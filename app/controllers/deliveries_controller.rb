class DeliveriesController < ApplicationController
  # GET /deliveries
  # GET /deliveries.json
  def index
    @deliveries = Delivery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deliveries }
    end
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @delivery }
    end
  end

  # GET /deliveries/new
  # GET /deliveries/new.json
  def new
    @delivery = Delivery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @delivery }
    end
  end

  # GET /deliveries/1/edit
  def edit
    @delivery = Delivery.find(params[:id])
  end

  # POST /deliveries
  # POST /deliveries.json
  def create
    uploaded_file = delivery_params[:spreadsheet]
    @delivery = Delivery.find_by_spreadsheet_name(uploaded_file.original_filename) || Delivery.new(delivery_params)
    
    file = Tempfile.new(uploaded_file.original_filename)
    @delivery.spreadsheet_name = uploaded_file.original_filename
    @delivery.date_uploaded = Time.now
    file.write(uploaded_file.read.force_encoding("UTF-8"))
    begin
        book = Spreadsheet.open file.path
    rescue
        flash[:error] = "File provided is not a valid Excel spreadsheet (.xls) file. Excel 2007 spreadsheets (.xlsx) files are not supported."
        render :action => "new" and return
    end
    sheet = book.worksheet 0
    logger.debug("after sheet")
    begin
      header_file = File.read(EXCEL_DELIVERY_INDEX_FILE)
    rescue
      if !defined?(EXCEL_DELIVERY_INDEX_FILE) then
        logger.error("EXCEL_DELIVERY_INDEX_FILE is not set in the config/environment.rb.  Please set this parameter and restart the application.")
        flash[:error] = "EXCEL_DELIVERY_INDEX_FILE is not set in the config/environment.rb.  Please set this parameter and restart the application."
        render :action => "new" and return(0)
      else
        logger.error("Could not read #{EXCEL_DELIVERY_INDEX_FILE}.  Please check that this file exists and is readable.")
        flash[:error] = "Could not read #{EXCEL_DELIVERY_INDEX_FILE}.  Please check that this file exists and is readable."
        render :action => "new" and return(0)
      end
    end
    logger.debug("after header file")
    headers = nil
    if sheet.name == "Shipped Genomes" then
        headers =  YAML.load(header_file)["CGI_1.0"]
    else
      logger.error("Unhandled Delivery Information #{sheet.name} for Delivery.  Check to make sure that the spreadsheet you submitted is a CGI Delivery spreadsheet.  If it is, then please add new version to the YAML and re-run.")
      flash[:error] = "Unhandled Delivery Information #{sheet.name} for Delivery.  Check to make sure that the spreadsheet you submitted is a CGI Delivery spreadsheet.  If it is, then please add new version to the YAML and re-run."
      render :action => "new" and return(0)
    end
    logger.debug("after headers #{headers.inspect}")

    if headers.nil? then
      logger.error("Error loading header information for Delivery Manifest from #{EXCEL_DELIVERY_INDEX_FILE}")
      flash[:error] = "Error loading header information for Delivery manifest."
      render :action => "new" and return(0)
    end
    flag = nil
    counter = 0
    @errors = Hash.new
    sheet.each do |row|
        logger.debug("parsing row #{row.inspect}")
        next if row.nil? or row.empty?
        if row[0] == "Company" then
            # check all of the headers exist
            headers.each do |col, index|
                logger.debug("col #{col.inspect} index #{index.inspect} row[index] #{row[index].inspect}")
                if row[index] != col then
                    flash[:error] = "Spreadsheet provided has an incorrect column.  <b>\"#{row[index]}\"</b> in column number #{index} should be <b>\"#{col}\"</b>.  Please check the format of your spreadsheet."
                    render :action => "new" and return(0)
                end
            end

            flag = 1
            next
        end

        if flag == 1 then
            counter +=1
            # make sure there's a sample with the sample vendor ID and customer sample ID
            sampleID = row[headers["Sample ID"]]
            if !sampleID.nil? then
                # if there's a sample in GMS already then it should be more up to date than the
                # data we have in this spreadsheet, so don't modify it
                s = Sample.find(:first, :conditions => {:sample_vendor_id => sampleID}) || nil
                if s.nil? then
                    s = Sample.new
                    s.sample_vendor_id = sampleID 
                    logger.debug("header customer sample #{headers["Cust. Sample ID"].inspect}")
                    logger.debug("row #{row[headers["Cust. Sample ID"]].inspect}")
                    s.customer_sample_id = row[headers["Cust. Sample ID"]].to_s
                    logger.debug("sample #{s.inspect}")
                    if s.valid?
                        s.save
                        logger.debug("saved sample #{s.inspect}")
                    else
                        logger.debug("sample invalid? #{s.inspect} #{s.errors.inspect}")
                        @errors["#{counter}"] = Hash.new
                        @errors["#{counter}"]["sample"] = s.errors
                    end
                end
            else
                # create a new sample to return the error that there is no sample id
                s = Sample.new
                s.errors.add(:sample, 'must have a sample id')
                @errors["#{counter}"] = Hash.new  if @errors["#{counter}"].nil?
                @errors["#{counter}"]["sample"] = s.errors
                render :action => "new" and return(0)
            end
            
            # make sure there's an assay with the deliverable ID as name and media_id is Job ID 
            # and encryption key is truecrypt_key (encrypted to encrypted_truecrypt_key automatically)
            assay_name = row[headers["Deliverable ID"]]
            if !assay_name.nil? then
                a = Assay.find_by_name(assay_name) || nil
                if a.nil? then
                    a = Assay.new
                    a.name = assay_name if a.name.nil?
                    media_id = row[headers["Job ID"]]
                    if media_id.nil? then
                        a.errors.add(:assay, 'must have a Job ID to use as media_id')
                        @errors["#{counter}"] = Hash.new  if @errors["#{counter}"].nil?
                        @errors["#{counter}"]["assay"] = a.errors
                        render :action => "new" and return(0)
                    end
                    a.media_id = media_id if a.media_id.nil?
                    truecrypt_key = row[headers["Encryption Key"]]
                    if !truecrypt_key.nil? and !truecrypt_key.match(/not applicable/) then
                        a.truecrypt_key = truecrypt_key if a.truecrypt_key.nil?
                    end
                    a.assay_type = "sequencing"
                    # this is for CGI assays which is the only type this method should parse
                    if row[headers["Tumor Status"]] == "Tumor" then
                        a.technology = "Cancer WGS"
                    elsif (row[headers["Baseline"]] == "Yes" or row[headers["Baseline"]] == "No") then
                        a.technology = "Cancer WGS"
                    else
                        a.technology = "Standard WGS"
                    end
    
                    a.vendor = "Complete Genomics"
                    if a.valid? then
                        a.save
                        logger.debug("saved assay #{a.inspect}")
                    else
                        @errors["#{counter}"] = Hash.new  if @errors["#{counter}"].nil?
                        @errors["#{counter}"]["assay"] = a.errors
                        render :action => "new" and return(0)
                    end
                else
                    # if an assay has been created without a truecrypt key then that needs to be updated
                    if row[headers["Encryption Key"]] then
                        truecrypt_key = row[headers["Encryption Key"]]
                        if !truecrypt_key.nil? and !truecrypt_key.match(/not applicable/) then
                            if a.truecrypt_key.nil? then
                                a.truecrypt_key = truecrypt_key
                            end
                        end 
                    end

                    if a.media_id.nil? && !row[headers["Job ID"]].nil? then
                        a.media_id = row[headers["Job ID"]]
                    end

                    if a.valid? then
                        a.save
                        logger.debug("updated assay #{a.inspect}")
                    else
                        @errors["#{counter}"] = Hash.new  if @errors["#{counter}"].nil?
                        @errors["#{counter}"]["assay"] = a.errors
                        render :action => "new" and return(0)
                    end
                end
            else
                a = Assay.new
                a.errors.add(:assay, 'must have a Deliverable ID to use as a name')
                @errors["#{counter}"] = Hash.new  if @errors["#{counter}"].nil?
                @errors["#{counter}"]["assay"] = a.errors
                render :action => "new" and return(0)
            end            

            # assembly is added by the pipeline uploader.
        else
            flash[:error] = "This delivery manifest does not contain the correct headers.  Please check and try again."
            render :action => "new" and return(0)
        end # end if flag

    end # end foreach row
    logger.debug("after sheet")

    respond_to do |format|
      if @errors.size == 0 && @delivery.save
        format.html { redirect_to @delivery, notice: 'Delivery was successfully created.' }
        format.json { render json: @delivery, status: :created, location: @delivery }
      else
        format.html { render action: "new" }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliveries/1
  # PATCH/PUT /deliveries/1.json
  def update
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      if @delivery.update_attributes(delivery_params)
        format.html { redirect_to @delivery, notice: 'Delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.json
  def destroy
    @delivery = Delivery.find(params[:id])
    @delivery.destroy

    respond_to do |format|
      format.html { redirect_to deliveries_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def delivery_params
      params.require(:delivery).permit(:date_uploaded, :sales_order, :spreadsheet_name, :spreadsheet)
    end
end
