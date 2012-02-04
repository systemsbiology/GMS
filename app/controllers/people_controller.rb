# encoding : utf-8
# in order to get Marshal deserialization to work you have to require all of the types of objects it might save
require 'person'
require 'relationship'
require 'sample'

class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    @people = Person.has_pedigree(params[:pedigree_filter])

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
        isb_person_id = "isb_ind_#{@person.id}"
	@person.isb_person_id = isb_person_id
	@person.save

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

  # an empty controller method to just display upload.html.erb
  def upload
  end

  # process the excel file and add data to the database
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
    book = Spreadsheet.open file.path
    sheet1 = book.worksheet 0
  
    if spreadsheet_type == 'cgi manifest' then
      @people, @samples, @relationships, @memberships, @diagnoses, @errors = process_cgi_manifest(sheet1, pedigree, disease)
    elsif spreadsheet_type == 'csv file' then
      @results, @errors = process_file('csv',sheet1, pedigree, disease)
    elsif spreadsheet_type == 'tsv file' then
      @results, @errors = process_file('tsv',sheet1, pedigree, disease)
    else
      flash[:error] = "Spreadsheet type not understood. Try this action again."
      render :action => "upload" and return
    end

    
    # need to add people, samples, relationships - don't track errors
    rc = 0
    @trans_id = Time.now.to_i + Random.rand(1000000)
    # temp objects are processed in order, so be careful of what order you write them

    # person needs to be written first
    rc = write_temp_object(@trans_id, "person",@people) unless @people.empty? or @people.nil?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    rc = write_temp_object(@trans_id, "sample",@samples) unless @samples.empty? or @samples.nil?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    rc = write_temp_object(@trans_id, "relationship",@relationships) unless @relationships.empty? or @relationships.nil?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    rc = write_temp_object(@trans_id, "membership",@memberships) unless @memberships.empty? or @memberships.nil?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    rc = write_temp_object(@trans_id, "diagnosis",@diagnoses) unless @diagnoses.empty? or @diagnoses.nil?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)

    respond_to do |format|
      format.html #upload_and_validate.html.erb
      format.xml  { head :ok }
    end

  end # end upload_and_validate

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
	    parent_collaborator_id = obj[0]
	    child_collaborator_id = obj[1]
	    rel_name = obj[2]
	    rel_order = obj[3]

	    rel = Relationship.new
	    parent = Person.find_by_collaborator_id(parent_collaborator_id)
	    if parent.nil? then
	      rel.errors.add(:person_id, "not found for #{parent_collaborator_id}")
	      @errors.push(["relationship", rel.errors])
	      next
	    end
	    child = Person.find_by_collaborator_id(child_collaborator_id)
	    if child.nil? then 
	      rel.errors.add(:person_id, "not found for #{child_collaborator_id}")
	      @errors.push(["relationship", rel.errors])
	      next
	    end
	    rel.person = parent
	    rel.relation = child
	    rel.name = rel_name
	    rel.relationship_type = rel.lookup_relationship_type(rel_name)
	    if rel.valid? then
	      rel.save

	      recip = Relationship.new
	      recip.person = child
	      recip.relation = parent
	      recip.name = rel.reverse_name
	      recip.relationship_type = recip.lookup_relationship_type(rel.reverse_name)
	      if recip.valid? then
	        recip.save
              else
	        @errors.push(["relationship",recip.errors])
	      end
	    else
	      @errors.push(["relationship",rel.errors])
            end
	  elsif temp_obj.object_type == "Membership" then
	    ped = Pedigree.find(obj[0])
	    person = Person.find_by_collaborator_id(obj[1])
  	    m = Membership.new
	    if person.nil? then
	      m.errors.add(:person_id,"not found for #{obj[1]}")
	      @errors.push(["membership",m.errors])
	    else
	      m.person_id = person.id
	      m.pedigree_id = ped.id
	      if m.valid? then
	        m.save
	      else
	        @errors.push(["membership", m.errors])
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
	      @errors.push(["diagnosis",diagnosis.errors])
	    end
	  end
	else
	  if obj.valid? then
	    obj.save
	  else
	    @errors.push(["#{temp_obj.object_type}",obj.errors])
	  end
	end # end if obj.class = array
      end # end obj_array.each do

      # need to delete the temp_object now that we've added it
      begin
        temp_obj.destroy
      rescue
        temp_obj.errors.add(:object_type, "could not be destroyed")
        @errors.push(["temp_object", temp_obj.errors])
      end

    end # end temp_objects.each do
  end

  def process_cgi_manifest(sheet, pedigree, disease)

    people = []
    samples = []
    relationships = Array.new
    memberships = Array.new
    diagnoses = Array.new
    errors = Hash.new
    counter = 0
    flag = 0

    sheet.each 1 do |row|
      if row[0] == "Complete Genomics Sample ID" then
        flag = 1
        next
      end
      if flag then
        counter+=1
        next if row[2].nil? # skip empty rows at end of list
        next if row[0] == "A"  # skip header column list
        next if row[3] == "NA19240" # skip example row

        # create the person information 
        p = Person.new
        p.collaborator_id = row[2]  # customer subject ID
        p.gender = row[5].downcase  # downcase it to make sure Female and FEMALE and female are the same...
	if p.gender != "male" and p.gender != "female" then
	  p.errors.add(:gender,"invalid selection #{row[5]}")
        end
        p.comments = row[17]
	p.planning_on_sequencing = 1

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
        #p.pedigree = pedigree
        memberships.push([pedigree.id, p.collaborator_id])

        # add diagnosis for this person if affected 
        phenotype = row[16]
        if phenotype.downcase! == "affected" then
	  diagnoses.push([disease.id, p.collaborator_id])
        end
     
        # queue up the relationship information so that we can add it later after confirmation
	# the end '' in this array is for 'child_order', which the CGI manifest format doesn't have
        mother_id = row[13]
        father_id = row[14]
	r = Relationship.new
	if mother_id == father_id then
	  unless mother_id.match('NA') or mother_id.nil? then
          relationships.push([mother_id, row[2], 'mother', ''])
	  r.errors.add(:parent_id, "Father ID #{father_id} and mother ID #{mother_id} are the same.  Only entering one relationship.")
	  end
	else
          relationships.push([mother_id, row[2], 'mother', '']) unless mother_id.match('NA') or mother_id.nil?
          relationships.push([father_id, row[2], 'father', '']) unless father_id.match('NA') or father_id.nil?
        end

        if r.errors.size > 0 then 
	  errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
	  errors["#{counter}"]["relationships"] = r.errors
	end

        # create the sample information
        s = Sample.new
        s.volume = row[6]
        s.concentration = row[7]
        #quantity is a formula
        if row[8].class == Spreadsheet::Formula then
          s.quantity = row[8].value
        else
          s.quantity = row[8]
        end
        source = row[10]
        sample_type = SampleType.find_by_name(source)
        if sample_type.nil? then
          s.errors.add(:sample_type_id, "Cannot find sample_type for #{source} for sample for person #{p.collaborator_id}.  Add this as a sample type before importing this spreadsheet")
          next
        end
        s.sample_type_id = sample_type.id
        s.status = 'submitted'

        if row[0].class == Spreadsheet::Formula then
          # this is sample.vendor_id
          vendor_id = row[0].value
          if !vendor_id.match("-DNA_") then
            plate_id,plate_well = vendor_id.split(/_/,2)
            vendor_id = plate_id+"-DNA_"+plate_well
          end
          vendor_id = vendor_id + 'test'
          s.sample_vendor_id = vendor_id
        else
          s.errors.add("Found strange sample_vendor_id : #{row[0]}, expected formula in CGI Manifest.  Try using TSV type?")
          next
        end
 
        if s.valid?
          samples << s
        else
          errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
          errors["#{counter}"]["sample"] = s.errors
        end

      end # end if flag
    end # end foreach row in sheet 1
    flash[:notice] = "CGI Manifests don't contain child order information, so you will have to edit each relationship created in order to add this information."
    return people, samples, relationships, memberships, diagnoses, errors
  end # end process cgi manifest definition

end
