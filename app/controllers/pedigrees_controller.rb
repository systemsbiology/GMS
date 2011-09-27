class PedigreesController < ApplicationController
  unloadable

  # GET /pedigrees
  # GET /pedigrees.xml
  def index
    @pedigrees = Pedigree.find(:all, :include => :study, :order => ['studies.name', 'pedigrees.name'])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pedigrees }
      format.json { render :json => @pedigrees }
    end
  end

  # GET /pedigrees/1
  # GET /pedigrees/1.xml
  def show
    @pedigree = Pedigree.find(params[:id])
    @people = Pedigree.find(params[:id]).people
    ped_info = Array.new()
    rels = Array.new()
    @people.each do |p|
      ped_info.push(p.isb_person_id)
      rels.push(p.relationships)
    end
    logger.debug("rels is #{rels.inspect}")
    logger.debug("ped_info is #{ped_info}")

    # the combination of pedigree name and pedigree id should be unique
    madeline_name = "madeline_#{@pedigree.name}_#{@pedigree.id}.xml"
    madeline_file = MADELINE_DIR + "#{madeline_name}"

    @rels = rels
    #@to_mad = to_madeline(rels)
    @filename = madeline_file
    if (!File.exists?(madeline_file)) then
      tmpfile, warnings = Madeline::Interface.new(:embedded => true, :L => "CM").draw(File.open("/u5/www/dev_sites/dmauldin/gms/public/madeline_adamsO_79083.txt","r"))
      FileUtils.copy(tmpfile,madeline_file)
    end

    @madeline = File.read(madeline_file) if @people.size > 0


    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pedigree }
      format.json  { render :json => @pedigree }
    end
  end

  # GET /pedigrees/new
  # GET /pedigrees/new.xml
  def new
    @pedigree = Pedigree.new
    if (params[:study]) 
      @pedigree.study_id = params[:study]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pedigree }
    end
  end

  # GET /pedigrees/1/edit
  def edit
    @pedigree = Pedigree.find(params[:id])
    @studies = Study.all
  end

  # POST /pedigrees
  # POST /pedigrees.xml
  def create
    @pedigree = Pedigree.new(params[:pedigree])

    respond_to do |format|
      if @pedigree.save
        format.html { redirect_to(@pedigree, :notice => 'Pedigree was successfully created.') }
        format.xml  { render :xml => @pedigree, :status => :created, :location => @pedigree }
        format.json  { render :json => @pedigree, :status => :created, :location => @pedigree }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pedigree.errors, :status => :unprocessable_entity }
        format.json  { render :json => @pedigree.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pedigrees/1
  # PUT /pedigrees/1.xml
  def update
    @pedigree = Pedigree.find(params[:id])

    respond_to do |format|
      if @pedigree.update_attributes(params[:pedigree])
        format.html { redirect_to(@pedigree, :notice => 'Pedigree was successfully updated.') }
        format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pedigree.errors, :status => :unprocessable_entity }
        format.json  { render :json => @pedigree.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pedigrees/1
  # DELETE /pedigrees/1.xml
  def destroy
    @pedigree = Pedigree.find(params[:id])
    @pedigree.destroy

    respond_to do |format|
      format.html { redirect_to(pedigrees_url) }
      format.xml  { head :ok }
      format.json  { head :ok }
    end
  end
end
