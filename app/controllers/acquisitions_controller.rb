class AcquisitionsController < ApplicationController
  # GET /acquisitions
  # GET /acquisitions.xml
  def index
    @acquisitions = Acquisition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @acquisitions }
    end
  end

  # GET /acquisitions/1
  # GET /acquisitions/1.xml
  def show
    @acquisition = Acquisition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @acquisition }
    end
  end

  # GET /acquisitions/new
  # GET /acquisitions/new.xml
  def new
    @acquisition = Acquisition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acquisition }
    end
  end

  # GET /acquisitions/1/edit
  def edit
    @acquisition = Acquisition.find(params[:id])
  end

  # POST /acquisitions
  # POST /acquisitions.xml
  def create
    @acquisition = Acquisition.new(params[:acquisition])

    respond_to do |format|
      if @acquisition.save
        format.html { redirect_to(@acquisition, :notice => 'Acquisition was successfully created.') }
        format.xml  { render :xml => @acquisition, :status => :created, :location => @acquisition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @acquisition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /acquisitions/1
  # PUT /acquisitions/1.xml
  def update
    @acquisition = Acquisition.find(params[:id])

    respond_to do |format|
      if @acquisition.update_attributes(params[:acquisition])
        format.html { redirect_to(@acquisition, :notice => 'Acquisition was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @acquisition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /acquisitions/1
  # DELETE /acquisitions/1.xml
  def destroy
    @acquisition = Acquisition.find(params[:id])
    @acquisition.destroy

    respond_to do |format|
      format.html { redirect_to(acquisitions_url) }
      format.xml  { head :ok }
    end
  end
end
