class AcquisitionsController < ApplicationController
  respond_to :json

  # GET /acquisitions
  # GET /acquisitions.xml
  def index
    respond_to do |format|
      # find(:all, :include => { :person => :pedigree}, :order => ['pedigrees.tag'])
      format.html {
        @acquisitions = Acquisition.has_pedigree(params[:pedigree_filter]).includes(:person => :pedigree).order('pedigrees.tag')
                                   .paginate(:page => params[:page], :per_page => 100)
      }
      format.any {
        @acquisitions = Acquisition.has_pedigree(params[:pedigree_filter])
      }
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
    @pedigrees = Pedigree.order("pedigrees.tag")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acquisition }
    end
  end

  # GET /acquisitions/1/edit
  def edit
    @acquisition = Acquisition.find(params[:id])
    @pedigrees = Pedigree.order("pedigrees.tag")
  end

  # POST /acquisitions
  # POST /acquisitions.xml
  def create
    #@acquisition = Acquisition.new(params[:acquisition])
    @acquisition = Acquisition.new(acquisition_params)
    if params[:person] and params[:person][:id]
      @acquisition.person_id = params[:person][:id]
    end

    respond_to do |format|
      if @acquisition.save
        logger.debug("saving!")
        format.html { redirect_to(@acquisition, :notice => 'Acquisition was successfully created.') }
        format.xml  { render :xml => @acquisition, :status => :created, :location => @acquisition }
      else
        logger.debug("Not saving! #{@acquisition.inspect}")
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
      if @acquisition.update_attributes!(acquisition_params)
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

  private
  def acquisition_params
    params.require(:acquisition).permit(:sample_id, :person_id, :method)
  end

end
