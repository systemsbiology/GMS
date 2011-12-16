require 'find'
require 'utils'

class Assembly < ActiveRecord::Base
  belongs_to :assay
  belongs_to :genome_reference
  has_many :assembly_files
  after_save :ensure_files_up_to_date

  auto_strip_attributes :name, :location, :description, :metadata, :software, :software_version, :comments
  validate :validates_assembly_directory
  validates_presence_of :name, :genome_reference_id, :assay, :location, :software, :software_version, :file_date
  validates_uniqueness_of :name, :location

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
    add_files,update_files = check_assembly_files(files)
    add_assembly_files(add_files)
    update_assembly_files(update_files)
  end

  # look on disk for the assembly files specified in the config under PEDIGREE_ROOT
  def find_assembly_files
    start_dir = self.location
    files = Hash.new
    Find.find(start_dir) do |path|
      filename = File.basename(path).split("/").last
      CGI_FILES.each { |filepart, filetype| 
        if filename.match(filepart) then 
          files[filetype] = path
        end
      }
    end

    return files
  end

  # look in the database for the assembly files
  def check_add_assembly_files(files=self.find_assembly_files)
    add = Hash.new
    files.each do |file_type, file_path|
      # returns an array
      filename = File.basename(file_path)
      af = AssemblyFile.where(:file_type => file_type, :name => filename)

      if af.size == 0 then
	add[file_path] = file_type
      end

    end

    return add
  end

  # look in the database for the assembly files
  def check_update_assembly_files(files=self.find_assembly_files)
    update = Hash.new
    files.each do |file_type, file_path|
      # returns an array
      filename = File.basename(file_path)
      af = AssemblyFile.find_by_name(filename)

      if !af.nil? then
        if af.location != file_path then
	  puts "updating file #{file_path} #{af.inspect}"
	  update[af.id] = Hash.new
          update[af.id]['path'] = file_path
	  update[af.id]['type'] = file_type
	end
      end

    end

    return update
  end

  def add_assembly_files(files=self.check_add_assembly_files)
    files.each do |file_path, file_type|
      file_type_id = FileType.find_by_type_name(file_type).id
      # header returns the top of the file, use variables in environment.rb to 
      # figure out what the names of the fields are that we're looking for
      # so that the fields are easily updatable 
      header = file_header(file_path)
      if header[CGI_ASSEMBLY_ID] and header[CGI_ASSEMBLY_ID] != self.name then
        puts("ERROR: file assembly name #{header[CGI_ASSEMBLY_ID]} doesn't match self assembly id #{self.name}.  Make sure that the value for CGI_ASSEMBLY_ID in config/environment.rb is correct.")
	next
      end

      if header[CGI_GENOME_REFERENCE] and header[CGI_GENOME_REFERENCE] != self.genome_reference.build_name then
        puts("ERROR: file genome_reference #{header[CGI_GENOME_REFERENCE]} doesn't match  #{self.genome_reference.build_name}.  Make sure that the value for CGI_GENOME_REFERENCE in config/environment.rb is correct.")
        next
      end

      if header[CGI_SAMPLE] and header[CGI_SAMPLE] != self.assay.sample.sample_vendor_id then
        puts("ERROR: file sample #{header[CGI_SAMPLE]} doesn't match #{self.assay.sample.sample_vendor_id}.  Make sure that the value for CGI_SAMPLE in config/environment.rb is correct.")
	next
      end

#  CGI uses GENE-ANNOTATION for ncRNA file but we want to be more specific, so we can't check unless we add exceptions.
#      if header[CGI_FILE_TYPE] and header[CGI_FILE_TYPE] != file_type then
#        puts("ERROR: file type #{header[CGI_FILE_TYPE]} doesn't match #{file_type}.  Make sure that the value for CGI_FILE_TYPE in config/environment.rb is correct.")
#	next
#      end

      xml = header.to_xml(:root => "assembly-file")
      filename = File.basename(file_path)
      assembly_file = AssemblyFile.new( 
      					:genome_reference_id => self.genome_reference_id,
					:assembly_id => self.id,
      					:file_type_id => file_type_id, 
					:name => filename,
      					:location => file_path, 
					:file_type => file_type,
					:file_date => creation_time(file_path),
					:software => header[CGI_SOFTWARE_PROGRAM],
					:software_version => header[CGI_SOFTWARE_VERSION],
					:current => 1,
					:metadata => xml
					)

      puts "adding assembly_file #{assembly_file.inspect}"
      assembly_file.save! # exclamation point forces it to raise an error if the save fails
    end # end files.each

  end

  def update_assembly_files(files=self.check_update_assembly_files)
    puts "update_assembly_files says files are #{files.inspect}\n\n"
    files.each do |assembly_file_id, innerhash|
      file_type = innerhash["type"]
      file_path = innerhash["path"]
      puts "updating #{file_type} and #{file_path}"

      assembly_file = AssemblyFile.find(assembly_file_id)

      file_type_id = FileType.find_by_type_name(file_type).id
      # header returns the top of the file, use variables in environment.rb to 
      # figure out what the names of the fields are that we're looking for
      # so that the fields are easily updatable 
      header = file_header(file_path)
      if header[CGI_ASSEMBLY_ID] and header[CGI_ASSEMBLY_ID] != self.name then
        puts("ERROR: file assembly name #{header[CGI_ASSEMBLY_ID]} doesn't match self assembly id #{self.name}.  Make sure that the value for CGI_ASSEMBLY_ID in config/environment.rb is correct.")
	next
      end

      if header[CGI_GENOME_REFERENCE] and header[CGI_GENOME_REFERENCE] != self.genome_reference.build_name then
        puts("ERROR: file genome_reference #{header[CGI_GENOME_REFERENCE]} doesn't match  #{self.genome_reference.build_name}.  Make sure that the value for CGI_GENOME_REFERENCE in config/environment.rb is correct.")
        next
      end

      if header[CGI_SAMPLE] and header[CGI_SAMPLE] != self.assay.sample.sample_vendor_id then
        puts("ERROR: file sample #{header[CGI_SAMPLE]} doesn't match #{self.assay.sample.sample_vendor_id}.  Make sure that the value for CGI_SAMPLE in config/environment.rb is correct.")
	next
      end

      xml = header.to_xml(:root => "assembly-file")
      filename = File.basename(file_path)
      assembly_file.update_attributes( 
      					"genome_reference_id" => self.genome_reference_id,
					"assembly_id" => self.id,
      					"file_type_id" => file_type_id, 
					"name" => filename,
      					"location" => file_path, 
					"file_date" => creation_time(file_path),
					"software" => header[CGI_SOFTWARE_PROGRAM],
					"software_version" => header[CGI_SOFTWARE_VERSION],
					"current" => 1,
					"metadata" => xml
					)

    end
  end

  def identifier
    "#{name} - #{GenomeReference.find(genome_reference_id).name} - #{software_version}"
  end

end
