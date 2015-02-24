class TraitsController < ApplicationController
  # GET /traits
  # GET /traits.xml
  def index
    @traits = Trait.has_pedigree(params[:pedigree_filter]).has_person(params[:person]).paginate :page => params[:page], :per_page => 100

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @traits }
      format.js
    end
  end

  # GET /traits/1
  # GET /traits/1.xml
  def show
    @trait = Trait.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trait }
    end
  end

  # GET /traits/new
  # GET /traits/new.xml
  def new
    @trait = Trait.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trait }
    end
  end

  # GET /traits/1/edit
  def edit
    @trait = Trait.find(params[:id])
  end

  # POST /traits
  # POST /traits.xml
  def create
    @trait = Trait.new(trait_params)

    respond_to do |format|
      if @trait.save
        format.html { redirect_to(@trait, :notice => 'Trait was successfully created.') }
        format.xml  { render :xml => @trait, :status => :created, :location => @trait }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /traits/1
  # PUT /traits/1.xml
  def update
    @trait = Trait.find(params[:id])

    respond_to do |format|
      if @trait.update_attributes(trait_params)
        format.html { redirect_to(@trait, :notice => 'Trait was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /traits/1
  # DELETE /traits/1.xml
  def destroy
    @trait = Trait.find(params[:id])
    @trait.destroy

    respond_to do |format|
      format.html { redirect_to(traits_url) }
      format.xml  { head :ok }
    end
  end

  private
  def trait_params
    params.require(:trait).permit(:person_id, :phenotype_id, :trait_information, :output_order)
  end
end
