require 'download_zip'
require 'madeline_utils'
require 'pedigree_info'
require 'utils'
require 'csv'

class PedigreesController < ApplicationController
  unloadable
  respond_to :json
  caches_page :all_pedigrees
  
  # GET /pedigrees
  # GET /pedigrees.xml
  def index
    @pedigrees = Pedigree.find(:all, :include => :study, :order => ['studies.name', 'pedigrees.name'])
    if params[:name] or  params[:pedigree_name] then
      @pedigrees = Pedigree.where(:name => [params[:name] , params[:pedigree_name]] ).paginate :page => params[:page], :per_page => 100
    elsif params[:id]
      @pedigrees = Pedigree.where("pedigrees.id = ? or pedigrees.isb_pedigree_id = ?", 
                                  params[:id],params[:id]).paginate :page => params[:page], :per_page => 100
    else
      respond_to do |format|
        format.html {
          @pedigrees = Pedigree.find(:all, :include => :study, 
                                     :order => ['studies.name', 'pedigrees.name'])
        }
        format.any{
          @pedigrees = Pedigree.find(:all, :include => :study, 
                                     :order => ['pedigrees.id'])
        }
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pedigrees }
      format.json { respond_with @pedigrees }
    end
  end
  
  # GET /pedigrees/1
  # GET /pedigrees/1.xml
  def show
    @pedigree = Pedigree.find(params[:id])
    @person_relationships = Relationship.order(:person_id).order(:relation_order).display_filter.find_all_by_person_id(@pedigree.people.map(&:id))

#    @person_relationships = Relationship.order(:person_id).find_all_by_person_id(@pedigree.people.map(&:id))
#    @relation_relationships = Relationship.find_all_by_relation_id(@pedigree.people.map(&:id))
#    @relationships = @person_relationships + @relation_relationships

    unless @pedigree.tag.match(/unrelateds/) or @pedigree.tag == 'diversity_P1' or @pedigree.people.size <= 2 or @pedigree.relationship_count < 2 then
      madeline_file = madeline_image(@pedigree)
      if File.exists?(madeline_file) then
        @madeline = File.read(madeline_file)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pedigree }
      format.json  { respond_with @pedigree }
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
    @pedigree = Pedigree.new(pedigree_params)

    @pedigree.version = 1
    respond_to do |format|
      if @pedigree.save then
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
      if @pedigree.update_attributes(pedigree_params)
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
    @pedigree = Pedigree.find(params[:pedigree_id])
    peddir_exists
    output_file = PEDFILES_DIR + pedigree_output_filename(@pedigree)
    ped_hash = pedfile(params[:pedigree_id])
    parent_rels = pedigree_relationships(params[:pedigree_id])
    ped_hash["relationships"] = parent_rels
    json_pedigree = JSON.pretty_generate(ped_hash)
    File.open(output_file, 'w') do |f|
      f.puts json_pedigree
    end

    respond_to do |format|
      format.html { send_data(File.read(output_file), :filename => "#{@pedigree.tag}.ped", :type => 'application/json') }
      format.json { send_data(File.read(output_file), :filename => pedigree_output_filename(@pedigree), :type => 'application/json') }
    end
  end

  def all_pedigree_files
    peddir_exists
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

    respond_to do |format|
      format.html { 
        # add the data_store to the zip file
        data_store = pedindex('FILE','TAG')
        data_store_name = PEDIGREE_DATA_STORE # from config/environment.rb
        data_store_loc = PEDFILES_DIR + data_store_name
        ped_file_list[data_store_name] = data_store_loc
        json_index = JSON.pretty_generate(data_store)
        File.open(data_store_loc, 'w') do |f|
          f.puts json_index
        end

        download_zip("pedigrees.zip",ped_file_list) 
      }
      format.json { 
        contents = Array.new
	ped_file_list.each do |file, file_loc|
	  contents.push(File.read(file_loc))
	end
	send_data(contents.join(","), :filename => "all_peds", :type => 'application/json') 
      }
    end

  end
 
  def all_pedigrees
    @ped_list = Hash.new
    Pedigree.all.each do |ped|
      ped_info =pedfile(ped.id)
      rels = pedigree_relationships(ped.id)
      ped_info["relationships"] = rels
      json_ped = JSON.pretty_generate(ped_info)
      @ped_list[ped.id] = json_ped
    end

    respond_to do |format|
    	format.html 
	format.json {
		render :json => @ped_list
	}
    end
  end

  

  def pedigree_datastore
    peddir_exists

    if params[:type] and params[:type].match('REST') then
      data_store = pedindex('REST','ID')
    else
      data_store = pedindex('FILE','TAG')
    end

    json_index = JSON.pretty_generate(data_store)
    respond_to do |format|
      format.html {
        send_data(json_index, :filename => "index", :type => "applicaton/json")
      }
      format.json {
        send_data(json_index, :filename => "index", :type => "applicaton/json")
      }
    end
  end

  def madeline_image(pedigree)
      peddir_exists
      maddir_exists
      # the combination of pedigree name and pedigree id should be unique
      madeline_name = madeline_file(pedigree)
      madeline_file = MADELINE_DIR + "#{madeline_name}"

      ordered_ped = ordered_pedigree(pedigree.id)
      madeline_array = to_madeline(pedigree,ordered_ped)
      @filename = madeline_file

      labels = Array.new
      labels.push("IndividualID")
      labels << pedigree.diseases.map{|d| d.name.gsub!(/ /, '_')}
      labels << pedigree.phenotypes.map{|p| p.name.gsub!(/ /,'_')}

      madeline_info = Array.new
      madeline_array.each do |line|
        line = line.join("\t")
        madeline_info.push(line)
      end

      infile = Tempfile.new('madeline_input')
      header = madeline_header(pedigree)
      infile.print(header)
      infile.print("\n")
      infile.print(madeline_info.join("\n"))
      infile.flush
      infile.close
      FileUtils.copy(infile.path, "/tmp/blah.txt")

      madeline_table = array_to_html_table(header.split(/\t/), madeline_array)
      madeline_table.gsub!(/table/, "table border=\"1\" cellspacing=\"0\"") #dunno how to get XMLBuilder to return a border
      # we want to regenerate the file every time because something may have changed.
      begin
        tmpfile, warnings = Madeline::Interface.new(:embedded => true, :L => labels, "font-size"=> "10", "nolabeltruncation" => true, "sort" => "SortOrder").draw(File.open(infile,'r'))
      rescue Exception => e
	msg = e.message.gsub(/\e\[(\d+)m/, '')
	msg.gsub!(/\n/, '<br />')
	msg.gsub!(/[^0-9A-Za-z \/<>-]/, '')
	msg.gsub!(/131m/,'')
        flash[:error] = "#{msg}" 
      else
        FileUtils.copy(tmpfile,madeline_file)
      end

      return madeline_file
  end

  def export_madeline_table
    @pedigree = Pedigree.find(params[:pedigree_id])
    ordered_ped = ordered_pedigree(@pedigree.id)
    madeline_array = to_madeline(@pedigree,ordered_ped)
    header = madeline_header(@pedigree).split(/\t/)

    csvdir_exists
    csv_file_name = "#{CSVDIR}/#{@pedigree.tag}_madeline_table_#{Date.today.to_s}.csv"
    CSV.open(csv_file_name, "wb") do |csv|
      csv << header
      madeline_array.each do |row|
        csv << row
      end
    end
    
    respond_to do |format|
      format.html { download_zip("#{@pedigree.tag}_madeline_table.zip",{ "#{@pedigree.tag}_madeline_table.csv" => csv_file_name}) }
    end
  end

  def export_all_madeline_tables
    study = Study.find(params[:study])
    if (study.nil?) then
        @pedigrees = Pedigree.all
    else 
        @pedigrees = study.pedigrees
    end
    filenames = Hash.new
    @pedigrees.each do |pedigree|
      ordered_ped = ordered_pedigree(pedigree.id)
      madeline_array = to_madeline(pedigree,ordered_ped)
      header = madeline_header(pedigree).split(/\t/)

      csvdir_exists
      csv_file_name = "#{CSVDIR}/#{pedigree.tag}_madeline_table_#{Date.today.to_s}.csv"
      filenames["#{pedigree.tag}_madeline_table.csv"] = csv_file_name
      CSV.open(csv_file_name, "wb") do |csv|
        csv << header
        madeline_array.each do |row|
          csv << row
        end
      end
    end

    if (!study.nil?) then
      zip_name = "#{study.tag}_"
    else
      zip_name = "all"
    end
    zip_name = zip_name+"_madeline_table.zip"
    respond_to do |format|
      format.html { download_zip(zip_name,filenames) }
    end
  end

  # this outputs a PDF of Madeline drawings for every pedigree
  def export_madeline_pdf
    @pedigrees = Pedigree.all
    pdf_name = MADELINE_DIR + "pedigrees.pdf"
    @pedigrees.each do |pedigree|
      madeline_name = madeline_file(pedigree)
      madeline_file = MADELINE_DIR + "#{madeline_name}"
      madeline_file = madeline_image(pedigree) unless File.exists?(madeline_file)
       
    end

    respond_to do |format|
      format.pdf do 
        render :pdf => "#{pdf_name}", :stylesheets => ["application","prince"], :layout => "pdf"
      end
    end
  end

  # give a list of founder isb_person_ids
  def founders
    @founders = Hash.new
    if params[:id] || (params[:pedigree_filter] && !params[:pedigree_filter][:id].blank?) || params[:pedigree_id] then
      cur_ped_id = params[:pedigree_id] if params[:pedigree_id]
      cur_ped_id = params[:id] if params[:id]
      cur_ped_id = params[:pedigree_filter][:id] if params[:pedigree_filter]
      @pedigree = Pedigree.find(cur_ped_id)
      return nil if @pedigree.nil?
      @people = parentless_people(@pedigree.id)
      @people.each do |person|
        @founders[person.isb_person_id] = person
      end
    else
      Pedigree.all.each do |pedigree|
        ped_people = parentless_people(pedigree.id)
	ped_people.each do |person|
	  @founders[person.isb_person_id] = person
	end
      end
    end
    respond_to do |format|
      format.html # founders.html.erb
      format.json  { render :json => @founders }
    end
  end

  def kwanzaa
    @pedigree = Pedigree.find(params[:id])
    outfile_name = "Kwanzaa_"+@pedigree.tag # needs a quartet identifier somehow
    # genotype.csv outfilename outfile path
    rc = `lib/genomeMapVariable.pl KWANZAA_DIR`
  end

  private
  def pedigree_params
    params.require(:pedigree).permit(:name, :tag, :study_id, :directory, :description, :version, :genotype_vector_date, :quartet_date, :autozygosity_date, :relation_pairing_date)
  end

end



