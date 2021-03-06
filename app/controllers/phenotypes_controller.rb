class PhenotypesController < ApplicationController
  # GET /phenotypes
  # GET /phenotypes.xml
  def index
    @phenotypes = Phenotype.order('madeline_display DESC, name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phenotypes }
    end
  end

  # GET /phenotypes/1
  # GET /phenotypes/1.xml
  def show
    @phenotype = Phenotype.find(params[:id])
	logger.debug("hpnoetype madleine {#@phenotype.inspect} #{@phenotype.madeline_display.inspect} #{I18n.t @phenotype.madeline_display}")
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phenotype }
    end
  end

  # GET /phenotypes/new
  # GET /phenotypes/new.xml
  def new
    @phenotype = Phenotype.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phenotype }
    end
  end

  # GET /phenotypes/1/edit
  def edit
    @phenotype = Phenotype.find(params[:id])
  end

  # POST /phenotypes
  # POST /phenotypes.xml
  def create
    @phenotype = Phenotype.new(phenotype_params)

    respond_to do |format|
      if @phenotype.save
        format.html { redirect_to(@phenotype, :notice => 'Phenotype was successfully created.') }
        format.xml  { render :xml => @phenotype, :status => :created, :location => @phenotype }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phenotype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phenotypes/1
  # PUT /phenotypes/1.xml
  def update
    @phenotype = Phenotype.find(params[:id])

    respond_to do |format|
      if @phenotype.update_attributes(phenotype_params)
        format.html { redirect_to(@phenotype, :notice => 'Phenotype was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phenotype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phenotypes/1
  # DELETE /phenotypes/1.xml
  def destroy
    @phenotype = Phenotype.find(params[:id])
    @phenotype.destroy

    respond_to do |format|
      format.html { redirect_to(phenotypes_url) }
      format.xml  { head :ok }
    end
  end

  private
  def phenotype_params
    params.require(:phenotype).permit(:condition_id, :name, :tag, :phenotype_type, :madeline_display, :description)
  end
end
