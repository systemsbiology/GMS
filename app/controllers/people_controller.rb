# encoding : utf-8
# in order to get Marshal deserialization to work you have to require all of the types of objects it might save
require 'person'
require 'relationship'
require 'sample'

class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    @people = Person.has_pedigree(params[:pedigree_filter]).paginate :page => params[:page], :per_page => 100

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
      format.js
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])

    if params[:gender] then
      if params[:gender] != 'unknown' then
        @person.gender = params[:gender]
      end
    end

    if params[:check_dates] then
      if params[:check_dates][:add_dob].to_i != 1 then
        @person.dob = nil
      end
      if params[:check_dates][:add_dod].to_i != 1 then
        @person.dod = nil
      end
    else
      @person.dob = nil
      @person.dod = nil
    end

    begin
      pedigree = Pedigree.find(params[:pedigree][:id])
    rescue
      @person.errors.add(:pedigree, 'must be selected')
      render :action => "new" and return
    end
    @person.pedigree = pedigree

    respond_to do |format|
      if @person.save
        # moved into an after_save callback 2012/02/07
        #isb_person_id = "isb_ind_#{@person.id}"
	#@person.isb_person_id = isb_person_id
	#@person.save

#	# create memberships
#	membership = Membership.new
#	# this should be params[:pedigree][:id] because that's what the create form passes in
#	membership.pedigree_id = params[:pedigree][:id]
#        membership.person_id = @person.id
#	membership.save

        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])

    @values = params[:person]
    if params[:check_dates] then
      if params[:check_dates][:add_dob].to_i != 1 then
        @values.delete_if{|k,v| k.match(/^dob/)}
      end
      if params[:check_dates][:add_dod].to_i != 1 then
        @values.delete_if{|k,v| k.match(/^dod/)}
      end
    else
      @values.delete_if{|k,v| k.match(/^dob/)}
      @values.delete_if{|k,v| k.match(/^dod/)}
    end

    # update the pedigree of the person
    if (params[:pedigree] and params[:pedigree][:id])
      pedigree = Pedigree.find(params[:pedigree][:id])
      @person.pedigree = pedigree
      @person.save
    end

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end


  def receiving_report
    if params[:pedigree_filter] and params[:pedigree_filter][:id] != '' then
      @pedigree = Pedigree.find(params[:pedigree_filter][:id])
      @people = Person.find(:all, :include => [ {:samples =>  :assays }, :pedigree], :conditions => { 'pedigrees.id' => @pedigree.id, 'planning_on_sequencing' => 1 })
    else
      @pedigree = Pedigree.order(:name)
      @people = Person.find(:all, :include => [ {:samples =>  :assays }, :pedigree], :conditions => { 'planning_on_sequencing' => 1 }, :order => [ 'pedigrees.name','people.collaborator_id','samples.status'])
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @people }
      format.js
    end
  end

############################################################################################################
############################################################################################################
#
# METHODS FOR HANDLING THE EXCEL/TSV/CSV UPLOAD
#
############################################################################################################
############################################################################################################
  # an empty controller method to just display upload.html.erb
  def upload
  end

############################################################################################################
############################################################################################################
############################################################################################################

  # process the file and add temporary data to the database
  def upload_and_validate
    begin
      pedigree = Pedigree.find(params[:pedigree][:id])
    rescue
      flash[:error] = "Pedigree must be selected"
      render :action => "upload" and return
    end

    begin
      disease = Disease.find(params[:disease][:id])
    rescue
      flash[:error] = "Disease must be selected"
      render :action => "upload" and return
    end
   
    spreadsheet_type = ''
    begin
      if params[:spreadsheet][:type] 
        spreadsheet_type = params[:spreadsheet][:type]
      else
        flash[:error] = "Spreadsheet type must be selected"
        render :action => "upload" and return
      end
    rescue
        flash[:error] = "Spreadsheet type must be selected"
        render :action => "upload" and return
    end

    test_file = params[:excel_file]
    file = Tempfile.new(test_file.original_filename)
    file.write(test_file.read.force_encoding("UTF-8"))
    begin
    book = Spreadsheet.open file.path
    rescue
      flash[:error] = "File provided is not a valid Excel spreadsheet (.xls) file. Excel 2007 spreadsheets (.xlsx) files are not supported."
      render :action => "upload" and return
    end
    sheet1 = book.worksheet 0

    if spreadsheet_type == 'fgg manifest' then
      ret_code, @people, @samples, @relationships, @memberships, @diagnoses, @acquisitions, @errors = process_fgg_manifest(sheet1, pedigree, disease)
    else
      flash[:error] = "Spreadsheet type not understood. Try this action again."
      render :action => "upload" and return
    end

    if ret_code == 0 then
      # render should already have been called in the process_XXXX method
      return
    end
    
    # need to add people, samples, relationships - don't track errors
    rc = 0
    @trans_id = Time.now.to_i + Random.rand(1000000)
    # temp objects are processed in order, so be careful of what order you write them

    # person needs to be written first
    rc = write_temp_object(@trans_id, "person",@people) unless @people.nil? or @people.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    
    # sample must be written next
    rc = write_temp_object(@trans_id, "sample",@samples) unless @samples.nil? or @samples.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)

    # rest are arbitrary
    rc = write_temp_object(@trans_id, "membership",@memberships) unless @memberships.nil? or @memberships.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)

    rc = write_temp_object(@trans_id, "acquisition",@acquisitions) unless @acquisitions.nil? or @acquisitions.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)

    rc = write_temp_object(@trans_id, "diagnosis",@diagnoses) unless @diagnoses.nil? or @diagnoses.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)

    rc = write_temp_object(@trans_id, "relationship",@relationships) unless @relationships.nil? or @relationships.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)

    respond_to do |format|
      format.html #upload_and_validate.html.erb
      format.xml  { head :ok }
    end

  end # end upload_and_validate


############################################################################################################
############################################################################################################
############################################################################################################

  def write_temp_object(trans_id, obj_type, object)
    to = TempObject.new
    to.object_type = obj_type.capitalize!
    to.trans_id = trans_id 
    to.added = Time.now
    to.object = Marshal.dump(object)
    if (to.save) then
      return 1
    else
      return 0
    end
  end

############################################################################################################
############################################################################################################
############################################################################################################

  # this is the method that takes a trans_id in the params and
  # gets all objects of that trans_is and saves them to the db
  def confirm
    trans_id = params[:trans_id]

    # may need to order this find eventually. Person needs to be processed first.
    # if getting errors about samples or relationships not finding the person
    # then this is likely the problem
    temp_objects = TempObject.find_all_by_trans_id(trans_id)
    @errors = Array.new
    temp_objects.each do |temp_obj|
      obj_array = Marshal.load(temp_obj.object)
      obj_array.each do |obj|
	if obj.class == Array then
	  if temp_obj.object_type == "Relationship" then
  	    # this is to deal with Relationship objects because we create a straight array
	    # for them because we don't know the person.id for the person if it hasn't
  	    # been created already...
	    person_collaborator_id = obj[0]
	    relation_collaborator_id = obj[1]
	    rel_name = obj[2]
	    rel_order = obj[3]

	    rel = Relationship.new
	    person = Person.find_by_collaborator_id(person_collaborator_id)
	    if person.nil? then
	      rel.errors.add(:person_id, "not found for #{person_collaborator_id}")
	      @errors.push(["relationship", rel, rel.errors])
	      next
	    end
	    relation = Person.find_by_collaborator_id(relation_collaborator_id)
	    if relation.nil? then 
	      rel.errors.add(:person_id, "not found for #{relation_collaborator_id}")
	      @errors.push(["relationship", rel, rel.errors])
	      next
	    end
	    rel.person = person
	    rel.relation = relation

	    # rel_name is 'undirected' for spouses but lookup_relationship_type requires 'husband' or 'wife'
	    # so we need to correct it to the proper name depending on the gender of the person
	    if rel_name == 'undirected' then
              if person.gender == "male" then
	        rel_name = "husband"
              elsif person.gender == "female" then
	        rel_name = "wife"
	      else
	        rel.errors.add(:person, 'gender not specified correctly')
		@errors.push(["relationship", rel, rel.errors])
		next
              end
	    end
	    rel.name = rel_name
	    rel.relationship_type = rel.lookup_relationship_type(rel_name)
	    rel.relation_order = rel_order unless rel_order.nil?
	    begin
	      if rel.valid? then
	        rel.save

	        recip = Relationship.new
	        recip.person = relation
	        recip.relation = person
	        recip.name = rel.reverse_name
	        recip.relationship_type = recip.lookup_relationship_type(rel.reverse_name)
	        recip.relation_order = rel_order unless rel_order.nil?
		begin
	          if recip.valid? then
	            recip.save
                  else
	            @errors.push(["relationship",recip, recip.errors])
	          end
		rescue Exception => e
	          # we don't want to display RecordNotUnique errors to the user here
	          unless e.class == ActiveRecord::RecordNotUnique then
		    recip.errors.add(:relationship,e.message)
	            @errors.push(["relationship",recip, recip.errors])
		  end
	        end
	      else
	        @errors.push(["relationship",rel, rel.errors])
              end
	    rescue Exception => e
	      # we don't want to display RecordNotUnique errors to the user here
	      unless e.class == ActiveRecord::RecordNotUnique then
	        rel.errors.add(:relationship,e.message)
	        @errors.push(["relationship",rel, rel.errors])
	      end
	    end 
	  elsif temp_obj.object_type == "Membership" then
	    ped = Pedigree.find(obj[0])
	    person = Person.find_by_collaborator_id(obj[1])
  	    m = Membership.new
	    if person.nil? then
	      m.errors.add(:person_id,"not found for #{obj[1]}")
	      @errors.push(["membership",m, m.errors])
	    else
	      m.person_id = person.id
	      m.pedigree_id = ped.id
	      if m.valid? then
	        m.save
	      else
	        @errors.push(["membership", m, m.errors])
	      end
	    end
	  elsif temp_obj.object_type == "Acquisition" then
	    person = Person.find_by_collaborator_id(obj[0])
	    sample = Sample.find_by_sample_vendor_id(obj[1])
  	    acq = Acquisition.new
	    if person.nil? then
	      acq.errors.add(:person_id,"not found for #{obj[0]}")
	      @errors.push(["acquisition",acq, acq.errors])
	    else
	      acq.person_id = person.id
	      acq.sample_id = sample.id
	      if acq.valid? then
	        acq.save
	      else
	        @errors.push(["acquisition", acq, acq.errors])
	      end
	    end
	  elsif temp_obj.object_type == "Diagnosis" then 
	    disease = Disease.find(obj[0])
	    person = Person.find_by_collaborator_id(obj[1])
	    diagnosis = Diagnosis.new
	    diagnosis.person_id = person.id
	    diagnosis.disease_id = disease.id
	    if diagnosis.valid? then
	      diagnosis.save
	    else
	      @errors.push(["diagnosis",diagnosis, diagnosis.errors])
	    end
	  end
	else
	  if obj.valid? then
	    obj.save
	  else
	    @errors.push(["#{temp_obj.object_type}",obj, obj.errors])
	  end
	end # end if obj.class = array
      end # end obj_array.each do

      # need to delete the temp_object now that we've added it
      begin
        temp_obj.destroy
      rescue Exception => exc
        temp_obj.errors.add(:object_type, "could not be destroyed")
        @errors.push(["temp_object", temp_obj.errors])
	logger.error("temp_object #{temp_obj.inspect} could not be destroyed!!  #{exc.message}")
      end

    end # end temp_objects.each do
  end

############################################################################################################
#
#  ###   ###    ##    ###  ####   ###   ###       #####   ####   ####
#  #  #  #  #  #  #  #     #     #     #          #      #      #
#  ###   ###   #  #  #     ####   ###   ###       ###    #  ##  #  ##
#  #     #  #  #  #  #     #         #     #      #      #   #  #   #
#  #     #  #   ##    ###  ####   ###   ###       #       ###    ###
#
############################################################################################################

  def process_fgg_manifest(sheet, pedigree, disease)
    people = []
    samples = []
    relationships = Array.new
    memberships = Array.new
    diagnoses = Array.new
    acquisitions = Array.new
    errors = Hash.new
    counter = 0
    flag = 0
    headers = nil

    begin
      header_file = File.read(EXCEL_FGG_HEADER_INDEX_FILE)
    rescue
      if !defined?(EXCEL_FGG_HEADER_INDEX_FILE) then
        logger.error("EXCEL_FGG_HEADER_INDEX_FILE is not set in the config/environment.rb.  Please set this parameter and restart the application.")
        flash[:error] = "EXCEL_FGG_HEADER_INDEX_FILE is not set in the config/environment.rb.  Please set this parameter and restart the application."
        render :action => "upload" and return(0)
      else
        logger.error("Could not read #{EXCEL_FGG_HEADER_INDEX_FILE}.  Please check that this file exists and is readable.")
        flash[:error] = "Could not read #{EXCEL_FGG_HEADER_INDEX_FILE}.  Please check that this file exists and is readable."
        render :action => "upload" and return(0)
      end
    end

    if sheet.name == "FGG Information v1.0" then
      headers =  YAML.load(header_file)[1.0]
      #elsif sheet.name == "Sample Information v3.5" then
      #  headers =  YAML.load(header_file)[3.5]
    else
      logger.error("Unhandled Sample Information version #{sheet.name} for FGG Manifest.  Check to make sure that the spreadsheet you submitted is a FGG Manifest spreadsheet.  If it is, then please add new version to the YAML and re-run.")
      flash[:error] = "Unhandled Sample Information version #{sheet.name} for FGG Manifest.  Check to make sure that the spreadsheet you submitted is a FGG Manifest spreadsheet.  If it is, then please add new version to the YAML and re-run."
      render :action => "upload" and return(0)
    end

    sheet.each do |row|
      if row[0] == "Sequencing Sample ID" then
        # check all of the headers exist
        headers.each do |col, index|
	  if row[index] != col then
            flash[:error] = "Spreadsheet provided has an incorrect column.  <b>\"#{row[index]}\"</b> in column number #{index} should be <b>\"#{col}\"</b>.  Please check the format of your spreadsheet."
	    render :action => "upload" and return(0)
	  end
        end

        flag = 1
        next
      end
      if flag == 1 then
        counter+=1
        next if row[2].nil? # skip empty rows at end of list
        next if row[0] == "A"  # skip header column list
	if row[headers["Customer Subject ID"]].nil? then
	  flash[:error] = "Spreadsheet provided is not of the proper type.  Can't find Customer Subject ID column."
          render :action => "upload" and return(0)
	end
	if row[headers["Customer Sample ID"]].nil? then
	  flash[:error] = "Spreadsheet provided is not a FGG Manifest.  Can't find the Customer Sample ID column."
	  render :action => "upload" and return(0)
	end
        next if row[headers["Customer Subject ID"]] == "NA19240" # skip example row

        # create the person information 
        p = Person.new
	customer_subject_id = row[headers["Customer Subject ID"]]
	if (customer_subject_id.is_a? Float) then 
	  customer_subject_id = customer_subject_id.to_i
	end
        p.collaborator_id = customer_subject_id
	logger.debug("collaborator_id is #{customer_subject_id}")
        p.gender = row[headers["Gender"]].downcase  # downcase it to make sure Female and FEMALE and female are the same...
	if p.gender != "male" and p.gender != "female" then
	  p.errors.add(:gender,"invalid selection #{row[headers["Gender"]]}")
        end
        p.comments = row[headers["Comments"]]
	p.planning_on_sequencing = 1


        # add diagnosis for this person if affected 
        affected_status = row[headers["Affected Status"]]
	if affected_status.nil? then
	  diag = Diagnosis.new
	  diag.errors.add(:disease_id, "could not be set.  No column called Affected Status found in upload spreadsheet.")
	  errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
	  errors["#{counter}"]["affected_status"] = diag.errors
	else
	  affected_status.downcase!
          if affected_status == "affected" then
	    diagnoses.push([disease.id, p.collaborator_id])
          end
	end
     
        # queue up the relationship information so that we can add it later after confirmation
        mother_id = row[headers["Mother's Subject ID"]]
        father_id = row[headers["Father's Subject ID"]]
	child_order = row[headers["Child Order"]].to_i
	child_order = '' if child_order.nil? # it's easier to find relationships that have no order value than to find ones that have a 1 value defaultly
	r = Relationship.new
	if mother_id == father_id then
	  unless mother_id.nil? or mother_id.match('NA') then
            relationships.push([mother_id, customer_subject_id, 'mother', child_order])
	    r.errors.add(:parent_id, "Father ID #{father_id} and mother ID #{mother_id} are the same.  Only entering one relationship.")
	  end
	else
	  unless mother_id.nil? or mother_id.match('NA') then
            relationships.push([mother_id, customer_subject_id, 'mother', child_order])
            relationships.push([father_id, customer_subject_id, 'father', child_order]) 
	  end
        end

	spouse_id =  row[headers["Spouse Subject ID"]]
	if !spouse_id.nil? and !spouse_id.to_s.match('NA') then
  	  spouse_order = row[headers["Spouse Order"]].to_i
  	  spouse_order = 1 if spouse_order.nil? or spouse_order.to_s.match('NA')
          #this person has a spouse and they are the X spouse that they've had
	  relationships.push([customer_subject_id, spouse_id, 'undirected', spouse_order])

          if r.errors.size > 0 then 
	    errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
	    errors["#{counter}"]["relationships"] = r.errors
	  end
        end

        vendor_id = row[headers["Sequencing Sample ID"]]
        if !vendor_id.nil? then  
          # create the sample information
          s = Sample.new
          source = row[headers["Sample Source"]]

  	  customer_sample_id = row[headers["Customer Sample ID"]]
	  if customer_sample_id != customer_subject_id then
	    s.customer_sample_id = customer_sample_id
	  end

          sample_type = SampleType.find_by_name(source)
          if sample_type.nil? then
            s.errors.add(:sample_type_id, "Cannot find sample_type for #{source} for sample for person #{p.collaborator_id}.  Add this as a sample type before importing this spreadsheet")
            errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
            errors["#{counter}"]["sample"] = s.errors
	    next
          end
          s.sample_type_id = sample_type.id
          s.status = 'submitted'

	  # need to add sample tumor processing here TODO

          if !vendor_id.match("-DNA_") then
            plate_id,plate_well = vendor_id.split(/_/,2)
            vendor_id = plate_id+"-DNA_"+plate_well
          end
          vendor_id = vendor_id
          s.sample_vendor_id = vendor_id

	  acquisitions.push([customer_subject_id, vendor_id])
 
          if s.valid?
            samples << s
	    p.planning_on_sequencing = 1
          else
            errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
            errors["#{counter}"]["sample"] = s.errors
          end
        end # end if !vendor_id.nil?

        if p.valid?
          people << p
        else
          errors["#{counter}"] = Hash.new
          errors["#{counter}"]["person"] = p.errors
          printable_row = Array.new
          row.each do |cell|
            if cell.class == Spreadsheet::Formula then
              printable_row << cell.value
            else 
              printable_row << cell
            end
          end
          errors["#{counter}"]["row"] = "<table><tr><td>"+printable_row.join("</td><td>")+"</tr></table>"
        end

	# queue up membership information /sigh
        memberships.push([pedigree.id, p.collaborator_id])

      end # end if flag

    end # end foreach row in sheet 1

    if headers.nil? then
      logger.error("Error loading header information for FGG Manifest from #{EXCEL_FGG_HEADER_INDEX_FILE}")
      flash[:error] = "Error loading header information for FGG Manifest."
      render :action => "upload" and return(0)
    end

    return 1, people, samples, relationships, memberships, diagnoses, acquisitions, errors
  end # end process fgi manifest definition

end
