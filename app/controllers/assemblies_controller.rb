require 'utils'

class AssembliesController < ApplicationController
  # GET /assembly
  # GET /assembly.xml
  def index
#    @assembly = find_all_by_pedigree_id(params[:pedigree_filter][:id]) if (params[:pedigree_filter])
#    @assembly = @assembly.find(:all, :include => { :assay => { :sample => { :person => :pedigree } } },
#                                        :conditions => [ 'pedigrees.id = ?', params[:pedigree_filter][:id] ]) if (params[:pedigree_filter])
    @assemblies = Assembly.has_pedigree(params[:pedigree_filter])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assembly }
      format.json  { render :json => @assembly }
      format.js
    end
  end

  # GET /assembly/1
  # GET /assembly/1.xml
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
    @assembly = Assembly.new(params[:assembly])
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
      if @assembly.update_attributes(params[:assembly])
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
    @assembly = Assembly.find(:all, :include => { :assay => { :sample => { :person => :pedigree } } },
                                        :conditions => [ 'pedigrees.id = ?', pedigree_id ])
  end

end
