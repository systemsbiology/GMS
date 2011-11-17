class SamplesController < ApplicationController
  # GET /samples
  # GET /samples.xml
  def index
    @samples = Sample.has_pedigree(params[:pedigree_filter]).find(:all, :include => {:person => :pedigree}, :order => ['pedigrees.name'])
    if params[:vendor_id] then
      if params[:vendor_id].match(/%/) then
        @samples = Sample.has_pedigree(params[:pedigree_filter]).where("vendor_id like ?", params[:vendor_id]).find(:all, :include => {:person => :pedigree}, :order => ['pedigrees.name'])
      else
        @samples = Sample.has_pedigree(params[:pedigree_filter]).where("vendor_id = ?", params[:vendor_id]).find(:all, :include => {:person => :pedigree}, :order => ['pedigrees.name'])
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @samples }
      format.js
    end
  end

  # GET /samples/1
  # GET /samples/1.xml
  def show
    @sample = Sample.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sample }
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


    respond_to do |format|
      if @sample.save
         isb_sample_id = "isb_sample_#{@sample.id}"
         @sample.isb_sample_id = isb_sample_id
         @sample.save

         #create acquisition
         acquisition = Acquisition.new
         acquisition.person_id = params[:person][:id]
         acquisition.sample_id = @sample.id
         acquisition.save

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

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        logger.debug("sample is #{@sample.inspect} after params #{params[:sample]}")
        format.html { redirect_to(@sample, :notice => 'Sample was successfully updated.') }
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
