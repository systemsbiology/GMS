class AssayFilesController < ApplicationController
  # GET /assay_files
  # GET /assay_files.xml
  def index
    #@assay_files = AssayFile.find(:all, :conditions => ['file_type = ?', params[:file_type]]) if (params[:file_type])
#    @assay_files = @assay_files.find_all_by_file_type(params[:file_type]) if (params[:file_type])
#    @assay_files = find_all_by_pedigree_id(params[:pedigree][:id]) if (params[:pedigree])
#    @assay_files = @assay_files.find(:all, :include => { :assay => { :sample => { :person => :pedigree } } },
#                                        :conditions => [ 'pedigrees.id = ?', params[:pedigree][:id] ]) if (params[:pedigree])
    @assay_files = AssayFile.has_file_type(params[:file_type]).has_pedigree(params[:pedigree])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assay_files }
      format.json  { render :json => @assay_files }
    end
  end

  # GET /assay_files/1
  # GET /assay_files/1.xml
  def show
    @assay_file = AssayFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assay_file }
      format.json  { render :json => @assay_file }
    end
  end

  # GET /assay_files/new
  # GET /assay_files/new.xml
  def new
    @assay_file = AssayFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assay_file }
      format.json  { render :json => @assay_file }
    end
  end

  # GET /assay_files/1/edit
  def edit
    @assay_file = AssayFile.find(params[:id])
  end

  # POST /assay_files
  # POST /assay_files.xml
  def create
    @assay_file = AssayFile.new(params[:assay_file])

    respond_to do |format|
      if @assay_file.save
        format.html { redirect_to(@assay_file, :notice => 'Assay file was successfully created.') }
        format.xml  { render :xml => @assay_file, :status => :created, :location => @assay_file }
        format.json  { render :json => @assay_file, :status => :created, :location => @assay_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assay_file.errors, :status => :unprocessable_entity }
        format.json  { render :json => @assay_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assay_files/1
  # PUT /assay_files/1.xml
  def update
    @assay_file = AssayFile.find(params[:id])

    respond_to do |format|
      if @assay_file.update_attributes(params[:assay_file])
        format.html { redirect_to(@assay_file, :notice => 'Assay file was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assay_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assay_files/1
  # DELETE /assay_files/1.xml
  def destroy
    @assay_file = AssayFile.find(params[:id])
    @assay_file.destroy

    respond_to do |format|
      format.html { redirect_to(assay_files_url) }
      format.xml  { head :ok }
    end
  end


  #HELPER METHODS

    def find_all_by_pedigree_id(pedigree_id)
    @assay_files = AssayFile.find(:all, :include => { :assay => { :sample => { :person => :pedigree } } },
                                        :conditions => [ 'pedigrees.id = ?', pedigree_id ])
  end

end
