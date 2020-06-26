require 'will_paginate'
require 'will_paginate/array'

class AssemblyFilesController < ApplicationController
  caches_action :ped_info
  cache_sweeper :assembly_files_sweeper
  # GET /assembly_files
  # GET /assembly_files.xml
  def index
    #@assembly_files = AssemblyFile.find(:all, :conditions => ['file_type = ?', params[:file_type]]) if (params[:file_type])
#    @assembly_files = @assembly_files.find_all_by_file_type(params[:file_type]) if (params[:file_type])
#    @assembly_files = find_all_by_pedigree_id(params[:pedigree_filter][:id]) if (params[:pedigree_filter])
#    @assembly_files = @assembly_files.find(:all, :include => { :assembly => { :assay => { :sample => { :person => :pedigree } } } },
#                                        :conditions => [ 'pedigrees.id = ?', params[:pedigree_filter][:id] ]) if (params[:pedigree_filter])
    if params[:file_type_id].blank? then
    #  logger.debug("setting params[:file_type_id] to nil because it is blank #{params[:file_type_id]} #{params[:file_type_id].blank?}")
      params[:file_type_id] = nil
    end
    # has_file_type(params[:file_type]).
    @assembly_files = AssemblyFile.has_file_type_id(params[:file_type_id]).has_pedigree(params[:pedigree_filter]).order("assembly_id").paginate :page => params[:page], :per_page => 100

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assembly_files }
      format.json  { render :json => @assembly_files }
      format.js
    end
  end

  # GET /assembly_files/1
  # GET /assembly_files/1.xml
  def show
    @assembly_file = AssemblyFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assembly_file }
      format.json  { render :json => @assembly_file }
    end
  end

  # GET /assembly_files/new
  # GET /assembly_files/new.xml
  def new
    @assembly_file = AssemblyFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assembly_file }
      format.json  { render :json => @assembly_file }
    end
  end

  # GET /assembly_files/1/edit
  def edit
    @assembly_file = AssemblyFile.find(params[:id])
  end

  # POST /assembly_files
  # POST /assembly_files.xml
  def create
    @assembly_file = AssemblyFile.new(assembly_file_params)

    respond_to do |format|
      puts "format is #{format.inspect}\n"
      if @assembly_file.save!
        puts "saved assembly!\n"
        format.html { redirect_to(@assembly_file, :notice => 'Assay file was successfully created.') }
        format.xml  { render :xml => @assembly_file, :status => :created, :location => @assembly_file }
        format.json  { render :json => @assembly_file, :status => :created, :location => @assembly_file }
      else
        puts "failed to save assembly #{@assembly_file.errors.inspect}\n\n"
        format.html { render :action => "new" }
        format.xml  { render :xml => @assembly_file.errors, :status => :unprocessable_entity }
        format.json  { render :json => @assembly_file.errors, :status => :unprocessable_entity }
      end

    end
    puts "ending!\n\n"
  end

  # PUT /assembly_files/1
  # PUT /assembly_files/1.xml
  def update
    @assembly_file = AssemblyFile.find(params[:id])

    respond_to do |format|
      if @assembly_file.update_attributes(assembly_file_params)
        format.html { redirect_to(@assembly_file, :notice => 'Assay file was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assembly_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assembly_files/1
  # DELETE /assembly_files/1.xml
  def destroy
    @assembly_file = AssemblyFile.find(params[:id])
    @assembly_file.destroy

    respond_to do |format|
      format.html { redirect_to(assembly_files_url) }
      format.xml  { head :ok }
    end
  end

  def ped_info
    ped_info = Hash.new
    AssemblyFile.all.each do |af|
      ped_id = af.pedigree_id.to_s
      ped_info[af.location] = "isb_ped_"+ped_id
      af_id = "isb_asmfile_"+af.id.to_s
      ped_info[af_id] = "isb_ped_"+ped_id
    end

    respond_to do |format|
      format.xml {head :ok}
      format.json { render :json => ped_info }
    end
  end


  #HELPER METHODS

    def find_all_by_pedigree_id(pedigree_id)
    @assembly_files = AssemblyFile.find(:all, :include => { :assembly => {:assay => { :sample => { :person => :pedigree } } } },
                                        :conditions => [ 'pedigrees.id = ?', pedigree_id ])
  end

  private
  def assembly_file_params
    params.require(:assembly_file).permit(:genome_reference_id, :name, :assembly_id, :description, :location, :file_type_id, :metadata, :software, :software_version, :file_date, :current, :comments)
  end

end
