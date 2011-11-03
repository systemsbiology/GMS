class RelationshipsController < ApplicationController
  # GET /relationships
  # GET /relationships.xml
  def index
    @relationships = Relationship.has_pedigree(params[:pedigree_filter]).order_by_pedigree

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @relationships }
      format.js
    end
  end

  # GET /relationships/1
  # GET /relationships/1.xml
  def show
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @relationship }
    end
  end

  # GET /relationships/new
  # GET /relationships/new.xml
  def new
    @relationship = Relationship.new
    # this is related to the filtering that is included at the bottom of the new form
    # and is a duplicate of the index code.  Should probably be refactored into one method
    @relationships = Relationship.has_pedigree(params[:pedigree_filter]).order_by_pedigree


    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @relationship }
      format.js
    end
  end

  # GET /relationships/1/edit
  def edit
    @relationship = Relationship.find(params[:id])
  end

  # POST /relationships
  # POST /relationships.xml
  def create
    @relationship = Relationship.new(params[:relationship])

    if @relationship.person_id == @relationship.relation_id then
      @relationship.errors[:base] << "Cannot add a relationship between the same person"
    end

    if @relationship.person.pedigree != @relationship.relation.pedigree then
      @relationship.errors[:base] << "Cannot create a relationship link between two pedigrees."
    end

    @relationship.relationship_type = @relationship.lookup_relationship_type

    if !@relationship.correct_gender? then
      @relationship.errors[:base] << "Wrong relationship selected.  "+
        "Person #{@relationship.person.identifier} is wrong gender *#{@relationship.person.gender}* for relationship - #{@relationship.name}-   "+
        "  AND/OR relation #{@relationship.relation.identifier} is wrong gender *#{@relationship.relation.gender}* to be target of relationship - #{@relationship.name}"

    end


      if !params[:status].nil? then
        if !params[:status][:divorced].nil? then
          if params[:status][:divorced] == "1" then
	    @relationship.divorced = 1
          end
        end
      end

      check_rel = Relationship.find_by_person_id_and_relation_id_and_relationship_type_and_name(@relationship.person_id, @relationship.relation_id, @relationship.relationship_type, @relationship.name)
      if !check_rel.nil? then
         @relationship.errors[:base] << "An identical relationship between these two people is already in the database."
      end

      if @relationship.is_undirected? then
        @reciprocal = Relationship.new
        @reciprocal.person_id = @relationship.relation_id
        @reciprocal.relation_id = @relationship.person_id
        @reciprocal.relationship_type = @relationship.relationship_type
        @reciprocal.name = @relationship.reverse_name
        @reciprocal.divorced = @relationship.divorced

        if @reciprocal.name.nil? then
          logger.debug("Settings relationship_reverse does not include #{@relationship.name}, please add it before adding this relationship")
          @relationship.errors[:base] << "Settings relationship_reverse does not include #{@relationship.name}, please add it before adding this relationship"
          render :action => "new"
        end

      elsif @relationship.is_directed? then  # finds 'parent' and 'child' relationship_types
        @reciprocal = Relationship.new
        @reciprocal.person_id = @relationship.relation_id
        @reciprocal.relation_id = @relationship.person_id
        @reciprocal.name = @relationship.reverse_name
        @reciprocal.relationship_type = @reciprocal.lookup_relationship_type


      else
        logger.debug("Error with relationship creation: relationship is not directed or undirected #{@relationship}")
      end


    respond_to do |format|
      if @relationship.errors[:base].size > 0 then
        format.html { render :action => "new" }
	format.xml {render :xml => @relationship.errors, :status => :unprocessable_entity }
      else

        if @relationship.save
          check_recip = Relationship.find_by_person_id_and_relation_id_and_relationship_type_and_name(@reciprocal.person_id, @reciprocal.relation_id, @reciprocal.relationship_type, @reciprocal.name)
          if check_recip.nil? then
            @reciprocal.save
            format.html { redirect_to(@relationship, :notice => 'Relationship and reciprocal successfully created.') }
	  else
            format.html { redirect_to(@relationship, :notice => 'Relationship was successfully created.') }
          end

          format.xml  { render :xml => @relationship, :status => :created, :location => @relationship }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /relationships/1
  # PUT /relationships/1.xml
  def update
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      if @relationship.update_attributes(params[:relationship])
        format.html { redirect_to(@relationship, :notice => 'Relationship was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.xml
  def destroy
    @relationship = Relationship.find(params[:id])
    @relationship.destroy

    respond_to do |format|
      format.html { redirect_to(relationships_url) }
      format.xml  { head :ok }
    end
  end
end
