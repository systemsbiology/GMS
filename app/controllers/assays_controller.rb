class AssaysController < ApplicationController
  respond_to :json
  # GET /assays
  # GET /assays.xml
  def index
    if params[:name] then
      @assays = Assay.has_pedigree(params[:pedigree_filter]).where(:name => params[:name]).paginate :page => params[:page], :per_page => 100
    elsif params[:assay_name] then
      @assays = Assay.has_pedigree(params[:pedigree_filter]).where(:name => params[:assay_name]).paginate :page => params[:page], :per_page => 100
    elsif params[:id]
      @assays = Assay.has_pedigree(params[:pedigree_filter]).where("assays.id = ?", params[:id]).paginate :page => params[:page], :per_page => 100
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assays }
      format.json { respond_with @assays } 
      format.js
    end
  end

  # GET /assays/1
  # GET /assays/1.xml
  def show
    @assay = Assay.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assay }
    end
  end

  # GET /assays/new
  # GET /assays/new.xml
  def new
    @assay = Assay.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assay }
    end
  end

  # GET /assays/1/edit
  def edit
    @assay = Assay.find(params[:id])
  end

  # POST /assays
  # POST /assays.xml
  def create
    @assay = Assay.new(params[:assay])
    @assay.status = "created"
    if (params[:sample] and params[:sample][:sample_id]) then
      sample = Sample.find(params[:sample][:sample_id])
      @assay.sample = sample
    end
   
    respond_to do |format|
      if @assay.save
        format.html { redirect_to(@assay, :notice => notice) }
        format.xml  { render :xml => @assay, :status => :created, :location => @assay }
        format.json  { render :json => @assay.to_json, :status => :created, :location => @assay }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assay.errors, :status => :unprocessable_entity }
        format.json { render :json => @assay.errors } 
      end
    end
  end

  # PUT /assays/1
  # PUT /assays/1.xml
  def update
    @assay = Assay.find(params[:id])

    respond_to do |format|
      if @assay.update_attributes(params[:assay])
        format.html { redirect_to(@assay, :notice => 'Assay was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assay.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assays/1
  # DELETE /assays/1.xml
  def destroy
    @assay = Assay.find(params[:id])
    @assay.destroy

    respond_to do |format|
      format.html { redirect_to(assays_url) }
      format.xml  { head :ok }
    end
  end

  def summary_report
    @counts = Assay.include_pedigree.has_reference(params[:reference], 'ASSEMBLY').group('pedigrees.id').count
    @pedigrees = Pedigree.order("name")


  end
end
