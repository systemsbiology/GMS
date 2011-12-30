class AssaysController < ApplicationController
  # GET /assays
  # GET /assays.xml
  def index
    @assays = Assay.has_pedigree(params[:pedigree_filter]).has_name(params[:assay_name])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assays }
      format.js
      format.json { render :json => @assays.first }  # should this assume first?  could be a bug someday..
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
    
    logger.debug("adding an assay with params #{params.inspect}")
    respond_to do |format|
      ActiveRecord::Base.transaction do 
        notice = ''
#  it may be better to create the sample association via this way rather than dealing directly with SampleAssay
#        sample = Sample.find(params[:sample][:sample_id])
#        @assay.samples << sample
        if @assay.save
          notice << 'Assay was successfully created.'
          # create a link between the sample passed in and this assay that was createda
          if params[:sample] then
	    sa = SampleAssay.new(params[:sample])
	    sa.assay_id = @assay.id
	    if sa.save
              notice << 'Assay and Sample <=> Assay link was successfully created.'
	      @assay.status = "created"
              @assay.save
              format.html { redirect_to(@assay, :notice => notice) }
              format.xml  { render :xml => @assay, :status => :created, :location => @assay }
              format.json  { render :json => @assay, :status => :created, :location => @assay }
	    else
	      notice << "Could not save sample <=> assay link.  Operation aborted."
              format.html { render :action => "new" }
	      format.xml { render :xml => @assay.errors, :status => :unprocessable_entity }
	      format.json { render :json => @assay.errors, :action =>"new" }
	      raise ActiveRecord::Rollback
	      return
	    end
  	  end
        else
          logger.debug("assay wasn't valid!!")
          format.html { render :action => "new" }
          format.xml  { render :xml => @assay.errors, :status => :unprocessable_entity }
  	  format.json { render :json => @assay.errors } 
        end
      end
      logger.debug("end of create method")
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
