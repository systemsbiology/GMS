class GenomeReferencesController < ApplicationController
  # GET /genome_references
  # GET /genome_references.xml
  def index
    @genome_references = GenomeReference.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @genome_references }
    end
  end

  # GET /genome_references/1
  # GET /genome_references/1.xml
  def show
    @genome_reference = GenomeReference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @genome_reference }
    end
  end

  # GET /genome_references/new
  # GET /genome_references/new.xml
  def new
    @genome_reference = GenomeReference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @genome_reference }
    end
  end

  # GET /genome_references/1/edit
  def edit
    @genome_reference = GenomeReference.find(params[:id])
  end

  # POST /genome_references
  # POST /genome_references.xml
  def create
    @genome_reference = GenomeReference.new(genome_reference_params)

    respond_to do |format|
      if @genome_reference.save
        format.html { redirect_to(@genome_reference, :notice => 'GenomeReference was successfully created.') }
        format.xml  { render :xml => @genome_reference, :status => :created, :location => @genome_reference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @genome_reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /genome_references/1
  # PUT /genome_references/1.xml
  def update
    @genome_reference = GenomeReference.find(params[:id])

    respond_to do |format|
      if @genome_reference.update_attributes(genome_reference_params)
        format.html { redirect_to(@genome_reference, :notice => 'GenomeReference was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @genome_reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /genome_references/1
  # DELETE /genome_references/1.xml
  def destroy
    @genome_reference = GenomeReference.find(params[:id])
    @genome_reference.destroy

    respond_to do |format|
      format.html { redirect_to(genome_references_url) }
      format.xml  { head :ok }
    end
  end

  private
  def genome_reference_params
    params.require(:genome_reference).permit(:name, :build_name, :description, :code, :location)
  end
end
