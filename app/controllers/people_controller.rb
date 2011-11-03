class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    @people = Person.has_pedigree(params[:pedigree_filter])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
      format.js
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])

    if params[:gender] then
      if params[:gender] != 'unknown' then
        @person.gender = params[:gender]
      end
    end

    if params[:check_dates] then
      if params[:check_dates][:add_dob].to_i != 1 then
        @person.dob = nil
      end
      if params[:check_dates][:add_dod].to_i != 1 then
        @person.dod = nil
      end
    else
      @person.dob = nil
      @person.dod = nil
    end

    respond_to do |format|
      if @person.save
        isb_person_id = "isb_ind: #{@person.id}"
	@person.isb_person_id = isb_person_id
	@person.save

	# create memberships
	membership = Membership.new
	# this should be params[:pedigree][:id] because that's what the create form passes in
	membership.pedigree_id = params[:pedigree][:id]
        membership.person_id = @person.id
	membership.save

        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])

    @values = params[:person]
    if params[:check_dates] then
      if params[:check_dates][:add_dob].to_i != 1 then
        @values.delete_if{|k,v| k.match(/^dob/)}
      end
      if params[:check_dates][:add_dod].to_i != 1 then
        @values.delete_if{|k,v| k.match(/^dod/)}
      end
    else
      @values.delete_if{|k,v| k.match(/^dob/)}
      @values.delete_if{|k,v| k.match(/^dod/)}
    end

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end


  def receiving_report
    if params[:pedigree_filter] and params[:pedigree_filter][:id] != '' then
      @pedigree = Pedigree.find(params[:pedigree_filter][:id])
      @people = Person.find(:all, :include => [ {:samples =>  :assays }, :pedigree], :conditions => { 'pedigrees.id' => @pedigree.id, 'planning_on_sequencing' => 1 })
    else
      @pedigree = Pedigree.order(:name)
      @people = Person.find(:all, :include => [ {:samples =>  :assays }, :pedigree], :conditions => { 'planning_on_sequencing' => 1 }, :order => [ 'pedigrees.name','people.collaborator_id','samples.status'])
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @people }
      format.js
    end
  end

end
