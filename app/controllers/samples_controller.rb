require 'will_paginate/array'
require 'ingenuity'
require 'download_zip'

class SamplesController < ApplicationController
  unloadable
  respond_to :json
  cache_sweeper :sample_sweeper

  # GET /samples
  # GET /samples.xml
  def index
    #@samples = Sample.has_pedigree(params[:pedigree_filter]).find(:all, :include => [:assays, {:person => :pedigree }], :order => ['pedigrees.name'])
    if params[:name] or params[:sample_vendor_id] then
      nameArg=params[:name] if params[:name]
      nameArg=params[:sample_vendor_id] if  params[:sample_vendor_id]
      if nameArg.match(/%/) then
        @samples = Sample.where("sample_vendor_id like ?", nameArg)
          .includes(person: {pedigree: :study })
          .order('samples.sample_vendor_id').paginate :page => params[:page], :per_page => 100
      else
        @samples = Sample.where("sample_vendor_id = ?", nameArg)
          .includes(person: { pedigree: :study})
          .order('samples.sample_vendor_id').paginate :page => params[:page], :per_page => 100
      end
    elsif params[:customer_sample_id] then
      nameArg=params[:customer_sample_id] if  params[:customer_sample_id]
      if nameArg.match(/%/) then
        @samples = Sample.where("customer_sample_id like ?", nameArg)
          .includes(person: { pedigree: :study },
                :order => ['samples.customer_sample_id']).paginate :page => params[:page], :per_page => 100
      else
        @samples = Sample.where("customer_sample_id = ?", nameArg)
        .includes(person: { pedigree: :study})
        .order('samples.customer_sample_id').paginate :page => params[:page], :per_page => 100
      end
    elsif params[:customer_subject_id] then
        # aka person.collaborator_id
        nameArg=params[:customer_subject_id] if  params[:customer_subject_id]
        if nameArg.match(/%/) then
            @samples = Sample.includes(person: { pedigree: :study})
                        .where('people.collaborator_id like ?', nameArg)
                        .order('samples.sample_vendor_id').paginate :page => params[:page], :per_page => 100
        else
            @samples = Sample.includes(person: { pedigree: :study})
                        .where(people: {collaborator_id: nameArg})
                        .order('samples.sample_vendor_id').paginate :page => params[:page], :per_page => 100
        end
    elsif params[:id] then
      if params[:id].match(/%/) then
        @samples = Sample.where("samples.id like ?", params[:id])
        .includes(person: { pedigree: :study})
        .order('samples.id').paginate :page => params[:page], :per_page => 100
      else
        idNum=params[:id].gsub(/isb_sam.*_/,"")
        @samples = Sample.where("id = ?", idNum)
        .includes(person: { pedigree: :study})
        .order('samples.id').paginate :page => params[:page], :per_page => 100
      end
    elsif params[:person] then
      @samples = Sample.has_person(params[:person])
        .order(:pedigree).paginate :page => params[:page], :per_page => 100
    elsif params[:problems] then
      #@samples = Sample.where( Acquisition.where( Acquisition.arel_table[:sample_id].eq(Sample.arel_table[:id]) ).exists.not ).paginate(:page => params[:page], :per_page => 10)
      @samples = Sample.where.not(id: Acquisition.pluck(:sample_id)).paginate(:page => params[:page], :per_page => 10)
    else

      respond_to do |format|
        format.html {
          @samples = Sample.has_pedigree(params[:pedigree_filter])
            .order('samples.id')
            .paginate :page => params[:page], :per_page => 100
        }
        format.any  {
          @samples = Sample.has_pedigree(params[:pedigree_filter])
            .order('samples.id')
        }
      end

    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @samples }
      format.json { respond_with @samples }
      format.js
    end
  end

  # GET /samples/1
  # GET /samples/1.xml
  def show
    @sample = Sample.includes(:assays, { person: :pedigree}).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sample }
      format.json { render :json => @sample.to_json(:include => :assays) }
    end
  end

  # GET /samples/new
  # GET /samples/new.xml
  def new
    @sample = Sample.new
    @pedigrees = Pedigree.order(:tag)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sample }
    end
  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.includes(:assays, {person: :pedigree}).find(params[:id])
    @pedigrees = Pedigree.order(:tag)
  end

  # POST /samples
  # POST /samples.xml
  def create
    @sample = Sample.new(sample_params)
    logger.debug("creating a new sample #{@sample.inspect}")
    if params[:check_dates] then
      if params[:check_dates][:add_date_submitted].to_i != 1 then
        @sample.date_submitted = nil
      end
    end

    if params[:sample_type] then
      @sample.sample_type_id = params[:sample_type][:id]
    end

    if params[:status] then
      @sample.status = params[:status]
    end

    # need to make usre thatperson[id] is not null
    begin
      person = Person.find(params[:person][:id])
    rescue
      @sample.errors.add(:person, 'must be selected')
      render :action => "new" and return
    end
    @sample.person = person

    respond_to do |format|
      if @sample.save
         #check acquisition
	 acq_check = Acquisition.find_by_person_id_and_sample_id(params[:person][:id], @sample.id)
	 if acq_check.nil? then
           #create acquisition
           acquisition = Acquisition.new
           acquisition.person_id = params[:person][:id]
           acquisition.sample_id = @sample.id
           acquisition.save
         end
        format.html { redirect_to(@sample, :notice => 'Sample was successfully created.') }
        format.xml  { render :xml => @sample, :status => :created, :location => @sample }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /samples/1
  # PUT /samples/1.xml
  def update
    @sample = Sample.find(params[:id])
    @pedigrees = Pedigree.order("pedigrees.tag")

    ac_notice = ''
    if (params[:person] and params[:person][:id]) then
      if (@sample.person.nil? || params[:person][:id].to_i != @sample.person.id.to_i) then
        #logger.debug("updating the person associated with this sample from #{@sample.person.id} to #{params[:person][:id]}")
	#check that there isn't an entry for this acquisition in the db already!
	check_aq = Acquisition.where(person_id: params[:person][:id], sample_id: @sample.id)
	if (check_aq.size > 0) then
	  @sample.errors.add("Cannot create duplicate sample (#{@sample.id}) and person (#{@sample.person.id}) link.")
	else
	  if (@sample.person) then
    	    acquisition = Acquisition.where(person_id: @sample.person.id, sample_id: @sample.id)
	    if (acquisition.size > 1) then
	      #logger.debug("Found multiple samples for this sample (#{@sample.id}) and person(#{@sample.person.id}) combination!!!  This is an error in the database!!  Fix it manually!  #{acquisition.inspect}")
  	      @sample.errors.add("Found multiple samples for sample #{@sample.id} and person #{@sample.person.id}.  Fix manually.")
	    else
	      acquisition = acquisition.first
	      acquisition.person_id = params[:person][:id]
	      if (acquisition.save) then
	        ac_notice << "Sample association with Person was successfully updated."
	      else
	        ac_notice << "Sample association update failed."
	        @sample.errors.add(ac_notice)
	      end
	    end
	  else
	    # create a new acquisition
	    acquisition = Acquisition.new(person_id: params[:person][:id], sample_id: @sample.id)
	    if (acquisition.save) then
	      ac_notice << "Created new association between sample and person."
	    else
	      ac_notice << "Failed to create a new association between sample and person."
	    end
	  end
        end
      end

      # check to see if sequenced is true on person.  if not, then update it to yes.
      person = Person.find(params[:person][:id])
      if (person.sequenced? == false) then
  	person.planning_on_sequencing = 1
	if (person.save) then
          ac_notice << "  Updated person to show that sequencing was done."
        end
      end
    end
    @sample.errors.add(:sample, ac_notice) unless ac_notice.empty?

    respond_to do |format|
      if @sample.update_attributes(sample_params)
        #logger.debug("sample is #{@sample.inspect} after params #{sample_params}")
        format.html { redirect_to(@sample, :notice => "Sample was successfully updated. #{ac_notice}") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :notice => "Sample failed updating .#{ac_notice}" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.xml
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    respond_to do |format|
      format.html { redirect_to(samples_url) }
      format.xml  { head :ok }
    end
  end

  def get_drop_down_samples_by_pedigree
    options = Sample.where(pedigree_id: (params[:pedigree_id]).collect { |x| "\"#{x.id}\" : \"#{x.full_identifier}\""}
    render :text => "{#{options.join(",")}}"
  end

  def ped_info
    ped_info = Hash.new
    Sample.all.each do |s|
      ped = s.pedigree
      next if ped.nil?
      ped_info[s.sample_vendor_id] = ped.isb_pedigree_id
      ped_info[s.isb_sample_id] = ped.isb_pedigree_id
    end

    respond_to do |format|
      format.html
      format.xml {head :ok}
      format.json { render :json => ped_info }
    end
  end

  # provides a blank upload form
  def ingenuity_upload
  end

  def ingenuity_missing_samples
    uploaded_file = params[:file]
    logger.debug("#{uploaded_file.inspect}")
    if uploaded_file and uploaded_file.original_filename then
    file = Tempfile.new(uploaded_file.original_filename)
    file.write(uploaded_file.read.force_encoding("UTF-8"))
    outfilename = check_ingenuity(file)
    zipname = Pathname.new(outfilename.gsub(/.txt/,'.zip')).basename
    logger.debug("filename #{outfilename} zipname #{zipname}")
    respond_to do |format|
      format.html { download_zip("#{zipname}",{"ingenuity_add.txt" => outfilename})}
    end
    else
      respond_to do |format|
        flash[:error] = "You must supply a file to process."
        format.html { render :action => "ingenuity_upload" }
      end
    end
  end

  private
  def sample_params
    params.require(:sample).permit(:customer_sample_id, :sample_type_id, :status, :date_submitted, :protocol, :volume, :concentration, :quantity, :date_received, :description, :comments, :pedigree_id, :sample_vendor_id)
  end
end
