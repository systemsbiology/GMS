class PersonAliasesController < ApplicationController
  # GET /person_aliases
  # GET /person_aliases.xml
  def index
    @person_aliases = PersonAlias.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @person_aliases }
    end
  end

  # GET /person_aliases/1
  # GET /person_aliases/1.xml
  def show
    @person_alias = PersonAlias.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person_alias }
    end
  end

  # GET /person_aliases/new
  # GET /person_aliases/new.xml
  def new
    @person_alias = PersonAlias.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person_alias }
    end
  end

  # GET /person_aliases/1/edit
  def edit
    @person_alias = PersonAlias.find(params[:id])
  end

  # POST /person_aliases
  # POST /person_aliases.xml
  def create
    @person_alias = PersonAlias.new(person_alias_params)

    respond_to do |format|
      if @person_alias.save
        format.html { redirect_to(@person_alias, :notice => 'Person alias was successfully created.') }
        format.xml  { render :xml => @person_alias, :status => :created, :location => @person_alias }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person_alias.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /person_aliases/1
  # PUT /person_aliases/1.xml
  def update
    @person_alias = PersonAlias.find(params[:id])

    respond_to do |format|
      if @person_alias.update_attributes(person_alias_params)
        format.html { redirect_to(@person_alias, :notice => 'Person alias was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person_alias.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /person_aliases/1
  # DELETE /person_aliases/1.xml
  def destroy
    @person_alias = PersonAlias.find(params[:id])
    @person_alias.destroy

    respond_to do |format|
      format.html { redirect_to(person_aliases_url) }
      format.xml  { head :ok }
    end
  end

  private
  def person_alias_params
    params.require(:person_alias).permit(:person_id, :value, :alias_type)
  end
end
