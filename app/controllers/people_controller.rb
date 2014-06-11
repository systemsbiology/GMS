# encoding : utf-8
# in order to get Marshal deserialization to work you have to require all of the types of objects it might save
require 'person'
require 'relationship'
require 'sample'

class PeopleController < ApplicationController
#  load_and_authorize_resource
  respond_to :json
  caches_action :ped_info
  cache_sweeper :people_sweeper
  # GET /people
  # GET /people.xml
  def index
    respond_to do |format|
      format.html {
        @people = Person.has_pedigree(params[:pedigree_filter])
          .paginate :page => params[:page], :per_page => 100
      }
      format.any  {
        @people = Person.has_pedigree(params[:pedigree_filter])
          .find(:all, :order => [ 'people.id'])
      }
    end
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
      format.js
      format.json { respond_with @people }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
      format.json { respond_with @person }
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
    @person = Person.new(person_params)
    #puts "params #{params.inspect}"
    #puts "person_params #{person_params.inspect}"
    #puts "person #{@person.inspect}"
    #logger.debug("person_param #{person_params.inspect}")
    #logger.debug("params #{params.inspect}")


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
    @person.pedigree_id = params[:pedigree][:id]
    #logger.debug("person is #{@person.inspect}")
    puts "last person #{@person.inspect}"
    respond_to do |format|
      if @person.save
        # moved into an after_save callback 2012/02/07
        #isb_person_id = "isb_ind_#{@person.id}"
        #@person.isb_person_id = isb_person_id
        #@person.save

#        # create memberships
#        membership = Membership.new
#        # this should be params[:pedigree][:id] because that's what the create form passes in
#        membership.pedigree_id = params[:pedigree][:id]
#            membership.person_id = @person.id
#        membership.save
        expire_action :action => :ped_info
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
    @values = person_params

    if params[:check_dates] then
        logger.debug("check dates is present in params #{params.inspect}")
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
      @values["pedigree_id"] = pedigree.id
      @person.pedigree = pedigree
      @person.save
    end

    respond_to do |format|
      if @person.update_attributes(@values)
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
    pedigree = @person.pedigree
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(pedigree_url(pedigree)) }
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

    condition = ''
    if (params[:condition] && params[:condition][:id] && !params[:condition][:id].empty?) then
      begin
        condition = Condition.find(params[:condition][:id])
      #rescue
      #  flash[:error] = "Condition must be selected params: #{params[:condition].inspect}"
      #  render :action => "upload" and return
      end
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
      ret_code, @people, @samples, @relationships, @memberships, @diagnoses, @acquisitions, @errors, @aliases, @phenotypes = process_fgg_manifest(sheet1, pedigree, condition)
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
    rc = write_temp_object(@trans_id, "person",@people,1) unless @people.nil? or @people.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
#    logger.debug("rc for people #{@people.inspect} is #{rc.inspect}")

    # sample must be written next
    rc = write_temp_object(@trans_id, "sample",@samples,2) unless @samples.nil? or @samples.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
#    logger.debug("rc for samples #{@samples.inspect} is #{rc.inspect}")

    # rest are arbitrary
    rc = write_temp_object(@trans_id, "membership",@memberships,3) unless @memberships.nil? or @memberships.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
#    logger.debug("rc for memberships #{@memberships.inspect} is #{rc.inspect}")

    rc = write_temp_object(@trans_id, "acquisition",@acquisitions,4) unless @acquisitions.nil? or @acquisitions.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
#    logger.debug("rc for acquisitions #{@acquisitions.inspect} is #{rc.inspect}")

    rc = write_temp_object(@trans_id, "diagnosis",@diagnoses,5) unless @diagnoses.nil? or @diagnoses.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
#    logger.debug("rc for diagnosis #{@diagnoses.inspect} is #{rc.inspect}")

    rc = write_temp_object(@trans_id, "relationship",@relationships,6) unless @relationships.nil? or @relationships.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
#    logger.debug("rc for relationship #{@relationships.inspect} is #{rc.inspect}")

    rc = write_temp_object(@trans_id, "aliases",@aliases,7) unless @aliases.nil? or @aliases.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    logger.debug("rc for alias #{@aliases.inspect} is #{rc.inspect}")

    rc = write_temp_object(@trans_id, "phenotypes",@phenotypes,8) unless @phenotypes.nil? or @phenotypes.empty?
    flash[:error] = "Write temporary objects failed.  Please contact system administrator." if (rc == 0)
    logger.debug("rc for phenotype #{@phenotypes.inspect} is #{rc.inspect}")

    respond_to do |format|
      format.html #upload_and_validate.html.erb
      format.xml  { head :ok }
    end

  end # end upload_and_validate


############################################################################################################
############################################################################################################
############################################################################################################

  def write_temp_object(trans_id, obj_type, object, order)
    to = TempObject.new
    to.object_type = obj_type.capitalize!
    to.trans_id = trans_id 
    to.added = Time.now
    to.object = Marshal.dump(object)
    to.object_order = order
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
    @pedigree_id = ''

    #process Person objects first
    @errors = Array.new
    person_temp_object = TempObject.find_by_trans_id_and_object_type(trans_id, "Person")
    if (person_temp_object.nil?) then
      #logger.error("No temp objects found to enter in database for transaction id #{trans_id}")
      # don't need to return here because this prevents the processing of pedigrees that already
      # have person information entered in the database
    else
      # process the person objects
      begin
        #logger.debug("person_temp_object #{person_temp_object.inspect}")
        #logger.debug("person_temp_object object #{person_temp_object.object.inspect}")
        person_obj_array = Marshal.load(person_temp_object.object)
        #logger.debug("person_obj_array #{person_obj_array.inspect}")
      rescue ArgumentError => error
        lazy_load ||= Hash.new {|hash, hash_key| hash[hash_key] = true; false}
        if error.to_s[/undefined class|referred/] && !lazy_load[error.to_s.split.last.constantize]
          retry
        else
          raise error
        end
      end

      person_obj_array.each do |person_obj|
        #logger.debug("person obj is #{person_obj.inspect}")
        #logger.debug("person_obj is a #{person_obj.class.inspect}")
        #logger.debug("person_obj is a #{person_obj.pedigree_id.class.inspect}")
        @pedigree_id = person_obj.pedigree_id
        begin
          if person_obj.valid? then
            person_obj.save!
          else
            @errors.push(["#{person_temp_object.object_type}",person_obj, person_obj.errors])
          end
        rescue NoMethodError => error
          raise error
        end
      end

      begin
        person_temp_object.destroy
      rescue Exception => exc
        person_temp_object.errors.add(:object_type, "could not be destroyed")
        @errors.push(["person_temp_object", person_temp_object.errors])
        logger.error("person_temp_object #{person_temp_object.inspect} could not be destroyed!!  #{exc.message}")
      end
    end

    # process the rest of the objects
    temp_objects = TempObject.find(:all, :conditions => {:trans_id => trans_id}, :order => "object_order")
    #logger.debug("temp objects are #{temp_objects.inspect}")
    temp_objects.each do |temp_obj|
      # need the begin rescue block because Person includes pedigree information and it needs to lazy load the pedigree class otherwise there is an error
      begin 
        obj_array = Marshal.load(temp_obj.object)
      rescue ArgumentError => error
        lazy_load ||= Hash.new {|hash, hash_key| hash[hash_key] = true; false}
        if error.to_s[/undefined class|referred/] && !lazy_load[error.to_s.split.last.constantize]
          retry
        else
          raise error
        end
      end
      obj_array.each do |obj|
    if obj.class == Array then
      if temp_obj.object_type == "Relationship" then
          # this is to deal with Relationship objects because we create a straight array
        # for them because we don't know the person.id for the person if it hasn't
          # been created already...
        #logger.debug("temp_obj is #{temp_obj.inspect}")
        pedigree_id = obj[0]
        @pedigree_id = pedigree_id
        person_collaborator_id = obj[1]
        relation_collaborator_id = obj[2]
        rel_name = obj[3]
        rel_order = obj[4]

        rel = Relationship.new
        person = Person.has_pedigree(pedigree_id).find_by_collaborator_id(person_collaborator_id)
        if person.nil? then
          rel.errors.add(:person_id, "not found for #{person_collaborator_id} in pedigree #{pedigree_id}")
          @errors.push(["relationship", rel, rel.errors])
          next
        end
        relation = Person.has_pedigree(pedigree_id).find_by_collaborator_id(relation_collaborator_id)
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

        if rel_name == 'monozygotic twin' then
          rel_name = 'monozygotic twin'
        end

        if rel_name == 'dizygotic twin' then
          rel_name = 'dizygotic twin'
        end

        rel.name = rel_name
        rel.relationship_type = rel.lookup_relationship_type(rel_name)
        #logger.debug("relationship type is #{rel.relationship_type} for #{rel.inspect} for person #{person.inspect} and relation #{relation.inspect}")
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
        @pedigree_id = ped.id
        #logger.debug("processing membership information for pedigree #{ped.inspect}")
        person = Person.find_by_collaborator_id_and_pedigree_id(obj[1], obj[0])
          m = Membership.new
        if person.nil? then
          m.errors.add(:person_id,"not found for #{obj[1]} in pedigree #{obj[0]}")
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
        pedigree_id = obj[0]
        @pedigree_id = pedigree_id
        person = Person.has_pedigree(pedigree_id).find_by_collaborator_id(obj[1])
        sample = Sample.find_by_sample_vendor_id_and_pedigree_id(obj[2], obj[0])
        logger.debug("acquisition debug says pedigree #{pedigree_id.inspect} person #{person.inspect} sample #{sample.inspect}")
        acq = Acquisition.new
        if person.nil? then
          acq.errors.add(:person_id,"not found for #{obj[0]}")
          @errors.push(["acquisition",acq, acq.errors])
        elsif sample.nil? then
          acq.errors.add(:sample_id,"not found for #{obj[0]} person #{obj[1]} and sample #{obj[2]}")
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
        condition = Condition.find(obj[0])
        pedigree_id = obj[1]
        @pedigree_id = pedigree_id
        person = Person.has_pedigree(pedigree_id).find_by_collaborator_id(obj[2])
            diagnosis = Diagnosis.new
        if person.nil? then
          diagnosis.errors.add(:person_id,"not found for condition #{obj[0]} pedigree #{pedigree_id} collaborator_id #{obj[2]}")
          @errors.push(["diagnosis",diagnosis, diagnosis.errors])
        else
            diagnosis.person_id = person.id
          diagnosis.condition_id = condition.id
          if diagnosis.valid? then
            diagnosis.save
          else
            @errors.push(["diagnosis",diagnosis, diagnosis.errors])
          end
        end
      elsif temp_obj.object_type == "Aliases" then
        person = Person.has_pedigree(obj[0]).find_by_collaborator_id(obj[1])
        if person.nil? then
            person = Person.new
            person.errors.add(:person_id,"not found for pedigree #{obj[0]} collaborator #{obj[1]}")
            @errors.push(["person",person,person.errors])
        else
            @pedigree_id = person.pedigree_id
            if obj[2].kind_of?(Array) then
                obj[2].each do |ali|
                    pa = PersonAlias.new
                    pa.person_id = person.id
                    pa.value = ali
                    pa.alias_type = "collaborator_id"
                    if pa.valid? then
                        pa.save
                    else
                        @errors.push(["person_alias",pa, pa.errors])
                    end
                end
            else
                pa = PersonAlias.new
                pa.person_id = person.id
                pa.value = obj[2]
                pa.alias_type = "collaborator_id"
                if pa.valid? then
                    pa.save
                else
                    @errors.push(["person_alias",pa, pa.errors])
                end
            end
        end
      elsif temp_obj.object_type == "Phenotypes" then
        phenotype = Phenotype.find(obj[0])
        person = Person.has_pedigree(obj[1]).find_by_collaborator_id(obj[2])
        @pedigree_id = person.pedigree_id
        trait = Trait.find_by_person_id_and_phenotype_id_and_trait_information(person.id, phenotype.id,obj[3])
        #logger.debug("phenotypes debug person #{person.inspect} trait #{trait.inspect}")
        if trait.nil? then
          trait = Trait.new
        end
        trait.person_id = person.id
        trait.phenotype_id = phenotype.id
        trait.trait_information = obj[3]
        if trait.valid? then
          trait.save
        else
            @errors.push(["trait",trait,trait.errors])
        end
      end
    else
      if obj.valid? then
      #logger.debug("saving object #{obj.inspect}")
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

  def process_fgg_manifest(sheet, pedigree, condition)
    people = []
    samples = []
    relationships = Array.new
    memberships = Array.new
    diagnoses = Array.new
    acquisitions = Array.new
    errors = Hash.new
    aliases = Array.new
    phenotypes = Array.new
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
    elsif sheet.name == "FGG Information v1.1" then
      headers = YAML.load(header_file)[1.1]
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
        if row[2].nil? and ! row[3].nil? then
            p = Person.new
            p.errors.add(:customer_sample_id, "cannot be blank.")
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
        # need to check both customer_subject_id and customer_sample_id in case they're
        # trying to switch which one is which in the database... /facepalm
        customer_subject_id = row[headers["Customer Subject ID"]]
        if (customer_subject_id.is_a? Float) then 
          customer_subject_id = customer_subject_id.to_i
        end

        customer_sample_id = row[headers["Customer Sample ID"]]
        # use customer subject_id to find the person with the correct pedigree
        p = Person.has_pedigree(pedigree.id).find_by_collaborator_id(customer_subject_id) 
        # use the customer_sample_id to find the person with the correct pedigree
        if (p.nil?) then
            p = Person.has_pedigree(pedigree.id).find_by_collaborator_id(customer_sample_id)
        end
        # use the customer_subject_id but don't trust that there's an entry in the 
        # memberships table since this sometimes errs out, but then test that
        # the pedigree id is the same
        if (p.nil?) then
            ps = Person.find_by_collaborator_id(customer_subject_id)
            logger.debug("pedigree #{pedigree.inspect}")
            if (!ps.nil? and ps.pedigree_id == pedigree.id) then
               p = ps
            end
        end
        # as above except use the customer_sample_id
        if (p.nil?) then
            ps = Person.find_by_collaborator_id(customer_sample_id)
            if (!ps.nil? and ps.pedigree_id == pedigree.id) then
               p = ps
            end
        end
        logger.debug("creating new p") if p.nil?
        p = Person.new if p.nil?
        p.collaborator_id = customer_subject_id

        if headers["Subject Aliases"] and !row[headers["Subject Aliases"]].nil? then
            person_aliases = Array.new
            person_alias = row[headers["Subject Aliases"]]
            logger.debug("person_alias #{person_alias}")
            if person_alias.to_s.match(';') then
              person_aliases = person_alias.split(/;/)
            else
              person_aliases.push(person_alias.to_s)
            end
            logger.debug("person_aliases #{person_aliases.inspect}")
            new_aliases = Array.new
            person_aliases.each do |pa|
              peral = PersonAlias.find_by_person_id_and_value_and_alias_type(p.id, pa, "collaborator_id")
              if peral.nil? then 
                new_aliases.push(pa.to_s)
              end
            end
            logger.debug("new aliasses #{new_aliases.inspect}")
            aliases.push([pedigree.id, p.collaborator_id, new_aliases]) unless new_aliases.nil?
        end

        if row[headers["Gender"]].nil? then
            p.errors.add(:gender, "Must provide a gender for person #{customer_sample_id}")
        else
            p.gender = row[headers["Gender"]].downcase  # downcase it to make sure Female and FEMALE and female are the same...
            if p.gender != "male" and p.gender != "female" and p.gender != "unknown" then
                p.errors.add(:gender,"invalid selection #{row[headers["Gender"]]}")
            end
        end
        p.comments = row[headers["Comments"]]
        p.pedigree_id = pedigree.id

        if !condition.nil? and !condition.blank? then
            # add diagnosis for this person if affected 
            affected_status = row[headers["Affected Status"]]
            if affected_status.nil? then
                diag = Diagnosis.new
                diag.errors.add(:condition_id, "could not be set.  No value for Affected Status found in upload spreadsheet.")
                errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
                errors["#{counter}"]["affected_status"] = diag.errors
            else
                affected_status.downcase!
                # other statuses are unaffected and unknown but those aren't handled right now...
                # don't really have a way to indicate in the database that the person is known unaffected versus unknown
                if affected_status == "affected" then
                    diagnoses.push([condition.id, pedigree.id, p.collaborator_id])
                elsif affected_status == "unknown" or affected_status == "unaffected" then
                    # do nothing - these are valid statuses but not stored in db
                else
                    errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
                    tp = Person.new
                    tp.errors.add(:affected_status, "value provided not recognized - '#{affected_status}'. Should be 'affected' in order to set status correctly.")
                    errors["#{counter}"]["affected_status"] = tp.errors
                    errors["#{counter}"]["line"] = row
                end
            end
        end

        if headers["Subject Phenotypes"] and !row[headers["Subject Phenotypes"]].nil? then
           all_phenotypes = row[headers["Subject Phenotypes"]].split(/;/)
           all_phenotypes.each do |pheno|
                if pheno.match(/=/) then
                  (pheno, pheno_info) = pheno.split(/=/)
                end
                phenotype = Phenotype.find_by_name(pheno)
                if phenotype.nil? then
                    phenotype = Phenotype.find_by_tag(pheno)
                end
                if phenotype.nil? or phenotype.to_s.match('NA') then
                    phen = Phenotype.new
                    phen.errors.add(:name, "could not be found.  Upload value of #{pheno} not in database. Please create in database before uploading spreadsheet.")
                    errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
                    errors["#{counter}"]["phenotype"] = phen.errors
                    next
                end
                phenotypes.push([phenotype.id, pedigree.id, p.collaborator_id, pheno_info])
           end
        end

        # queue up the relationship information so that we can add it later after confirmation
        mother_id = row[headers["Mother's Subject ID"]]
        mother_id = mother_id.to_i if (mother_id.is_a? Float)
        father_id = row[headers["Father's Subject ID"]]
        father_id = father_id.to_i if (father_id.is_a? Float)
    
        child_order = row[headers["Child Order"]] ? row[headers["Child Order"]].to_i : 1
        r = Relationship.new
        if mother_id == father_id then
            unless mother_id.nil? or mother_id.to_s.match('NA') or mother_id.to_s.empty? then
                relationships.push([pedigree.id, mother_id, customer_subject_id, 'mother', child_order])
                r.errors.add(:parent_id, "Father ID '#{father_id}' and mother ID '#{mother_id}' are the same.  Only entering one relationship.")
            end
        else
            unless mother_id.nil? or mother_id.to_s.match('NA') or mother_id.to_s.empty? then
                relationships.push([pedigree.id, mother_id, customer_subject_id, 'mother', child_order])
            end
            unless father_id.nil? or father_id.to_s.match('NA') or father_id.to_s.empty? then
                relationships.push([pedigree.id, father_id, customer_subject_id, 'father', child_order]) 
            end
        end

        if headers["Monozygotic Twin Subject ID"] then
            mz_twin_id = row[headers["Monozygotic Twin Subject ID"]]
            mz_twin_id = mz_twin_id.to_i if (mz_twin_id.is_a? Float)
            if (!mz_twin_id.nil? and !mz_twin_id.empty? and !mz_twin_id.to_s.match('NA')) then
                relationships.push([pedigree.id, customer_subject_id, mz_twin_id, 'monozygotic twin','1'])
            end
        elsif headers["Twin Subject ID"] and !row[headers["Twin Subject ID"]].nil? then
            if !row[headers["Twin Subject ID"]].nil? and !row[headers["Twin Type"]].nil? then 
                if (row[headers["Twin Type"]] != 'mz' and row[headers["Twin Type"]] != 'dz' and row[headers["Twin Type"]] != 'monozygotic' and row[headers["Twin Type"]] != 'dizygotic' ) then
                    r.errors.add(:parent_id, "Twin Type must be 'mz', 'dz', 'monozygotic', or 'dizygotic'")
                else
                    twin_id = row[headers["Twin Subject ID"]]
                    twin_type = row[headers["Twin Type"]]
                    if (twin_type == "mz" or twin_type == "monozygotic") then twin_type = "monozygotic twin" end
                    if (twin_type == "dz" or twin_type == "dizygotic") then twin_type = "dizygotic twin" end
                    if (!twin_id.nil? and !twin_id.empty? and !twin_id.to_s.match('NA')) then
                        relationships.push([pedigree.id, customer_subject_id, twin_id, twin_type, '1'])
                    end
                end
            else 
                r.errors.add(:parent_id, "Twin Subject ID requires a Twin Type")
            end
        end

        spouse_id =  row[headers["Spouse Subject ID"]]
        spouse_id = spouse_id.to_i if (spouse_id.is_a? Float)
        if !spouse_id.nil? and !spouse_id.to_s.match('NA') then
            spouse_order = row[headers["Spouse Order"]]
            spouse_order = spouse_order.to_i if (spouse_order.is_a? Float)
            spouse_order = 1 if (spouse_order.nil? or spouse_order.to_s.match('NA'))
            #this person has a spouse and they are the X spouse that they've had
            relationships.push([pedigree.id, customer_subject_id, spouse_id, 'undirected', spouse_order])

            if r.errors.size > 0 then 
                errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
                errors["#{counter}"]["relationships"] = r.errors
            end
        end

        vendor_id = row[headers["Sequencing Sample ID"]]
        if !vendor_id.nil? then  
            # create the sample information
            s = Sample.find(:first, :conditions => {:sample_vendor_id => vendor_id, :pedigree_id =>pedigree.id}) || Sample.new
            source = row[headers["Sample Source"]]
            s.customer_sample_id = customer_sample_id # don't check for duplicates, just add it and they can change it later

            sample_type = SampleType.find_by_name(source)
            if sample_type.nil? then
                s.errors.add(:sample_type_id, "Cannot find sample_type for #{source} for sample for person #{p.collaborator_id}.  Add this as a sample type before importing this spreadsheet")
                errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
                errors["#{counter}"]["sample"] = s.errors
                next
            end
            s.sample_type_id = sample_type.id

            # need to add sample tumor processing here TODO

            if (!vendor_id.match("-DNA_") and vendor_id.match("GS")) then
                plate_id,plate_well = vendor_id.split(/_/,2)
                vendor_id = plate_id+"-DNA_"+plate_well
            end
            s.sample_vendor_id = vendor_id
            s.pedigree_id = pedigree.id

            acquisitions.push([pedigree.id, customer_subject_id, vendor_id])
 
            # handle volume, concentration, quantity
            volume = row[headers["Volume"]]
            concentration = row[headers["Concentration"]]
            quantity = row[headers["Quantity"]]
            s.volume = volume unless volume.nil? or volume.blank?
            s.concentration = concentration unless concentration.nil? or concentration.blank?
            s.quantity = quantity unless quantity.nil? or quantity.blank?

            # handle sample status
            status = row[headers["Sample Status"]]
            if status.nil? or status.blank? then
                s.status = 'submitted'
            else 
                s.status = status
            end

            if s.valid?
                samples << s
                p.planning_on_sequencing = 1
            else
                errors["#{counter}"] = Hash.new if errors["#{counter}"].nil?
                errors["#{counter}"]["sample"] = s.errors
            end
        else
            p.planning_on_sequencing = 0
        end # end if !vendor_id.nil?

        if p.valid?
          people << p
        else
            logger.debug("p is not valid #{p.inspect}")
            logger.debug("p.errors #{p.errors.inspect}")
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
            logger.debug("set error #{counter} to #{printable_row.inspect}")
            errors["#{counter}"]["row"] = "<table><tr><td>"+printable_row.join("</td><td>")+"</tr></table>"
        end

        #   queue up membership information /sigh
        memberships.push([pedigree.id, p.collaborator_id])

      end # end if flag

    end # end foreach row in sheet 1

    if headers.nil? then
      logger.error("Error loading header information for FGG Manifest from #{EXCEL_FGG_HEADER_INDEX_FILE}")
      flash[:error] = "Error loading header information for FGG Manifest."
      render :action => "upload" and return(0)
    end

    #logger.debug("people are #{people.inspect}")
    #logger.debug("samples are #{samples.inspect}")
    #logger.debug("relationships is #{relationships.inspect}")
    #logger.debug("memberships are #{memberships.inspect}")
    #logger.debug("acquisitions are #{acquisitions.inspect}")
    #logger.debug("errors are #{errors.inspect}")

    return 1, people, samples, relationships, memberships, diagnoses, acquisitions, errors, aliases, phenotypes
  end # end process fgi manifest definition

  def get_drop_down_people_by_pedigree
    options = Person.has_pedigree(params[:pedigree_id]).collect { |per| "\"#{per.id}\" : \"#{per.full_identifier}\"" }
    render :text => "{#{options.join(",")}}"
  end

  def ped_info
    ped_info = Hash.new
    Person.all.each do |p|
      ped = p.pedigree
      logger.error("no pedigree for person #{p.inspect}") if ped.nil?
      next if ped.nil?
      ped_info[p.collaborator_id] = ped.isb_pedigree_id
      ped_info[p.isb_person_id] = ped.isb_pedigree_id
      ped_info[p.full_identifier] = ped.isb_pedigree_id
    end

    respond_to do |format|
      format.html
      format.xml {head :ok}
      format.json { render :json => ped_info }
    end
  end

  private
  def person_params
    params.require(:person).permit(:collaborator_id, :gender, :dob, :dod, :deceased, :planning_on_sequencing, :complete, :root, :comments, :pedigree_id)
  end
end
