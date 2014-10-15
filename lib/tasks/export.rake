namespace :export do

  #########################################################################################################
  ## SAMPLES
  #########################################################################################################

  desc "Export all samples to a single tab delimited file"
  task :export_all_samples => :environment do
    all_output = Array.new
    all_output.push(["Pedigree ID","Pedigree Tag","ISB Person ID","ISB Collaborator ID","Person Gender","Person Samples", "Person Vendor Sample IDs", "Sample Types"].join("\t"))
    Pedigree.all.each do |ped|
      output = single_sample(ped.id)
      all_output = all_output + output
    end
    filename = "gms_export_pedigree.txt"
    create_file(all_output, filename)

  end

  desc "Export all pedigrees to a individual tab delimited files"
  task :export_individual_samples => :environment do
    Pedigree.all.each do |ped|
      output = Array.new
      output.push(["Pedigree ID","Pedigree Tag","ISB Person ID","ISB Collaborator ID","Person Gender","Person Samples", "Person Vendor Sample IDs", "Sample Types"].join("\t"))
      output = output+ single_sample(ped.id)
      filename = "gms_export_pedigree_#{ped.id}.txt"
      create_file(output, filename)
    end

  end

  desc "Export one pedigree to a tab delimited file"
  task :export_sample, [:pedigree_id] => :environment do |t, args|
    pedigree_id = args[:pedigree_id]
    raise "No pedigree id provided" unless pedigree_id
    output = Array.new
    output.push(["Pedigree ID","Pedigree Tag","ISB Person ID","ISB Collaborator ID","Person Gender","Person Samples", "Person Vendor Sample IDs", "Sample Types"].join("\t"))
    output = output+ single_sample(pedigree_id)
    filename = "gms_export_pedigree_#{pedigree_id}.txt"
    create_file(output, filename)

  end

  def single_sample(pedigree_id)
    raise "No pedigree id provided" unless pedigree_id

    # want the format to be
    # isb_pedigree_id pedigree_tag isb_person_id collaborator_id gender isb_sample_id(csv) sample_vendor_id(csv)
    ped_output = Array.new
    ped = Pedigree.find(pedigree_id)
    ped.people.each do |person|
      samples = person.samples
      sample_ids = samples.collect { |s| s.isb_sample_id }.join(",")
      vendor_ids = samples.collect { |s| s.sample_vendor_id }.join(",")
      sample_types = samples.collect { |s| if s.sample_type then s.sample_type.name else 'unknown' end }.join(",")
      sample_ids = 'NONE' if sample_ids.empty?
      vendor_ids = 'NONE' if vendor_ids.empty?
      sample_types = 'NONE' if sample_types.empty?
      #puts "sample_ids are #{sample_ids.inspect} and vendor_ids are #{vendor_ids} for samples #{samples.inspect} and person #{person.inspect}"
      output = [ped.isb_pedigree_id, ped.tag, person.isb_person_id, person.collaborator_id, person.gender, sample_ids, vendor_ids, sample_types]
      ped_output.push(output.join("\t"))
    end
    return ped_output
  end

  #########################################################################################################
  ## INDIVIDUALS
  #########################################################################################################
  desc "Export individual information for each pedigree"
  task :export_individual, [:pedigree_id] => :environment do |t, args|
    pedigree_id = args[:pedigree_id]
    raise "No pedigree id provided" unless pedigree_id
    output = Array.new
    output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Father ID", "Mother ID","ISB Sample IDs","ISB Sample Vendor IDs","Sample Types","ISB Assay IDs", "Assay Names", "Assay Vendors", "Assay Technologies", "ISB Assembly IDs","Assembly Names","Assembly Locations", "Assembly Software Versions","Assembly Genome References"].join("\t"))
    output = output+ individual_by_pedigree(pedigree_id)
    filename = "gms_export_individual_pedigree_#{pedigree_id}.txt"
    create_file(output, filename)
  end

  desc "Export a combined file with individual information for each pedigree"
  task :export_all_individuals => :environment do
    output = Array.new
    output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Father ID", "Mother ID","ISB Sample IDs","ISB Sample Vendor IDs","Sample Types","ISB Assay IDs", "Assay Names", "Assay Vendors", "Assay Technologies", "ISB Assembly IDs","Assembly Names","Assembly Locations", "Assembly Software Versions","Assembly Genome References"].join("\t"))
    Pedigree.all.each do |ped|
      output = output+ individual_by_pedigree(ped.id)
    end
    filename = "gms_export_individual_pedigrees.txt"
    create_file(output, filename)
  end

  desc "Export individual pedigree individual information, process all pedigrees"
  task :export_individual_individual => :environment do
    Pedigree.all.each do |ped|
      output = Array.new
      output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Father ID", "Mother ID","ISB Sample IDs","ISB Sample Vendor IDs","Sample Types","ISB Assay IDs", "Assay Names", "Assay Vendors", "Assay Technologies", "ISB Assembly IDs","Assembly Names","Assembly Locations", "Assembly Software Versions","Assembly Genome References"].join("\t"))
      output = output+ individual_by_pedigree(ped.id)
      filename = "gms_export_individual_pedigree_#{ped.id}.txt"
      create_file(output, filename)
    end
  end

 
  def individual_by_pedigree(ped_id)
    raise "No pedigree id provided to individual_by_pedigree" unless ped_id
    ped = Pedigree.find(ped_id)
    ind_output = Array.new
    ped.people.each do |person|
      person_samples_id = Array.new
      person_samples_vendor_id = Array.new
      person_sample_types = Array.new
      person_assays_id = Array.new
      person_assays_name = Array.new
      person_assays_vendor = Array.new
      person_assays_technology = Array.new
      person_assemblies_id = Array.new
      person_assemblies_name = Array.new
      person_assemblies_location = Array.new
      person_assemblies_software_version = Array.new
      person_assemblies_genome_reference = Array.new
      person.samples.each do |sample|
        next if sample.assays.nil?
        person_samples_id.push(sample.isb_sample_id)
        person_samples_vendor_id.push(sample.sample_vendor_id)
        sample_type = sample.sample_type.nil? ? 'unknown' : sample.sample_type.name 
        person_sample_types.push(sample_type)
        sample.assays.each do |assay|
          person_assays_id.push("isb_asy_#{assay.id}")
          person_assays_name.push(assay.name)
          person_assays_vendor.push(assay.vendor)
          person_assays_technology.push(assay.technology)
          assay.assemblies.each do |asm|
            person_assemblies_id.push("isb_asm_#{asm.id}")
            person_assemblies_name.push(asm.name)
            person_assemblies_location.push(asm.location)
            person_assemblies_software_version.push(asm.software_version)
            person_assemblies_genome_reference.push(asm.genome_reference.name)
          end
        end
      end
      mother = person.mother.empty? ? 'NULL' : person.mother.first.isb_person_id
      father = person.father.empty? ? 'NULL' : person.father.first.isb_person_id
      output = [ped.study.tag, ped.isb_pedigree_id, ped.tag, person.isb_person_id, person.collaborator_id, person.gender, father, mother, person_samples_id.join(","), person_samples_vendor_id.join(","), person_sample_types.join(","), person_assays_id.join(","), person_assays_name.join(","), person_assays_vendor.join(","), person_assays_technology.join(","), person_assemblies_id.join(","), person_assemblies_name.join(","), person_assemblies_location.join(","), person_assemblies_software_version.join(","), person_assemblies_genome_reference.join(",")]
      ind_output.push(output.join("\t"))
    end
    return ind_output
  end




  #########################################################################################################
  ## ASSEMBLIES
  #########################################################################################################
  desc "Export assembly information for each pedigree"
  task :export_assembly, [:pedigree_id] => :environment do |t, args|
    pedigree_id = args[:pedigree_id]
    raise "No pedigree id provided" unless pedigree_id
    output = Array.new
    output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Father ID", "Mother ID","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "Assay Vendor", "Assay Technology", "ISB Assembly ID","Assembly Name","Assembly Location", "Assembly Software Version","Assembly Genome Reference"].join("\t"))
    output = output+ assembly_by_pedigree(pedigree_id)
    filename = "gms_export_assembly_pedigree_#{pedigree_id}.txt"
    create_file(output, filename)
  end

  desc "Export a combined file with assembly information for each pedigree"
  task :export_all_assemblies => :environment do
    output = Array.new
    output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Father ID", "Mother ID","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "Assay Vendor", "Assay Technology", "ISB Assembly ID","Assembly Name","Assembly Location", "Assembly Software Version","Assembly Genome Reference"].join("\t"))
    Pedigree.all.each do |ped|
      output = output+ assembly_by_pedigree(ped.id)
    end
    filename = "gms_export_assembly_pedigrees.txt"
    create_file(output, filename)
  end

  desc "Export individual pedigree assembly information, process all pedigrees"
  task :export_individual_assembly => :environment do
    Pedigree.all.each do |ped|
      output = Array.new
      output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Father ID", "Mother ID","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "Assay Vendor", "Assay Technology", "ISB Assembly ID","Assembly Name","Assembly Location", "Assembly Software Version","Assembly Genome Reference"].join("\t"))
      output = output+ assembly_by_pedigree(ped.id)
      filename = "gms_export_assembly_pedigree_#{ped.id}.txt"
      create_file(output, filename)
    end
  end

 
  def assembly_by_pedigree(ped_id)
    raise "No pedigree id provided to assembly_by_pedigree" unless ped_id
    ped = Pedigree.find(ped_id)
    asm_output = Array.new
    ped.people.each do |person|
      person.samples.each do |sample|
        next if sample.assays.nil?
        sample.assays.each do |assay|
	  assay.assemblies.each do |assembly|
        mother = person.mother.empty? ? 'NULL' : person.mother.first.isb_person_id
        father = person.father.empty? ? 'NULL' : person.father.first.isb_person_id
	    sample_type = sample.sample_type.nil? ? 'unknown' : sample.sample_type.name 
	    output = [ped.study.tag, ped.isb_pedigree_id, ped.tag, person.isb_person_id, person.collaborator_id, person.gender, father, mother, sample.isb_sample_id, sample.sample_vendor_id, sample_type, "isb_asy_#{assay.id}", assay.name, assay.vendor, assay.technology, "isb_asm_#{assembly.id}", assembly.name, assembly.location, assembly.software_version, assembly.genome_reference.name]
	    asm_output.push(output.join("\t"))
	  end
	end
      end
    end
    return asm_output
  end




  #########################################################################################################
  ## ASSEMBLY FILES
  #########################################################################################################
  desc "Export assembly file information for each pedigree"
  task :export_assembly_files, [:pedigree_id] => :environment do |t, args|
    pedigree_id = args[:pedigree_id]
    raise "No pedigree id provided" unless pedigree_id
    output = Array.new
    output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "ISB Assembly ID","Assembly Name","ISB Assembly File ID","Assembly File Type","Assembly File Location","Date of Assembly File"].join("\t"))
    output = output+ assembly_files_by_pedigree(pedigree_id)
    filename = "gms_export_assembly_file_pedigree_#{pedigree_id}.txt"
    create_file(output, filename)
  end

  desc "Export a combined file with assembly file information for each pedigree"
  task :export_all_assembly_files => :environment do
    output = Array.new
    output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "ISB Assembly ID","Assembly Name","ISB Assembly File ID","Assembly File Type","Assembly File Location","Date of Assembly File"].join("\t"))
    Pedigree.all.each do |ped|
      output = output+ assembly_files_by_pedigree(ped.id)
    end
    filename = "gms_export_assembly_file_pedigrees.txt"
    create_file(output, filename)
  end

  desc "Export individual pedigree assembly file information, process all pedigrees"
  task :export_individual_assembly_files => :environment do
    Pedigree.all.each do |ped|
      output = Array.new
      output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "ISB Assembly ID","Assembly Name","ISB Assembly File ID","Assembly File Type","Assembly File Location","Date of Assembly File"].join("\t"))
      output = output+ assembly_files_by_pedigree(ped.id)
      filename = "gms_export_assembly_file_pedigree_#{ped.id}.txt"
      create_file(output, filename)
    end
  end

 
  def assembly_files_by_pedigree(ped_id)
    raise "No pedigree id provided to assembly_files_by_pedigree" unless ped_id
    ped = Pedigree.find(ped_id)
    af_output = Array.new
    ped.people.each do |person|
      person.samples.each do |sample|
        next if sample.assays.nil?
        sample.assays.each do |assay|
	  assay.assemblies.each do |assembly|
	    assembly.assembly_files.each do |file|
	      sample_type = sample.sample_type.nil? ? 'unknown' : sample.sample_type.name 
	      output = [ped.study.tag, ped.isb_pedigree_id, ped.tag, person.isb_person_id, person.collaborator_id, person.gender, sample.isb_sample_id, sample.sample_vendor_id, sample_type, "isb_asy_#{assay.id}", assay.name, "isb_asm_#{assembly.id}", assembly.name, "isb_asmfile_#{file.id}", file.file_type.type_name, file.location, file.file_date]
	      af_output.push(output.join("\t"))
	    end
	  end
	end
      end
    end
    return af_output
  end

  #########################################################################################################
  ## ASSEMBLY FILES WITH STATUS
  #########################################################################################################
  desc "Export assembly file information for each pedigree"
  task :export_assembly_files_status, [:pedigree_id] => :environment do |t, args|
    pedigree_id = args[:pedigree_id]
    raise "No pedigree id provided" unless pedigree_id
    output = Array.new
      output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Affected","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "ISB Assembly ID","Assembly Name","ISB Assembly File ID","Assembly File Type","Assembly File Location","Date of Assembly File"].join("\t"))
    output = output+ assembly_files_by_status_pedigree(pedigree_id)
    filename = "gms_export_assembly_file_status_pedigree_#{pedigree_id}.txt"
    create_file(output, filename)
  end

  desc "Export a combined file with assembly file information for each pedigree"
  task :export_all_assembly_files_status => :environment do
    output = Array.new
      output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Affected","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "ISB Assembly ID","Assembly Name","ISB Assembly File ID","Assembly File Type","Assembly File Location","Date of Assembly File"].join("\t"))
    Pedigree.all.each do |ped|
      output = output+ assembly_files_by_status_pedigree(ped.id)
    end
    filename = "gms_export_assembly_file_status_pedigrees.txt"
    create_file(output, filename)
  end

  desc "Export individual pedigree assembly file information, process all pedigrees"
  task :export_individual_assembly_files_status => :environment do
    Pedigree.all.each do |ped|
      output = Array.new
      output.push(["Study","Pedigree ID", "Pedigree Tag","ISB Person ID","ISB Collaborator ID","Gender","Affected","ISB Sample ID","ISB Sample Vendor ID","Sample Type","ISB Assay ID", "Assay Name", "ISB Assembly ID","Assembly Name","ISB Assembly File ID","Assembly File Type","Assembly File Location","Date of Assembly File"].join("\t"))
      output = output+ assembly_files_by_status_pedigree(ped.id)
      filename = "gms_export_assembly_file_status_pedigree_#{ped.id}.txt"
      create_file(output, filename)
    end
  end

 
  def assembly_files_by_status_pedigree(ped_id)
    raise "No pedigree id provided to assembly_files_by_status_pedigree" unless ped_id
    ped = Pedigree.find(ped_id)
    af_output = Array.new
    ped.people.each do |person|
      person.samples.each do |sample|
        next if sample.assays.nil?
        affected = 'N'
        affected = 'Y' if person.conditions.size > 0
        sample.assays.each do |assay|
	  assay.assemblies.each do |assembly|
	    assembly.varfiles.each do |file|
	      sample_type = sample.sample_type.nil? ? 'unknown' : sample.sample_type.name 
	      output = [ped.study.tag, ped.isb_pedigree_id, ped.tag, person.isb_person_id, person.collaborator_id, person.gender, affected, sample.isb_sample_id, sample.sample_vendor_id, sample_type, "isb_asy_#{assay.id}", assay.name, "isb_asm_#{assembly.id}", assembly.name, "isb_asmfile_#{file.id}", file.file_type.type_name, file.location, file.file_date]
	      af_output.push(output.join("\t"))
	    end
	  end
	end
      end
    end
    return af_output
  end



  ##########################################################################################################
  ### UTIL
  ##########################################################################################################
  

  def exportdir_exists
    if !File.exists?(EXPORT_DIR) then
      Dir.mkdir(EXPORT_DIR)
    end
  end

  def create_file(output, filename)
    exportdir_exists
    full_path =  EXPORT_DIR + '/' unless EXPORT_DIR.match('/$')
    full_path = "#{full_path}#{filename}"
    #puts "full path #{full_path}"
    string = output.join("\n")
    File.open(full_path, 'w') do |f|
      f.puts string
    end
    raise "ERROR: pedigree export #{full_path} not created" unless File.exists?(full_path)
  end

end
