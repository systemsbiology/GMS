require 'download_zip'

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
    @people = Person.has_pedigree(params[:id]).include_samples
    @person_relationships = Relationship.order(:person_id).find_all_by_person_id(@people.map(&:id))
    @relation_relationships = Relationship.find_all_by_relation_id(@people.map(&:id))
    @relationships = @person_relationships + @relation_relationships
    ped_info = Array.new()

    # the combination of pedigree name and pedigree id should be unique
    madeline_name = "madeline_#{@pedigree.name}_#{@pedigree.id}.xml"
    madeline_file = MADELINE_DIR + "#{madeline_name}"
    #logger.debug("looking for madeline file #{madeline_file}")

    #@to_mad = to_madeline(@relationships)
    @filename = madeline_file
    if (!File.exists?(madeline_file)) then
      if File.exists?("/u5/www/dev_sites/dmauldin/gms/public/madeline_adamsO_79083.txt") then
        tmpfile, warnings = Madeline::Interface.new(:embedded => true, :L => "CM").draw(File.open("/u5/www/dev_sites/dmauldin/gms/public/madeline_adamsO_79083.txt","r"))
      FileUtils.copy(tmpfile,madeline_file)
      else
        File
      end
    end

    if File.exists?(madeline_file) then
      @madeline = File.read(madeline_file) if @people.size > 0
    end

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
        isb_ped_id = "isb_ped: #{@pedigree.id}"
        @pedigree.isb_pedigree_id = isb_ped_id

	@pedigree.version = 1
	@pedigree.save

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

  # this prints out the JSON pedigree file
  def pedigree_file
    @pedigree = Pedigree.find(params[:id])
    output_file = PEDFILES_DIR + pedigree_output_filename(@pedigree)
    ped_hash = pedfile(params[:id])
    parent_rels = pedigree_relationships(params[:id])
    ped_hash["relationships"] = parent_rels
    json_pedigree = JSON.pretty_generate(ped_hash)
    File.open(output_file, 'w') do |f|
      f.puts json_pedigree
    end

    respond_to do |format|
      format.html { send_data(File.read(output_file), :filename => "#{@pedigree.tag}.ped", :type => 'application/json') }
      format.json { end_data(File.read(output_file), :filename => output_file, :type => 'application/json') }
    end
  end

  def all_pedigree_files
    @pedigrees = Pedigree.all
    ped_file_list = Hash.new
    @pedigrees.each do |ped|
      file_name = pedigree_output_filename(ped)
      output_file = PEDFILES_DIR + file_name
      ped_file_list[file_name] = output_file
      ped_hash = pedfile(ped.id)
      parent_rels = pedigree_relationships(ped.id)
      ped_hash["relationships"] = parent_rels
      json_pedigree = JSON.pretty_generate(ped_hash)
      File.open(output_file, 'w') do |f|
        f.puts json_pedigree
      end
    end

    data_store = pedindex
    data_store_name = PEDIGREE_DATA_STORE # from config/environment.rb
    data_store_loc = PEDFILES_DIR + data_store_name
    ped_file_list[data_store_name] = data_store_loc
    json_index = JSON.pretty_generate(data_store)
    File.open(data_store_loc, 'w') do |f|
      f.puts json_index
    end

    respond_to do |format|
      format.html { download_zip("pedigrees.zip",ped_file_list) }
    end

  end
end
