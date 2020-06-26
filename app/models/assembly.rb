require 'find'
require 'utils'
require 's3_utils'

class Assembly < ActiveRecord::Base
  belongs_to :assay
  belongs_to :genome_reference
  has_many :assembly_files, :dependent => :destroy
  after_save :ensure_files_up_to_date

  auto_strip_attributes :name, :location, :description, :metadata, :software, :software_version, :comments
  validates_presence_of :name, :genome_reference_id, :assay, :location, :software, :software_version
  validates_uniqueness_of :name, :location
  validate :validates_assembly_directory

  after_create :check_isb_assembly_id
  after_update :check_isb_assembly_id

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      if pedigree.kind_of?(Array) then
        pedigree_id = pedigree[0]
      elsif pedigree.kind_of?(ActionController::Parameters) or pedigree.kind_of?(Hash) then
        pedigree_id = pedigree[:id]
      else
        pedigree_id = pedigree.to_i
      end
      unless pedigree_id.blank?
        joins(:assay => { :sample => { :person => :pedigree } } )
        .where(pedigrees: {id: pedigree_id})
      end
    end
  }

  scope :is_current, lambda {
    { :conditions => [ 'current = ?', '1'] }
  }

  def check_circos
    circos = self.location+'/REPORTS/circos-'+self.name+'.png'
    if File.exists?(circos) then
        return true
    else
        return false
    end
  end

  def validates_assembly_directory
      if self.location.match(/wellness/) then # this is a hack because the user the db runs as doesn't have access to all of the directories - TODO: Make this better somehow?
          return
      end
      if self.location && ! self.location.match(/^s3/) && !File.exists?(self.location) then
        errors.add(:location, "Directory does not exist on filesystem.")
        logger.error("validates_assembly_directory says that #{self.location} doesn't exist")
      end
  end

  # check the assembly, look in that directory and make sure there
  # is an assembly file entry for each file in that directory that is
  # in the config files.
  def ensure_files_up_to_date
    if self.location.match(/^s3/)
        files = find_s3_files
    else
        files = find_assembly_files
    end
    #logger.debug("files #{files}")
    update_files = check_update_assembly_files(files)
    #logger.debug("update files #{update_files}")
    errors = update_assembly_files(update_files)
    if errors.size > 0 then
      return errors
    end
    add_files = check_add_assembly_files(files)
    #logger.debug( "add files #{add_files}")
    errors = add_assembly_files(add_files)
    #logger.debug("errors #{errors}")
    if errors.size > 0 then
      return errors
    else
      return []
    end
  end

  # find files on s3
  def find_s3_files
    output = `s3cmd ls #{self.location}/`
    output.gsub!(/DIR/,"")
    output.gsub!(/ +/," ")
    dir_listing = output.split(/\n/)
    logger.debug("dir_listing #{dir_listing.inspect}")
    files = Hash.new
    dir_listing.each do |list|
        if (list.match(/^ /)) then
          # found a directory - not going to worry about going down the directory for now
        else
          # found a file
          (date, time, size, path) = list.split(/ /)
          filename = File.basename(path).split("/").last
          FILE_TYPES.each { |filepart, filehash|
            type = filehash["type"]
            vendor = filehash["vendor"]
            if filename.match(filepart) then
              #logger.debug( "filename is #{filename}")
              files[type] = Hash.new
              files[type]["path"] = path
              files[type]["vendor"] = vendor
            end
          }
        end
    end
    logger.debug(" files is #{files.inspect}")
    return files
  end


  # look on disk for the assembly files specified in the config under PEDIGREE_ROOT
  def find_assembly_files
    start_dir = self.location
    #logger.debug("self is #{self.inspect}")
    #logger.debug("checking in location #{start_dir}")
    files = Hash.new
    if ! File.directory? start_dir then
      errors.add(:location, "Directory #{start_dir} does not exist on the system.")
      #abort("Directory #{start_dir} does not exist on the system for #{self.inspect}")
      return []
    end
    #logger.error("start dir is #{start_dir}")
    Find.find(start_dir) do |path|
      filename = File.basename(path).split("/").last
      skip_flag = 0
      FILE_SKIPS.each { |filepart, filehash|
        type = filehash["type"]
        category = filehash["category"]
        if category == 'suffix' then
            if (filename.match("#{filepart}$")) then
                skip_flag = 1
            end
        else
            if (filename.match("#{filepart}")) then
                skip_flag = 1
            end
        end

      }
      if (skip_flag == 1) then
        logger.error("Skipping file #{filename} because it matches a file skip")
        next
      end
      FILE_TYPES.each { |filepart, filehash|
	    type = filehash["type"]
	    vendor = filehash["vendor"]
        if filename.match(filepart) then
          #logger.error("filename is #{filename}")
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
	  #logger.debug("updating file #{file_path} #{af.inspect}")
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
    #logger.debug "self at front of adda_ssembly_files #{self.inspect} #{self.location}\n\n"
    #logger.debug "self sample #{self.assay.sample.inspect}\n\n"
    if files.size == 0 then
      logger.error("add_assembly_files didn't get any results from check_add_assembly_files")
      return []
    end
    asm_file_errors = Array.new
    files.each do |file_path, file_hash|
      if (file_path.match(/~\z/)) then
        logger.debug("Skipping file #{file_path} because it contains a tilda")
        next
      end
      file_type = file_hash["type"]
      file_vendor = file_hash["vendor"]
      #logger.debug "file type is #{file_type} and path is #{file_path} and file_vendor is #{file_vendor}"
      #logger.debug FileType.find_by_type_name(file_type)
      file_type_id = FileType.find_by_type_name(file_type).id
      # header returns the top of the file, use variables in environment.rb to
      # figure out what the names of the fields are that we're looking for
      # so that the fields are easily updatable
      if (file_path.match(/^s3/)) then
        software_version = get_software_version(self.location)
        software = 'cgatools' # this is impossible to get without loading each file and too expensive for now
      else
          header = file_header(file_path, file_vendor)
          if file_vendor == "CGI" and file_type.match("VCF") then
            check = check_cgi_vcf_header(header, file_type, file_path)
            software = header[CGI_SOFTWARE_PROGRAM]
            software_version = header[CGI_SOFTWARE_VERSION]
          elsif file_vendor == "CGI" then
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
      end

       #logger.debug "file #{file_path} file_vendor #{file_vendor} file_type_id #{file_type_id} check #{check} software #{software} software_version #{software_version}\n"

      if check == 0 then
        logger.error("skipping file #{file_path} because it contains incorrect values for this filetype")
	    asm_file_errors.push("#{file_path} cannot be added to assembly because it contains incorrect values for this filetype")
        next
      end
      if file_path.match(/^s3/) then
        xml = ''
      elsif file_vendor == "CGI" then
        xml = header.to_xml(:root => "assembly-file")
      elsif file_vendor == "VCF" then
        xml = header.to_xml
      else
        xml = ''
      end
      if file_path.match(/Old/) or file_path.match(/OLD/) then
        logger.error("Skipping file because it's in an old directory #{file_path}")
        next
      end
      filename = File.basename(file_path)
      if filename.match(/~\z/) then
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
    #logger.debug("update_assembly_files says files are #{files.inspect}")
    asm_file_errors = Array.new
    files.each do |assembly_file_id, innerhash|
      file_type = innerhash["type"]
      file_path = innerhash["path"]
      file_vendor = innerhash["vendor"]
      #logger.debug( "updating #{file_type} and #{file_path}")

      assembly_file = AssemblyFile.find(assembly_file_id)

      file_type_id = FileType.find_by_type_name(file_type).id
      # header returns the top of the file, use variables in environment.rb to
      # figure out what the names of the fields are that we're looking for
      # so that the fields are easily updatable
      header = file_header(file_path, file_vendor)

      if file_vendor == "CGI" and file_type.match("VCF") then
        check = check_cgi_vcf_header(header, file_type, file_path)
	    software = header[CGI_SOFTWARE_PROGRAM]
	    software_version = header[CGI_SOFTWARE_VERSION]
      elsif file_vendor == "CGI" then
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
      if software_version.nil? || software.nil? then
        logger.error("skipping file #{file_path} because it did not set software or software_version")
        asm_file_errors.push("#{file_path} cannot be added to assembly because it did not set software or software_version")
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
    end

    return asm_file_errors
  end

  def identifier
    "#{name} - #{GenomeReference.find(genome_reference_id).name} - #{software_version}"
  end



  def check_cgi_header(header, file_type, file_path)
     return 1 if file_type == 'SVEVENTS' #SVEVENTS don't have any of this info in the header :(
     return 1 if file_path.match(/^s3/) # s3 files aren't on disk and can't be read

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
        #print "file sample #{header[CGI_SAMPLE]} doesn't match #{self.assay.sample.sample_vendor_id}\n"
        logger.error("ERROR: file HEADER sample #{header[CGI_SAMPLE]} doesn't match SELF VENDOR_ID #{self.assay.sample.sample_vendor_id}.  Make sure that the value for CGI_SAMPLE in config/environment.rb is correct.")
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


  def check_cgi_vcf_header(header, file_type, file_path)
     return 1 if file_type == 'SVEVENTS' #SVEVENTS don't have any of this info in the header :(

      if header[CGI_ASSEMBLY_ID].nil? or header[CGI_ASSEMBLY_ID] != self.name then
        logger.error("ERROR: file assembly name #{header[CGI_ASSEMBLY_ID]} doesn't match self assembly id #{self.name}.  Make sure that the value for CGI_ASSEMBLY_ID in config/environment.rb is correct.")
	    return 0
      end

      if header[CGI_GENOME_REFERENCE].nil? or header[CGI_GENOME_REFERENCE] != self.genome_reference.build_name then
        logger.error("ERROR: file genome_reference #{header[CGI_GENOME_REFERENCE]} doesn't match  #{self.genome_reference.build_name}.  Make sure that the value for CGI_GENOME_REFERENCE in config/environment.rb is correct.")
	    return 0
      end

      if header[CGI_SOFTWARE_PROGRAM].nil? then
        logger.error("ERROR: file_sample #{header[CGI_SAMPLE]} doesn't have a CGI_SOFTWARE_PROGRAM value.")
	    return 0
      end

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

  def check_isb_assembly_id
    if self.isb_assembly_id.nil? or !self.isb_assembly_id.match(/isb_asm/) then
      isb_assembly_id = "isb_asm_"+self.id.to_s
      self.isb_assembly_id = isb_assembly_id
      self.save
    end
  end

  def pedigree
    begin
      return self.assay.sample.person.pedigree
    rescue
      logger.error("Error with pedigree_id call for assembly #{self.inspect}")
      return nil
    end
  end

  # return an array.  Should only have one entry
  def varfiles
    return self.assembly_files.where(["file_type_id = ?", "1"])
  end


  def self.qualityChart(assembly)
    summ = assembly.assembly_files.where(["file_type_id = ?", "7"]).first # summary file
    return nil if summ.nil?
    # get Gross Mapping Yield (Gb), Fully called genome fraction, Fully called exome fraction, Genome fraction where weightSumSequenceCoverage >= 40x, Exome fraction where weightSumSequenceCoverage >=40x, SNP total count, SNP heterozygous/homozygous ratio, SNP transitions/transversions ratio, SNP novelty fraction
    fileKeys = ["Gross mapping yield (Gb)","Fully called genome fraction","Fully called exome fraction","Genome fraction where weightSumSequenceCoverage >= 40x","Exome fraction where weightSumSequenceCoverage >=40x","SNP total count","SNP heterozygous/homozygous ratio","SNP transitions/transversions ratio"]
    fileValues = {
           "Genome coverage - Gross mapping yield (Gb)" => { "MIN" => "136.975", "FIRST" => "167.663", "MEDIAN" => "180.157", "THIRD" => "194.508", "MAX" => "379.232"},
           "Genome coverage - Fully called genome fraction" => { "MIN" => "0.8644", "FIRST" => "0.963", "MEDIAN" => "0.968", "THIRD" => "0.972", "MAX" => "0.978"},
           "Exome coverage - Fully called exome fraction" => { "MIN" => "0.932", "FIRST" => "0.979", "MEDIAN" => "0.983", "THIRD" =>"0.985", "MAX" => "0.99" },
           "Genome coverage - Genome fraction where weightSumSequenceCoverage >= 40x" => { "MIN" => "0.466", "FIRST" => "0.63", "MEDIAN" => "0.682", "THIRD" => "0.765", "MAX" => "0.975" },
           "Exome coverage - Exome fraction where weightSumSequenceCoverage >=40x" => { "MIN" => "0.46", "FIRST" => "0.722", "MEDIAN" => "0.778", "THIRD" => "0.818", "MAX" => "0.988"},
           "Genome variations - SNP total count" => { "MIN" => "2880744", "FIRST" => "3444634", "MEDIAN" => "3475246", "THIRD" => "3506851", "MAX" => "4252714"},
           "Exome variations - SNP total count" => { "MIN" => "19751", "FIRST" => "22075", "MEDIAN" => "22315", "THIRD" => "22588", "MAX" => "27139"},
           "Genome variations - SNP heterozygous/homozygous ratio" => { "MIN" => "1.216", "FIRST" => "1.614", "MEDIAN" => "1.653", "THIRD" => "1.681", "MAX" => "2.357" },
           "Exome variations - SNP heterozygous/homozygous ratio" => { "MIN" => "1.329", "FIRST" => "1.681", "MEDIAN" => "1.728", "THIRD" => "1.781", "MAX" => "2.476"},
           "Genome variations - SNP transitions/transversions ratio" => { "MIN" => "2.059", "FIRST" => "2.108", "MEDIAN" => "2.123", "THIRD" => "2.134", "MAX" => "2.196"},
           "Exome variations - SNP transitions/transversions ratio" => { "MIN" => "2.689", "FIRST" => "2.942", "MEDIAN" => "2.983", "THIRD" => "3.027", "MAX" => "3.192" }
        }
    logger.debug("file values #{fileValues.inspect}")
    logger.debug("file keys #{fileKeys.inspect}")
    logger.debug("summary file #{summ.inspect}")
    results = Array.new
    File.open(summ.location).each_line do |line|
        logger.debug("line is #{line.inspect}")
        (category,type,value,scale) = line.split(/\t/)
        logger.debug("category #{category.inspect} type #{type.inspect} value #{value.inspect} scale #{scale.inspect}")
        next if scale and scale.match(/HIGH/)
        if fileKeys.include?(type.to_s) then
            logger.debug("found type #{type.inspect} in file!")
            local = Array.new
            local.push("#{category} - #{type}")
            local.push(value)
            results.push(local)
        end
    end
    logger.debug("results #{results.inspect}")
    return results
  end

end
