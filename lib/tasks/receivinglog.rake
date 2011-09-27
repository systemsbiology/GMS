require 'fileutils'

namespace :receiving_log do

  desc "Read Receiving Log and upload information to database"
  task :upload_receiving_log, :filename, :study_root, :needs => [:environment] do |t,args|
    raise "No filename argument provided" if args[:filename].nil?
    raise "No study_root argument provided" if args[:study_root].nil?
    raise "File #{args[:filename]} does not exist." unless File.exists?(args[:filename])
    raise "File #{args[:filename]} not readable." unless File.readable?(args[:filename])
    raise "Directory #{args[:study_root]} does not exist." unless File.exists?(args[:study_root])
    study_root = args[:study_root]
    unless args[:study_root].match(/\/$/) then
       study_root = "#{args[:study_root]}/"
    end
    default_ref_genome = GenomeReference.find_by_name("hg19").id
    puts "Default reference genome is hg19 with id #{default_ref_genome}. Change this default by editing the lib/tasks/receivinglog.rake file if this changes."
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
	  genome_id = GenomeReference.find_by_name(ref_value).id
	  if genome_id.nil? then
	    raise "Couldn't find a genome_id for reference #{ref_value}"
	  end
	  puts "setting ref_genome to genome_id #{genome_id}"
	  ref_genome = genome_id
	end

	next
      end
      next if line.match("^>")
      if line.match("//") then
        ref_genome = ''
	next
      end
      # fields timestamp study vendor_pedigree date_received date_transferred dated_backup qc_pass_date vendor seuqencer_version diskID vendorID assemblyID SampleID
      fields = line.split("\t")
      unless fields.size == 13 or fields.size == 17 or fields.size == 29 or fields.size == 30
         puts "Incorrect number of fields: #{fields.size}: #{line}" 
         next
      end
      fields.each do |f|
        f.strip!  # removes leading and ending whitespace
      end
      puts "line #{line}"

# this code works but is unnecessary since we don't create anything above the samples table
      study = Study.find_by_tag(fields[1])
      puts "study #{study.inspect} for fields1 #{fields[1]}"
      raise "Could not find study for *#{fields[1]}*" if study.nil?

      pedigree = Pedigree.find_by_name(fields[2])
      if pedigree.nil? then
        pedigree = Pedigree.find_by_tag(fields[2])
      end
      if pedigree.nil? then
        pedigree = Pedigree.find_by_directory(fields[2])
      end

      if pedigree.nil? and ! study.nil?
        puts "need to manually update pedigree name in database or create it #{fields[2]}"
        exit
      end 
      raise "Could not find pedigree for #{fields[2]}" if pedigree.nil?
      puts "pedigree #{pedigree.inspect} for fields2 #{fields[2]}"

      # can't create an acquisition because don't have the collaborator id to vendor id correlation
      if fields[12].empty? then
        puts "ERROR: No sample identification information for current line : #{line}"
	next
      end

      sample_id = fields[12]
      puts "checking sample BEGIN#{sample_id}END"
      sample = Sample.find_by_vendor_id(sample_id)
      
      if sample.nil?
          puts "creating new sample"
  	  cur_sample = Sample.new
	  cur_sample.vendor_id = sample_id
	  cur_sample.status = 'sequenced'
	  cur_sample.comments = 'automatically created'
#	  success = cur_sample.save
#	  if success then
            isb_sample_id = "isb_sample: #{cur_sample.id}"
	    cur_sample.isb_sample_id = isb_sample_id
	    puts "setting isb_sample_id to #{isb_sample_id}"
#	    cur_sample.save
#	  else 
#           raise "Failed to save sample."
#	  end
 	  sample = cur_sample
      end

      puts "sample is #{sample.inspect} for vendor id #{fields[12]}"

      #create or find assay
      puts "checking for assay of type sequencing with name #{fields[10]}"
      assay = Assay.find(:first, :conditions => { :name => fields[10], :assay_type => 'sequencing'})

      puts "assay before #{assay.inspect}"

      if assay.nil? then
        cur_assay = Assay.new
	cur_assay.name = fields[10]
	cur_assay.assay_type = 'sequencing'
	cur_assay.vendor = fields[7]
	cur_assay.technology = 'CGI' if fields[7] == 'Complete Genomics'
	cur_assay.date_received = fields[3] unless fields[3].nil?
	cur_assay.date_transferred = fields[4] unless fields[4].nil?
	cur_assay.dated_backup = fields[5] unless fields[5].nil?
	cur_assay.qc_pass_date = fields[6] unless fields[6].nil?
#	success = cur_assay.save
#	if success then
	  assay = cur_assay
	  puts "created and saved assay"
#	else 
#	  raise "error saving assay."
#	end
      else
        puts "found assay"
      end

      puts "assay is #{assay.inspect}"

      #create or find assay_files
      # set a default reference genome
      if ref_genome.nil? then
        puts "setting ref_genome to default #{default_ref_genome}"
        ref_genome = default_ref_genome
      end

      #fields[1] = study
      #fields[2] = pedigree
      #fields[12] = sample_id
      #fields[11] = assembly_id
      data_dir = "#{study_root}#{fields[1]}/sequence/#{fields[2]}/#{fields[12]}/#{fields[11]}/ASM/"
      puts "data_dir is #{data_dir}"

      # create master ASSEMBLY for ancestry
      puts "finding assembly using #{fields[11]} for name and ref_genome #{ref_genome}"
      assembly = AssayFile.find(:first, :conditions => { :file_type => 'ASSEMBLY', :assay_id => assay.id, :current => 1, :name => "#{fields[11]}", :genome_reference_id => ref_genome } )
      if (assembly.nil?) then
        puts "creating assembly"
        cur_af = AssayFile.new
        cur_af.assay_id = assay.id
        cur_af.name = #{fields[11]}
        cur_af.location = #{data_dir}
        cur_af.file_type = "ASSEMBLY"
        cur_af.disk_id = fields[9]
        cur_af.software = "cgatools"
        cur_af.software_version = fields[8]
	cur_af.genome_reference_id = ref_genome
	cur_af.current = 1
	puts "created af #{cur_af.inspect}"
#	success = cur_af.save
#	if success then
	  assembly = cur_af
	  puts "created and saved assembly"
#    	else 
#	  raise "error saving assembly."
#        end
     end

      files = Hash.new
      files["VAR-ANNOTATION"] = { 
      						"loc" => "#{data_dir}var-#{fields[11]}.tsv.bz2",
						"name" => "var-#{fields[11]}.tsv.bz2",
						"software" => "dbsnptool"
				}
      files["GENE-ANNOTATION"] = { 
      						"loc" => "#{data_dir}gene-#{fields[11]}.tsv.bz2",
						"name" => "gene-#{fields[11]}.tsv.bz2",
						"software" => "callannotate"
				 }
      files["GENE-VAR-SUMMARY-REPORT"] = { 
      						"loc" => "#{data_dir}geneVarSummary-#{fields[11]}.tsv",
						"name" => "geneVarSummary-#{fields[11]}.tsv",
						"software" => "callannotate"
					}
      files["NCRNA-ANNOTATION"] = { 
	      					"loc" => "#{data_dir}ncRNA-#{fields[11]}.tsv.bz2",
						"name" => "ncRNA-#{fields[11]}.tsv.bz2",
						"software" => "dbsnptool"
      				  }
      files["CNV-SEGMENTS"] = { 
      						"loc" => "#{data_dir}CNV/cnvSegmentsBeta-#{fields[11]}.tsv",
						"name" => "cnvSegmentsBeta-#{fields[11]}.tsv",
						"software" => "CallCNVs"
			      }
      files["JUNCTIONS"] = { 
      						"loc" => "#{data_dir}SV/highConfidenceJunctionsBeta-#{fields[11]}.tsv",
						"name" => "highConfidenceJunctionsBeta-#{fields[11]}.tsv",
						"software" => "ExportWorkflow&ReportEngine"
			   }

      puts "files is #{files.inspect}"
      files.each do |file_type, file_vals|
        file_loc = file_vals["loc"]
	file_name = file_vals["name"]
	file_software = file_vals["software"]
	af = AssayFile.find(:first, :conditions => { :file_type => file_type, :assay_id => assay.id, :current => 1 } )
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
	      cur_af.disk_id = fields[9]
	      cur_af.software = file_software
	      cur_af.software_version = fields[8]
	      cur_af.genome_reference_id = ref_genome
	      cur_af.current = 1
	      cur_af.ancestry = assembly.id
	      puts "created af #{cur_af.inspect}"
#	      success = cur_af.save
#	       if success then
	         af = cur_af
	         puts "created and saved assay_file"
#    	       else 
#	         raise "error saving assay_file."
#              end
	   else
	      puts "file #{file_loc} not found on disk, not creating entry in database"
	    end
	  else 
	    puts "found assayfile2 for #{file_type} : #{af2.inspect}"
	  end
        else 
          puts "found assayfile #{af.id} for #{file_type} : #{af.inspect}"
        end
      end
      
      puts "######################################################"
    end # end each line

  end # end task upload_receiving_log

end
