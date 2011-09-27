require 'fileutils'

namespace :receiving_report do

  # this parses the receiving report files - should only be done once
  desc "Read Receiving Report and upload information to database"
  task :upload_receiving_report, :filename, :study_root, :needs => [:environment] do |t,args|
    raise "No filename argument provided" if args[:filename].nil?
    raise "No study_root argument provided" if args[:study_root].nil?
    raise "File #{args[:filename]} does not exist." unless File.exists?(args[:filename])
    raise "File #{args[:filename]} not readable." unless File.readable?(args[:filename])
    raise "Directory #{args[:study_root]} does not exist." unless File.exists?(args[:study_root])
    study_root = args[:study_root]
    unless args[:study_root].match(/\/$/) then
       study_root = "#{args[:study_root]}/"
    end

    # nil is false
    DEBUG=nil

    default_ref_genome = GenomeReference.find_by_name("hg19").id
    puts "Default reference genome is hg19. Change this default by editing the lib/tasks/receivingreport.rake file if this changes."
    sleep 1
    puts "study root is #{study_root}"
    filename = args[:filename]
    file = File.open(filename)
    ref_genome = nil
    file.each do |line|
      line.chomp!
      if line.match("^#") then
        if line.match("Reference Genome:") then
	  (ref_key, ref_value) = line.split(/: /)
	  ref_value.downcase!
	  puts "found ref_key #{ref_key} ref_value #{ref_value}"
	  genome = GenomeReference.find_by_name(ref_value)
	  if genome.nil? then
	    raise "Couldn't find a genome_id for reference *#{ref_value}*"
	  end
	  ref_genome = genome.id
	end

	next
      end
      next if line.match("^>")
      if line.match("//") then
        ref_genome = nil
	next
      end

      fields = line.split("\t")
      unless fields.size == 13 or fields.size == 17 or fields.size == 28 or fields.size == 29
         puts "Incorrect number of fields: #{fields.size}: #{line}" 
      end

      # remove leading and ending whitespace
      fields.each_with_index do |f, index|
        f.strip!  
	puts "#{index} #{f}"
      end
      puts "line #{line}"

      if fields[2].match("CONTAMINATED") then
        puts "skipping sample due to contamination"
	puts "##########################################"
	next
      end

      if fields[2].match("FAILED CGI QC") then
        puts "skipping sample due failed cgi qc"
	puts "##########################################"
	next
      end 

      if fields[2].match("^$") and fields[3].match("^$") and fields[4].match("^$")  then
        puts "Genome hasn't been received yet: #{line}"
	puts "##########################################"
	next
      end

      study = Study.find_by_tag(fields[0])
      study = Study.find_by_name(fields[0]) if study.nil?
      puts "study #{study.inspect} for fields0 #{fields[0]}"
      raise "Could not find study for *#{fields[0]}*" if study.nil?

      pedigree = Pedigree.find_by_name(fields[1])
      if pedigree.nil? then
        pedigree = Pedigree.find_by_tag(fields[1])
      end
      if pedigree.nil? then
        pedigree = Pedigree.find_by_directory(fields[1])
      end

      if pedigree.nil? and ! study.nil?
        puts "need to manually update pedigree name in database or create it #{fields[1]}"
        exit
      end 
      raise "Could not find pedigree for #{fields[1]}" if pedigree.nil?
      puts "pedigree #{pedigree.inspect} for fields1 #{fields[1]}"

      ############################################
      # PERSON
      raise "ERROR: No way to find person with null fields #{fields[13]} #{fields[14]}" if fields[13].nil? and fields[14].nil?
      puts "finding person by #{fields[13]} or #{fields[14]}"
      p = Person.find_by_collaborator_id(fields[13])
      if p.nil? then
        p = Person.find_by_collaborator_id(fields[14])
      end

      if p.nil?
         puts "creating person"
	 cur_per = Person.new
	 cur_per.collaborator_id = fields[13]
	 cur_per.gender = fields[16]
	 cur_per.save unless DEBUG
	 p = cur_per
      end
      puts "found person #{p.inspect} for #{fields[13]} or #{fields[14]}"
      puts " "

      #######################################
      # MEMBERSHIP
      mems = Membership.find(:all, :conditions => { :person_id => p.id, :pedigree_id => pedigree.id})
      puts "multiple memberships found for person #{p.id} and pedigree #{pedigree.id}" if mems.size > 1
      mem = mems[0]
      if mem.nil? then
        puts "creating membership for person #{p.id} and pedigree #{pedigree.id}"
	cur_mem = Membership.new
	cur_mem.person_id = p.id
	cur_mem.pedigree_id = pedigree.id
	cur_mem.save unless DEBUG
	mem = cur_mem
      end
      puts "found membership #{mem.inspect}"
      puts " "

      ###############################################
      ### SAMPLE

      # can't create an acquisition because don't have the collaborator id to vendor id correlation
      if fields[11].empty? then
        puts "ERROR: No sample identification information for current line : #{fields[11]}"
	next
      end

      customer_sample_id = fields[11]
      puts "checking sample BEGIN#{customer_sample_id}END"
      sample = Sample.find_by_vendor_id(customer_sample_id)
      
	if sample.nil? then
          puts "creating new sample"
  	  cur_sample = Sample.new
	  cur_sample.vendor_id = customer_sample_id
	  cur_sample.status = 'sequenced'
	  cur_sample.comments = 'automatically created'
	  success = cur_sample.save unless DEBUG
	  success = 1 if DEBUG

	  if success then
            isb_sample_id = "isb_sample: #{cur_sample.id}"
	    cur_sample.isb_sample_id = isb_sample_id
	    puts "setting isb_sample_id to #{isb_sample_id}"
	    puts "created sample #{cur_sample.inspect}"
	    cur_sample.save unless DEBUG
	  else 
           raise "Failed to save sample."
	  end

 	  sample = cur_sample
	end

      puts "sample is #{sample.inspect} for customer_sample_id #{fields[13]} or customer_subject_id #{fields[14]}"

      puts " "

      ###############################################
      ## ACQUISITION
      unless p.nil? or sample.nil? then
        aqs = Acquisition.find(:all, :conditions => { :sample_id => sample.id, :person_id => p.id})
	puts "ERROR: multiple acquisitions" if aqs.size > 1
	aq = aqs[0]
        if aq.nil? then
          puts "created an acquisition for sample #{sample.id} and person #{p.id}"
	  cur_aq = Acquisition.new
	  cur_aq.person_id = p.id
	  cur_aq.sample_id = sample.id
	  cur_aq.save unless DEBUG
        else
          puts "found acquisition #{aq.inspect}"
        end
      end 

      puts " "

      ####################################
      # ASSAY
      #create or find assay
      puts "checking for assay of type sequencing with name vendor_did #{fields[9]} and sample id #{sample.id}"
      assays = Assay.find(:all, :conditions => { :name => fields[9], :assay_type => 'sequencing', :samples => {:id => sample.id} }, :include => :sample)
      puts "ERROR: Found multiple assays #{assays.inspect} for vendor_did #{fields[9]}" if assays.size > 1
      assay = assays[0]

      unless fields[2].nil? or fields[2].match(/^$/) then
       puts "WARN: Incorrect receiving date format #{fields[2]} for person #{fields[13]} or #{fields[14]}" unless fields[2].match(/\d+\/\d+\/\d+/) 
      end
      unless fields[3].nil? or fields[3].match(/^$/) then
       puts "WARN: Incorrect transferred date format #{fields[3]} for person #{fields[13]} or #{fields[14]}" unless fields[3].match(/\d+\/\d+\/\d+/) 
      end
      unless fields[4].nil? or fields[4].match(/^$/) then 
        puts "WARN: Incorrect backup date format #{fields[4]} for person #{fields[13]} or #{fields[14]}" unless fields[4].match(/\d+\/\d+\/\d+/)
      end
      unless fields[5].nil? or fields[5].match(/^$/) then
        puts "WARN: Incorrect qc pass date format #{fields[5]} for person #{fields[13]} or #{fields[14]}" unless fields[5].match(/\d+\/\d+\/\d+/)
      end

      if assay.nil? then
        cur_assay = Assay.new
	cur_assay.name = fields[9]
	cur_assay.assay_type = 'sequencing'
	cur_assay.vendor = fields[6]
	cur_assay.technology = 'CGI' if fields[6] == 'Complete Genomics'
	cur_assay.technology = 'Illumina' if fields[6] == 'Illumina'
	cur_assay.date_received = fields[2] unless fields[2].nil?
	cur_assay.date_transferred = fields[3] unless fields[3].nil?
	cur_assay.dated_backup = fields[4] unless fields[4].nil?
	cur_assay.qc_pass_date = fields[5] unless fields[5].nil?
	success_assay = cur_assay.save unless DEBUG
	success_assay = 1 if DEBUG
	if success_assay then
	  assay = cur_assay
	  puts "created and saved assay #{cur_assay.inspect}"
	else 
	  raise "error saving assay."
	end
      else
        puts "found assay"
      end

      puts "assay is #{assay.inspect}"

      puts " "
      ###################################################################
      ### SAMPLE_ASSAYS
      unless sample.nil? or assay.nil? then
        sas = SampleAssay.find(:all, :conditions => { :sample_id => sample.id, :assay_id => assay.id})
	puts "ERROR: multiple sample_assays" if sas.size > 1
	sa = sas[0]
        if sa.nil? then
          puts "created an sample_assay for sample #{sample.id} and assay #{assay.id}"
	  cur_sa = SampleAssay.new
	  cur_sa.assay_id = assay.id
	  cur_sa.sample_id = sample.id
	  cur_sa.save unless DEBUG
        else
          puts "found sample_assay #{sa.inspect}"
        end
      end 

      puts " "

      ###################################################################
      # ASSAY_FILES
      #create or find assay_files
      # set a default reference genome
      if ref_genome.nil? then
        ref_genome = default_ref_genome
      end

      study_name = fields[0]
      pedigree_name = fields[1]
      sample_name = nil
      assembly_name = fields[10]
      assembly_type = 'ASSEMBLY'

      puts "fields 6 is *#{fields[6]}*"
      if fields[6] == 'Illumina' then
        puts "Illumina handling started"
	sample_name = fields[11]
	assembly_dir = "IlluminaFormat/Assembly/#{fields[10]}"
	assembly_type = 'ILLUMINA-ASSEMBLY'
      else 
        puts "CGI Handling"
        sample_name = fields[11]
        assembly_dir = "#{fields[10]}/ASM"
      end 
      data_dir = "#{study_root}#{study_name}/sequence/#{pedigree_name}/#{sample_name}/#{assembly_dir}/"
      current = 1
      if fields[29] == 'Y' then # deprecated
        data_dir = "#{study_root}#{study_name}/sequence/#{pedigree_name}/deprecated/#{sample_name}/#{assembly_dir}/"
	current = 0
      end
      puts "data_dir is #{data_dir}"
      unless File.exists?(data_dir) then
        puts "ERROR: Assembly directory doesn't exists #{data_dir}"
	puts "#################################################"
	next
      end

      # create master ASSEMBLY for ancestry
      puts "finding assembly for file_type #{assembly_type} assay_id #{assay.id} current #{current} name #{assembly_name} genome reference #{ref_genome}"
      assemblies = AssayFile.find(:all, :conditions => { :file_type => assembly_type, :assay_id => assay.id, :current => current, :name => "#{assembly_name}", :genome_reference_id => ref_genome } )
      raise "Too many assemblies found #{assemblies.inspect}" if assemblies.size > 1
      assembly = assemblies[0]
      if (assembly.nil?) then
        puts "creating assembly for #{data_dir}"
        cur_af = AssayFile.new
        cur_af.assay_id = assay.id
        cur_af.name = assembly_name
        cur_af.location = data_dir
        cur_af.file_type = assembly_type
        cur_af.disk_id = fields[8]
        cur_af.software = "cgatools"
        cur_af.software_version = fields[7]
	cur_af.genome_reference_id = ref_genome
	cur_af.current = current
	puts "created af #{cur_af.inspect}"
	success_af = cur_af.save unless DEBUG
	success_af = 1 if DEBUG
	if success_af then
	  assembly = cur_af
	  puts "created and saved assembly #{cur_af.inspect}"
    	else 
	  raise "error saving assembly."
        end
     else 
       puts "found assembly #{assembly.inspect}"
       if assembly.location != data_dir then
         puts "updating assembly location from #{assembly.location} to #{data_dir}"
	 assembly.location = data_dir
	 assembly.save unless DEBUG
       else
         puts "assembly location is #{assembly.location}"
       end
     end

     puts "ERROR: No vendor specified in field 6 : #{fields[6]}" if fields[6].nil?
     if (fields[6] == "Complete Genomics") then 
      files = Hash.new
      files["VAR-ANNOTATION"] = { 
      						"loc" => "#{data_dir}var-#{assembly_name}.tsv.bz2",
						"name" => "var-#{assembly_name}.tsv.bz2",
						"software" => "dbsnptool"
				}
      files["GENE-ANNOTATION"] = { 
      						"loc" => "#{data_dir}gene-#{assembly_name}.tsv.bz2",
						"name" => "gene-#{assembly_name}.tsv.bz2",
						"software" => "callannotate"
				 }
      files["GENE-VAR-SUMMARY-REPORT"] = { 
      						"loc" => "#{data_dir}geneVarSummary-#{assembly_name}.tsv",
						"name" => "geneVarSummary-#{assembly_name}.tsv",
						"software" => "callannotate"
					}
      files["NCRNA-ANNOTATION"] = { 
	      					"loc" => "#{data_dir}ncRNA-#{assembly_name}.tsv.bz2",
						"name" => "ncRNA-#{assembly_name}.tsv.bz2",
						"software" => "dbsnptool"
      				  }
      files["CNV-SEGMENTS"] = { 
      						"loc" => "#{data_dir}CNV/cnvSegmentsBeta-#{assembly_name}.tsv",
						"name" => "cnvSegmentsBeta-#{assembly_name}.tsv",
						"software" => "CallCNVs"
			      }
      files["JUNCTIONS"] = { 
      						"loc" => "#{data_dir}SV/highConfidenceJunctionsBeta-#{assembly_name}.tsv",
						"name" => "highConfidenceJunctionsBeta-#{assembly_name}.tsv",
						"software" => "ExportWorkflow&ReportEngine"
			   }
      files["SUMMARY"] = {
      						"loc" => "#{data_dir}summary-#{assembly_name}.tsv",
						"name" => "summary-#{assembly_name}.tsv",
						"software" => "ExportWorkflow&ReportEngine"
			 }
      puts " "
      puts "files is #{files.inspect}"
      puts " "
      puts "----------"
      files.each do |file_type, file_vals|
        file_loc = file_vals["loc"]
	file_name = file_vals["name"]
	file_software = file_vals["software"]
	af = AssayFile.find(:first, :conditions => { :file_type => file_type, :assay_id => assay.id, :current => current, :genome_reference_id => ref_genome } )
        if af.nil?
          af2 = AssayFile.find(:first, :conditions => { :file_type => file_type, :location => file_loc })
	  if af2.nil?
	    if File.exists?(file_loc) then
              puts "creating assayfile for #{file_type} and #{file_loc}"
  	      cur_af = AssayFile.new
	      cur_af.assay_id = assay.id
	      cur_af.name = file_name
	      cur_af.location = file_loc
	      cur_af.file_type = file_type
	      cur_af.disk_id = fields[8]
	      cur_af.software = file_software
	      cur_af.software_version = fields[7]
	      cur_af.genome_reference_id = ref_genome
	      cur_af.current = current
	      cur_af.ancestry = assembly.id
	      puts "created af #{cur_af.inspect}"
	      success_caf = cur_af.save unless DEBUG
	      success_caf = 1 if DEBUG
	       if success_caf then
	         af = cur_af
	         puts "created and saved assay_file #{cur_af.inspect}"
    	       else 
	         raise "error saving assay_file."
              end
	   else
	      puts "file #{file_loc} not found on disk, not creating entry in database"
	    end
	  else 
	    puts "WARN: found assayfile2 for #{file_type} via location, not name : #{af2.inspect}"

	  end
        else 
          puts "found assayfile #{af.id} for #{file_type} : #{af.inspect}"
	  if file_loc != af.location then
	    if File.exists?(file_loc) then
	      puts "updating assayfile location: #{af.location} to #{file_loc}"
	      af.location = file_loc
	      af.save unless DEBUG
            end
	  end
        end
	puts " "
	puts "    ___________"
	puts " "
      end
      end # end if vendor[6] == Complete Genomics
      puts "######################################################"
    end # end each line

  end # end task upload_receiving_report

end
