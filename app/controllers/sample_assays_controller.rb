class SampleAssaysController < ApplicationController
  # GET /sample_assays
  # GET /sample_assays.xml
  def index
    @sample_assays = SampleAssay.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sample_assays }
    end
  end

  # GET /sample_assays/1
  # GET /sample_assays/1.xml
  def show
    @sample_assay = SampleAssay.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sample_assay }
    end
  end

  # GET /sample_assays/new
  # GET /sample_assays/new.xml
  def new
    @sample_assay = SampleAssay.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sample_assay }
    end
  end

  # GET /sample_assays/1/edit
  def edit
    @sample_assay = SampleAssay.find(params[:id])
  end

  # POST /sample_assays
  # POST /sample_assays.xml
  def create
    @sample_assay = SampleAssay.new(params[:sample_assay])

    respond_to do |format|
      if @sample_assay.save
        format.html { redirect_to(@sample_assay, :notice => 'Sample assay was successfully created.') }
        format.xml  { render :xml => @sample_assay, :status => :created, :location => @sample_assay }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sample_assay.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sample_assays/1
  # PUT /sample_assays/1.xml
  def update
    @sample_assay = SampleAssay.find(params[:id])

    respond_to do |format|
      if @sample_assay.update_attributes(params[:sample_assay])
        format.html { redirect_to(@sample_assay, :notice => 'Sample assay was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sample_assay.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sample_assays/1
  # DELETE /sample_assays/1.xml
  def destroy
    @sample_assay = SampleAssay.find(params[:id])
    @sample_assay.destroy

    respond_to do |format|
      format.html { redirect_to(sample_assays_url) }
      format.xml  { head :ok }
    end
  end
end
