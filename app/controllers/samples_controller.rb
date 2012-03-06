class SamplesController < ApplicationController
  unloadable
  respond_to :json

  # GET /samples
  # GET /samples.xml
  def index
#    @samples = Sample.has_pedigree(params[:pedigree_filter]).find(:all, :include => [:assays, {:person => :pedigree }], :order => ['pedigrees.name'])
    @samples = Sample.has_pedigree(params[:pedigree_filter]).order_by_pedigree.paginate :page => params[:page], :per_page => 100
    if params[:sample_vendor_id] then
      if params[:sample_vendor_id].match(/%/) then
        @samples = Sample.has_pedigree(params[:pedigree_filter]).where("sample_vendor_id like ?", params[:sample_vendor_id]).find(:all, :include => {:person => {:pedigree => :study }}, :order => ['pedigrees.name'])
      else
        @samples = Sample.has_pedigree(params[:pedigree_filter]).where("sample_vendor_id = ?", params[:sample_vendor_id]).find(:all, :include => {:person => { :pedigree => :study} }, :order => ['pedigrees.name'])
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
    @sample = Sample.find(params[:id], :include => [:assays, { :person => :pedigree}])

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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sample }
    end
  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id])
  end

  # POST /samples
  # POST /samples.xml
  def create
    @sample = Sample.new(params[:sample])

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
         isb_sample_id = "isb_sample_#{@sample.id}"
         @sample.isb_sample_id = isb_sample_id
         @sample.save

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

    ac_notice = ''
    if (params[:person] and params[:person][:id]) then
      if (params[:person][:id].to_i != @sample.person.id.to_i) then
        #logger.debug("updating the person associated with this sample from #{@sample.person.id} to #{params[:person][:id]}")
	#check that there isn't an entry for this acquisition in the db already!
	check_aq = Acquisition.find(:all, :conditions => {:person_id => params[:person][:id], :sample_id => @sample.id})
	if (check_aq.size > 0) then
	  @sample.errors.add("Cannot create duplicate sample (#{@sample.id}) and person (#{@sample.person.id}) link.")
	else 
  	  acquisition = Acquisition.find(:all, :conditions => {:person_id => @sample.person.id, :sample_id => @sample.id})
	  if (acquisition.size > 1) then
	    #logger.debug("Found multiple samples for this sample (#{@sample.id}) and person(#{@sample.person.id}) combination!!!  This is an error in the database!!  Fix it manually!  #{acquisition.inspect}")
	    @sample.errors.add("Found multiple samples for sample #{@sample.id} and person #{@sample.person.id}.  Fix manually.")
	  else 
	    acquisition = acquisition.first
	    acquisition.person_id = params[:person][:id]
	    if (acquisition.save) then
	      ac_notice << "Sample association with Person was successfully updated."
	      # check to see if sequenced is true on person.  if not, then update it to yes.
	      if (@sample.person.sequenced? == false) then
	        person = @sample.person
		person.planning_on_sequencing = 1
		if (person.save) then
		  ac_notice << "Updated person to show that sequencing was done."
		end
	      end
	    else
	      ac_notice << "Sample association update failed."
	      @sample.errors.add(ac_notice)
	    end
	  end
	end
      end
    end

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        logger.debug("sample is #{@sample.inspect} after params #{params[:sample]}")
        format.html { redirect_to(@sample, :notice => "Sample was successfully updated. #{ac_notice}") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
end
