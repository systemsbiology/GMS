class AssaysController < ApplicationController
  # GET /assays
  # GET /assays.xml
  def index
    @assays = Assay.has_pedigree(params[:pedigree_filter])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assays }
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

    respond_to do |format|
      if @assay.save
        notice = 'Assay was successfully created.'
        # create a link between the sample passed in and this assay that was createda
        if params[:sample] then
	  sa = SampleAssay.new(params[:sample])
	  sa.assay_id = @assay.id
	  if sa.save
            notice = 'Assay and Sample <=> Assay link was successfully created.'
	  else
	    logger.debug("could not save sampleassay #{sa.errors.inspect}")
	    notice = "Assay saved, but could not save sample <=> assay link."
	  end
	end
        format.html { redirect_to(@assay, :notice => notice) }
        format.xml  { render :xml => @assay, :status => :created, :location => @assay }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assay.errors, :status => :unprocessable_entity }
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
    @counts = Assay.include_pedigree.group('pedigrees.id').has_reference(params[:reference], 'ASSEMBLY').count
    @pedigrees = Pedigree.order("name")


  end
end
