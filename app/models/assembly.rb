require 'find'
require 'utils'

class Assembly < ActiveRecord::Base
  belongs_to :assay
  belongs_to :genome_reference
  has_many :assembly_files, :dependent => :destroy
  after_save :ensure_files_up_to_date

  auto_strip_attributes :name, :location, :description, :metadata, :software, :software_version, :comments
  validate :validates_assembly_directory
  validates_presence_of :name, :genome_reference_id, :assay, :location, :software, :software_version, :file_date
  validates_uniqueness_of :name, :location

  after_create :check_isb_assay_id
  after_update :check_isb_assay_id

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        { :include => { :assay => { :sample => { :person => :pedigree } } },
          :conditions => [ 'pedigrees.id = ?', pedigree_id]
        }
      end
    end
  }

  scope :is_current, lambda {
    { :conditions => [ 'current = ?', '1'] }
  }

  def validates_assembly_directory
      if !File.exists?(self.location) then
        errors.add(:location, "Directory does not exist on filesystem.")
      end
  end

  # check the assembly, look in that directory and make sure there
  # is an assembly file entry for each file in that directory that is
  # in the config files.
  def ensure_files_up_to_date
    files = find_assembly_files
    add_files = check_add_assembly_files(files)
    errors = add_assembly_files(add_files)
    if errors.size > 0 then
      return errors
    end
    update_files = check_update_assembly_files(files)
    errors = update_assembly_files(update_files)
    if errors.size > 0 then
      return errors
    else
      return []
    end
    
  end

  # look on disk for the assembly files specified in the config under PEDIGREE_ROOT
  def find_assembly_files
    start_dir = self.location
    files = Hash.new
    Find.find(start_dir) do |path|
      filename = File.basename(path).split("/").last
      FILE_TYPES.each { |filepart, filehash| 
	type = filehash["type"]
	vendor = filehash["vendor"]
        if filename.match(filepart) then 
          files[type] = Hash.new
	  files[type]["path"] = path
	  files[type]["vendor"] = vendor
        end
      }
    end
    return files
  end

  # look in the database for the assembly files
  def check_add_assembly_files(files=self.find_assembly_files)
    add = Hash.new
    files.each do |file_type, file_hash|
      # returns an array
      file_path = file_hash["path"]
      file_vendor = file_hash["vendor"]
      filename = File.basename(file_path)
      # if you use file_type then if the file_type is wrong it tries to add a new file...
#      af = AssemblyFile.includes(:file_type).where(:name => filename, :file_types => {:type_name => file_type})
      af = AssemblyFile.where(:name => filename) 

      if af.size == 0 then
        add[file_path] = Hash.new
	add[file_path]["type"] = file_type
	add[file_path]["vendor"] = file_vendor
      end

    end
    if add.size == 0 then
      logger.error("check_add_assembly_files did not find any files to add")
      return []
    end
    return add
  end

  # look in the database for the assembly files
  def check_update_assembly_files(files=self.find_assembly_files)
    update = Hash.new
    files.each do |file_type, file_hash|
      file_path = file_hash["path"]
      file_vendor = file_hash["vendor"]
      # returns an array
      filename = File.basename(file_path)
      af = AssemblyFile.find_by_name(filename)

      if !af.nil? then
        if af.location != file_path or af.file_type != file_type then
	  #puts "updating file #{file_path} #{af.inspect}"
	  update[af.id] = Hash.new
          update[af.id]['path'] = file_path
	  update[af.id]['type'] = file_type
	  update[af.id]['vendor'] = file_vendor
	end
      end

    end

    return update
  end

  def add_assembly_files(files=self.check_add_assembly_files)
    if files.size == 0 then
      logger.error("add_assembly_files didn't get any results from check_add_assembly_files")
      return []
    end
    asm_file_errors = Array.new
    files.each do |file_path, file_hash|
      file_type = file_hash["type"]
      file_vendor = file_hash["vendor"]
      #puts "file type is #{file_type} and path is #{file_path}"
      #puts FileType.find_by_type_name(file_type).id
      file_type_id = FileType.find_by_type_name(file_type).id
      # header returns the top of the file, use variables in environment.rb to 
      # figure out what the names of the fields are that we're looking for
      # so that the fields are easily updatable 
      header = file_header(file_path, file_vendor)
      if file_vendor == "CGI" then
        check = check_cgi_header(header, file_type, file_path)
	software = header[CGI_SOFTWARE_PROGRAM]
	software_version = header[CGI_SOFTWARE_VERSION]
      elsif file_vendor == "VCF" then
        check = check_vcf_header(header, file_type, file_path)
	if file_type == "VCF-INDEL-ANNOTATION" then
	  software = header[VCF_SOURCE]
	else
	  software = "UnifiedGenotyper"
	end
	software_version = "UNKNOWN"
      end

      if check == 0 then
        logger.error("skipping file #{file_path} because it contains incorrect values for this filetype")
	asm_file_errors.push("#{file_path} cannot be added to assembly because it contains incorrect values for this filetype")
        next
      end
 
      if file_vendor == "CGI" then
        xml = header.to_xml(:root => "assembly-file")
      elsif file_vendor == "VCF" then
        xml = header.to_xml
      else
        xml = ''
      end

      filename = File.basename(file_path)
      if filename.match(/~$/) then
        logger.error("Skipping a file with a tilda when adding assembly files.  filename #{filename}")
        next
      end
      #logger.error("file_type_id #{file_type_id} for assembly #{self.inspect} #{self.location} trying to add #{file_path}")
      assembly_file = AssemblyFile.new( 
      					:genome_reference_id => self.genome_reference_id,
					:assembly_id => self.id,
      					:file_type_id => file_type_id, 
					:name => filename,
      					:location => file_path, 
					:file_date => creation_time(file_path),
					:software => software,
					:software_version => software_version,
					:current => 1,
					:metadata => xml
					)

      #logger.error("adding assembly_file #{assembly_file.inspect}")
      assembly_file.save! # exclamation point forces it to raise an error if the save fails
    end # end files.each

    return asm_file_errors
  end

  def update_assembly_files(files=self.check_update_assembly_files)
    #puts "update_assembly_files says files are #{files.inspect}\n\n"
    asm_file_errors = Array.new
    files.each do |assembly_file_id, innerhash|
      file_type = innerhash["type"]
      file_path = innerhash["path"]
      file_vendor = innerhash["vendor"]
      #puts "updating #{file_type} and #{file_path}"

      assembly_file = AssemblyFile.find(assembly_file_id)

      file_type_id = FileType.find_by_type_name(file_type).id
      # header returns the top of the file, use variables in environment.rb to 
      # figure out what the names of the fields are that we're looking for
      # so that the fields are easily updatable 
      header = file_header(file_path, file_vendor)

      if file_vendor == "CGI" then
        check = check_cgi_header(header, file_type, file_path)
	software = header[CGI_SOFTWARE_PROGRAM]
	software_version = header[CGI_SOFTWARE_VERSION]
      elsif file_vendor == "VCF" then
        check = check_vcf_header(header, file_type, file_path)
	if file_type == "VCF-INDEL-ANNOTATION" then
	  software = header[VCF_SOURCE]
	else
	  software = "UnifiedGenotyper" # this is hardcoded for now to not need to parse an INFO field...
	end
	software_version = "UNKNOWN"
      end

      if check == 0 then
        logger.error("skipping file #{file_path} because it contains incorrect values for this filetype")
	asm_file_errors.push("#{file_path} cannot be added to assembly because it contains incorrect values for this filetype")
        next
      end

      if file_vendor == "CGI" then
        xml = header.to_xml(:root => "assembly-file")
      elsif file_vendor == "VCF" then
        xml = header.to_xml
      else
        xml = ''
      end

      filename = File.basename(file_path)
      assembly_file.update_attributes( 
      					"genome_reference_id" => self.genome_reference_id,
					"assembly_id" => self.id,
      					"file_type_id" => file_type_id, 
					"name" => filename,
      					"location" => file_path, 
					"file_date" => creation_time(file_path),
					"software" => software,
					"software_version" => software_version,
					"current" => 1,
					"metadata" => xml
					)
      return asm_file_errors
    end
  end

  def identifier
    "#{name} - #{GenomeReference.find(genome_reference_id).name} - #{software_version}"
  end

  def check_cgi_header(header, file_type, file_path)
     if header[CGI_SAMPLE].nil? then
        logger.error("ERROR: file #{file_path} with type #{file_type} doesn't appear to be a valid CGI file.")
	return 0
      end

      if header[CGI_ASSEMBLY_ID].nil? or header[CGI_ASSEMBLY_ID] != self.name then
        logger.error("ERROR: file assembly name #{header[CGI_ASSEMBLY_ID]} doesn't match self assembly id #{self.name}.  Make sure that the value for CGI_ASSEMBLY_ID in config/environment.rb is correct.")
	return 0 
      end

      if header[CGI_GENOME_REFERENCE].nil? or header[CGI_GENOME_REFERENCE] != self.genome_reference.build_name then
        logger.error("ERROR: file genome_reference #{header[CGI_GENOME_REFERENCE]} doesn't match  #{self.genome_reference.build_name}.  Make sure that the value for CGI_GENOME_REFERENCE in config/environment.rb is correct.")
	return 0 
      end
      if header[CGI_SAMPLE].nil? or header[CGI_SAMPLE] != self.assay.sample.sample_vendor_id then
        logger.error("ERROR: file sample #{header[CGI_SAMPLE]} doesn't match #{self.assay.sample.sample_vendor_id}.  Make sure that the value for CGI_SAMPLE in config/environment.rb is correct.")
	return 0 
      end
      if header[CGI_SOFTWARE_PROGRAM].nil? then
        logger.error("ERROR: file_sample #{header[CGI_SAMPLE]} doesn't have a CGI_SOFTWARE_PROGRAM value.")
	return 0
      end
#  CGI uses GENE-ANNOTATION for ncRNA file but we want to be more specific, so we can't check unless we add exceptions.
#      if header[CGI_FILE_TYPE] and header[CGI_FILE_TYPE] != file_type then
#        logger.error("ERROR: file type #{header[CGI_FILE_TYPE]} doesn't match #{file_type}.  Make sure that the value for CGI_FILE_TYPE in config/environment.rb is correct.")
#	next
#      end

      return 1
  end

  def check_vcf_header(header, file_type, file_path)
    # indel file has VCF_SOURCE, VCF_FILEFORMAT, VCF_GENOME_REFERENCE
    # snp file has VCF_FILEFORMAT
    if header[VCF_FILEFORMAT].nil? or !header[VCF_FILEFORMAT].match(/VCF/) then
      logger.error("ERROR: file #{file_path} with type #{file_type} doesn't appear to be a valid VCF file")
      return 0
    end

    if file_type == "VCF-INDEL-ANNOTATION" then
      if header[VCF_SOURCE].nil? then
        logger.error("ERROR: file #{file_path} with type #{file_type} doesn't have a source")
        return 0
      end

      if header[VCF_GENOME_REFERENCE].nil? then
        logger.error("ERROR: file #{file_path} with type #{file_type} doesn't have a genome reference")
        return 0
      end
    end

    return 1
  end

  def complete
    # TODO: there should be a better way to do this other than to hardcode the file_type_id
    var_file_count = self.assembly_files.where(["file_type_id = ?", 1]).count
    vcf_file_count = self.assembly_files.where(["file_type_id = ?", 8]).count    
    if var_file_count > 0 || vcf_file_count > 0 then
      return true
    end
    return false
  end
end

  def check_isb_assembly_id
    if self.isb_assembly_id.nil? or !self.isb_assembly_id.match(/isb_asm/) then
      isb_assembly_id = "isb_asm_"+self.id.to_s
      self.update_attributes(:isb_assembly_id => isb_assembly_id)
    end
  end

