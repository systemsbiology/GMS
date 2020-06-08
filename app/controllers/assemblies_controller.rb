require 'utils'

class AssembliesController < ApplicationController
#  load_and_authorize_resource
  respond_to :json
  # GET /assembly
  # GET /assembly.xml
  def index
#    @assembly = find_all_by_pedigree_id(params[:pedigree_filter][:id]) if (params[:pedigree_filter])
    #    @assembly = @assembly.find(:all, :include => { :assay => { :sample => { :person => :pedigree } } },
    #                                        :conditions => [ 'pedigrees.id = ?', params[:pedigree_filter][:id] ]) if (params[:pedigree_filter])

    @assemblies = Assembly.has_pedigree(params[:pedigree_filter])
      .paginate :page => params[:page], :per_page => 100
    if params[:name] or params[:assembly_name] then
      @assemblies = Assembly.where(:name => [params[:name] , params[:assembly_name]] )
        .paginate :page => params[:page], :per_page => 100
    elsif params[:id]
      idNum=params[:id].gsub(/isb_asm_/,"")
      @assemblies = Assembly.where("assemblies.id = ?",
                                   idNum)
        .paginate :page => params[:page], :per_page => 100
    else
      respond_to do |format|
        format.html {# show.html.erb
          @assemblies = Assembly.has_pedigree(params[:pedigree_filter])
            .order('assemblies.name')
            .paginate :page => params[:page], :per_page => 100
        }
        format.any  {
          @assemblies = Assembly.has_pedigree(params[:pedigree_filter])
            .order('assemblies.id')
        }
      end
    end
  end

  def retrieve_circos
    assembly = Assembly.find(params[:assembly_id])
    # check for a circos-<assembly>.html file
    circos = assembly.location+'/REPORTS/circos-'+assembly.name+'.png'
    if File.exists?(circos) then
        File.open(circos, 'rb') do |f|
            send_data f.read, :type => "image/png", :disposition => "inline"
			return
        end
    end
    render :nothing => true
  end

  def retrieve_circos_legend
    assembly = Assembly.find(params[:assembly_id])
    # check for a circos-<assembly>.html file
    circos = assembly.location+'/REPORTS/circosLegend.png'
    if File.exists?(circos) then
        File.open(circos, 'rb') do |f|
            send_data f.read, :type => "image/png", :disposition => "inline"
			return
        end
    end
    render :nothing => true
  end

  # GET /assembly/1
  def show
    @assembly = Assembly.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assembly }
      format.json  { render :json => @assembly }
    end
  end

  # GET /assembly/new
  # GET /assembly/new.xml
  def new
    @assembly = Assembly.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assembly }
      format.json  { render :json => @assembly }
    end
  end

  # GET /assembly/1/edit
  def edit
    @assembly = Assembly.find(params[:id])
  end

  # POST /assembly
  # POST /assembly.xml
  def create
    @assembly = Assembly.new(assembly_params)
    @assembly.current = 1  # new assemblies should automatically be current
    dir = params[:assembly][:location]
    if File.exists?(dir) then
      @assembly.file_date = creation_time(dir)
    end
    if (params[:genome_reference]) then
      gr = GenomeReference.find_by_name(params[:genome_reference])
      @assembly.genome_reference = gr
    end
    @assembly.status = 'created'
    respond_to do |format|
        if @assembly.save
          format.html { redirect_to(@assembly, :notice => 'Assembly file was successfully created.') }
          format.xml  { render :xml => @assembly, :status => :created, :location => @assembly }
          format.json  { render :json => @assembly, :status => :created, :location => @assembly }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @assembly.errors, :status => :unprocessable_entity }
          format.json  { render :json => @assembly.errors, :status => :unprocessable_entity }
        end
    end
  end

  # PUT /assembly/1
  # PUT /assembly/1.xml
  def update
    @assembly = Assembly.find(params[:id])

    respond_to do |format|
      if @assembly.update_attributes(assembly_params)
        format.html { redirect_to(@assembly, :notice => 'Assembly file was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assembly.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assembly/1
  # DELETE /assembly/1.xml
  def destroy
    @assembly = Assembly.find(params[:id])
    @assembly.destroy

    respond_to do |format|
      format.html { redirect_to(assembly_url) }
      format.xml  { head :ok }
    end
  end


  #HELPER METHODS

  def find_all_by_pedigree_id(pedigree_id)
    @assembly = Assembly.includes(assay: { sample: { person: :pedigree } })
                        .where('pedigrees.id = ?', pedigree_id)
  end

  def ensure_files_up_to_date
    @assemblies = Array.new
    if params[:assembly_id] then
      @assemblies.push(Assembly.find(params[:assembly_id]))
    else
      @assemblies = Assembly.all
    end

    @assemblies.each do |assembly|
      @errors = assembly.ensure_files_up_to_date
    end

    expire_action(:controller => '/assembly_files', :action => :ped_info, :format => 'json')

    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end

  def ped_info
    ped_info = Hash.new
    Assembly.all.each do |af|
      ped = af.pedigree
      logger.error("Assembly #{af.inspect} doesn't have a pedigree??") if ped.nil?
      next if ped.nil?
      ped_info[af.name] = ped.isb_pedigree_id
      ped_info[af.isb_assembly_id] = ped.isb_pedigree_id
    end

    respond_to do |format|
      format.html
      format.xml {head :ok}
      format.json { render :json => ped_info }
    end
  end

  private
  def assembly_params
    params.require(:assembly).permit(:genome_reference_id, :assay_id, :name, :description, :location, :file_type, :file_date, :status, :metadata, :disk_id, :software, :software_version, :record_date, :current, :comments, :coverage_data_date, :qa_data_date, :bed_file_date, :genotype_file_date, :COVERAGE_Alltypes_Fully_Called_Percent, :COVERAGE_Alltypes_Partially_Called_Percent, :COVERAGE_Alltypes_No_Called_Percent, :COVERAGE_Alltypes_Fully_Called_Count, :COVERAGE_Alltypes_Partially_Called_Count, :COVERAGE_Alltypes_No_Called_Count, :COVERAGE_Exon_Any_Called_Count, :COVERAGE_Unclassified_Any_Called_Count, :COVERAGE_Repeat_Simple_Low_Fully_Called_Count, :COVERAGE_Repeat_Int_Young_Fully_Called_Count, :COVERAGE_Repeat_Other_Fully_Called_Count, :COVERAGE_Cnv_Fully_Called_Count, :COVERAGE_Segdup_Fully_Called_Count, :COVERAGE_Exon_Partially_Called_Count, :COVERAGE_Unclassified_Partially_Called_Count, :COVERAGE_Repeat_Simple_Low_Partially_Called_Count, :COVERAGE_Repeat_Int_Young_Partially_Called_Count, :COVERAGE_Repeat_Other_Partially_Called_Count, :COVERAGE_Cnv_Partially_Called_Count, :COVERAGE_Segdup_Partially_Called_Count, :COVERAGE_Exon_No_Called_Count, :COVERAGE_Unclassified_No_Called_Count, :COVERAGE_Repeat_Simple_Low_No_Called_Count, :COVERAGE_Repeat_Int_Young_No_Called_Count, :COVERAGE_Repeat_Other_No_Called_Count, :COVERAGE_Cnv_No_Called_Count, :COVERAGE_Segdup_No_Called_Count)
  end

end
