#
require 'csv'
namespace :import do

    # should have a header that contains
    # #study_name
    # #study_tag
    # #collaborator
    # #collaborating_institution
    # Then lines of data
    desc "Import information from a tsv file"
    task :import_tsv_metadata, [:filename, :person_index, :sample_index, :sample_type_info, :assay_index, :assay_technology, :assembly_index, :pedigree_name_index, :pedigree_tag_index] => [:environment] do |t, args|
        raise "No filename provided" unless args[:filename]
        raise "No person_index provided" unless args[:person_index]
        raise "No sample_index provided" unless args[:sample_index]
        raise "No sample_type_info provided" unless args[:sample_type_info] # either a string or an index
        raise "No assay_index provided" unless args[:assay_index]
        raise "No assay_technology provided" unless args[:assay_technology] # either a string or an index
        raise "No assembly_index provided" unless args[:assembly_index]
        raise "No pedigree_name_index provided" unless args[:pedigree_name_index]

        workspace = "/tmp"

        f = File.open(args[:filename],"r")
        study = ''
        skip = nil
        f.each_line do |line|
            break unless line.match("^#")
            line.gsub!(/#/,'')
            line.strip!
            data = line.split(/\t/)
            if (data.size > 2) then
                puts "in size > 2"
                indexes = data.each_index.select{|i| data[i] == "Redacted/Excluded"}
                if indexes.size > 0 then
                    skip = indexes[0]
                end
                next
            end
            puts "data #{data.inspect}"
            if (data[0].match(/study_name/)) then
                study_name = data[1]
                study = Study.find_by_name(study_name) || Study.new
                study.name = study_name if study.name.nil? or study.name.empty?
            elsif (data[0].match(/study_tag/)) then
                study.tag = data[1] if study.tag.nil? or study.tag.empty?
            elsif (data[0].match("collaborator")) then
                study.collaborator = data[1] if study.collaborator.nil? or study.collaborator.empty?
            elsif (data[0].match(/collaborating_institution/)) then
                study.collaborating_institution = data[1] if study.collaborating_institution.nil? or study.collaborating_institution.empty?
            end
        end
        puts "skip is #{skip}"
        puts "study #{study.inspect}"
        puts "valid? #{study.valid?}"
        raise "Study not valid! #{study.errors.inspect}" unless study.valid?
        study.save
        puts "study #{study.inspect}"
        f.each_line do |line|
            line.strip!
            data = line.split(/\t/)
            if (! skip.nil? && data[skip].match(/TRUE/);) then
                puts "skipping Sample because it is redacted #{data.inspect}"
                next
            end
            # assign data
            person_name =data[args[:person_index].to_i]
            sample_vendor_id =data[args[:sample_index].to_i]
            if (args[:sample_type_info].is_a? String) then
                sample_type = SampleType.find_by_name(args[:sample_type_info].to_s)
            else 
                sample_type = SampleType.find_by_name(data[args[:sample_type_info].to_i].to_s)
            end
            raise("Unable to find sample_type for type #{args[:sample_type_info]}") if sample_type.nil?
            assay_name =data[args[:assay_index].to_i]
            assembly_name =data[args[:assembly_index].to_i]
            pedigree_name =data[args[:pedigree_name_index].to_i]
            if (args[:pedigree_tag_index].nil?) then
                puts "Setting pedigree tag to pedigree name"
                pedigree_tag = pedigree_name
            else
                pedigree_tag =data[args[:pedigree_tag_index].to_i]
            end
            puts "sample #{sample_vendor_id} assay #{assay_name} assembly #{assembly_name} pedigree_name #{pedigree_name}"
            next if sample_vendor_id.empty? or sample_vendor_id.match("^NA$") or sample_vendor_id.match("^ND$")
            next if assay_name.empty? or assay_name.match("^NA$") or assay_name.match("^ND$")
            next if assembly_name.empty? or assembly_name.match("^NA$") or assembly_name.match("^ND$")
            next if pedigree_name.empty? or pedigree_name.match("^NA$") or pedigree_name.match("^ND$")
            next if pedigree_tag.empty? or pedigree_tag.match("^NA$") or pedigree_tag.match("^ND$")
            puts "data #{data.inspect}"

            # create pedigree
            pedigree = Pedigree.find_by_name(pedigree_name) || Pedigree.new
            pedigree.name = pedigree_name if pedigree.name.nil? or pedigree.name.empty?
            pedigree.tag = pedigree_tag if pedigree.tag.nil? or pedigree.tag.empty?
            pedigree.study_id = study.id
            puts "pedigree valid? #{pedigree.valid?}"
            puts "pedigree #{pedigree.inspect}"

            raise "Pedigree not valid #{pedigree.errors.inspect}" unless pedigree.valid?
            pedigree.save

            # create person
            puts "person_name #{person_name}"
            if person_name.match("^NA$") then
                puts "skipping person because name is NA - #{data.inspect}"
                next
            end
            person = Person.find_by_collaborator_id(person_name) || Person.new
            person.collaborator_id = person_name if person.collaborator_id.nil? or person.collaborator_id.empty?
            # for the inova studies gender is defined by the collaborator id
            if person_name.match(/^M-/) then
                gender = "female"
            elsif person_name.match(/^F-/) then
                gender = "male"
            else
                gender = "Unknown"  # all newborns will be this until later when we upload the clinical file
            end
            person.gender = gender if person.gender.nil? or person.gender.empty?
            puts "person #{person.inspect}"
            puts "person valid? #{person.valid?}"

            raise "Person not valid #{person.errors.inspect}" unless person.valid?
            # create membership
            person.pedigree = pedigree
            person.save


            # create sample
            sample = Sample.find_by_sample_vendor_id(sample_vendor_id) || Sample.new
            sample.sample_vendor_id = sample_vendor_id if sample.sample_vendor_id.nil? or sample.sample_vendor_id.empty?
            puts "sample_type #{sample_type.inspect}"
            sample.sample_type_id = sample_type.id if sample.sample_type_id.nil? 
            puts "sample #{sample.inspect}"
            # sample status should be one of the following
            # | sequenced |
            # | failed qc |
            # | submitted |
            # | passed QC |
            # | failed    |
            sample.status = "sequenced"
            
            puts "sample valid? #{sample.valid?}"
            puts "sample #{sample.inspect}"

            raise "Sample not valid #{sample.errors.inspect}" unless sample.valid?
            sample.save
            sample.person = person

            # create assay
            assay = Assay.find_by_name(assay_name) || Assay.new
            assay.name = assay_name if assay.name.nil? or assay.name.empty?
            # assay_type should be sequencing or exome
            assay.assay_type = "sequencing"
            # assay_technology should be:
            #  Standard WGS                     
            #  Illumina                        
            #  Cancer WGS                       
            #  Agilent SureSelect 50Mb platform 
            if (args[:assay_technology].is_a? String) then
                assay_technology = args[:assay_technology].to_s
            else
                assay_technology = data[args[:assay_technology].to_i].to_s
            end
            assay.technology = assay_technology
            puts "assay #{assay.inspect}"
            puts "assay valid? #{assay.valid?}"
            raise "Assay not valid #{assay.errors.inspect}" unless assay.valid?
            assay.sample = sample
            assay.save

            
            # create assembly
            # need name, genome_reference_id, assay, location, software, software_version
            assembly = Assembly.find_by_name(assembly_name) || Assembly.new
            assembly.name = assembly_name if assembly.name.nil? or assembly.name.empty?
            assembly.genome_reference_id = 1 # hg19
            assembly.software = "cgatools"
            location = "s3://itmi.ptb/#{assay_name}/#{assembly_name}/#{sample_vendor_id}/ASM"
            assembly.location = location
            summaryFile = "summary-#{assembly_name}.tsv"
            summaryPath = "#{location}/#{summaryFile}"
            localPath = "#{workspace}/#{summaryFile}"
            puts "getting SummaryFile #{summaryPath}"
            begin
                system("s3cmd get #{summaryPath} #{localPath} --force")
            rescue Exception => e
                puts "exception #{e.inspect}"
                raise "Couldn't get file from s3 #{summaryPath}"
            end
            s = File.open(localPath, "r")
            s.each_line do |line|
                break if line.match("^$")
                if line.match("^#SOFTWARE_VERSION") then
                    puts "found software version #{line.inspect}"
                    line.strip!
                    (key, software_version) = line.split("\t")
                    puts "software version #{software_version}"
                end
            end
            s.close
            puts "software version #{software_version}"

            puts "removing localPath #{localPath}"
            begin
                system("rm #{localPath}")
            rescue Exception => e
                puts "Couldn't delete local file exception #{e.inspect}"
            end
            assembly.software_version = software_version unless software_version.nil?
            assembly.assay = assay
            puts "assembly #{assembly.inspect}"
            puts "assembly valid? #{assembly.valid?}"
            raise "Assembly not valid #{assembly.errors.inspect}" unless assembly.valid?
            assembly.save

            puts "\n\n"
        end
        f.close
    end

######################################################################################################
######################################################################################################
######################################################################################################
# IMPORT ExportForITMIFiles
######################################################################################################
######################################################################################################
######################################################################################################

	# load into assembly_files
    desc "Import ExportForITMIFiles type file"
    task :import_itmi_export, [:filename]=> [:environment] do |t,args|
        raise "No filename provided" unless args[:filename]

		workspace="/tmp"
		# 0=studyShortID, 1=familyCode, 2=cohortRole, 3=subjectLabel, 4=analysisType, 5=fileSizeInBytes,
		# 6=fileLocation, 7=awsVolume, 8=CaseWithdrawn, 9=MultipleBirth, 10=fileSizeInGB, 11=fileSizeInTB,
		# 12=itmiFileName, 13=fileCreateDate, 14=monthCreated, 15=yearCreated, 16=fileExtension,
		# 17=variantType, 18=plate, 19=awsTopBucket, 20=subjectID, 21=studyID, 22=familyID
        f = File.open(args[:filename],"r")
        f.each_line do |line|
			next if line.match(/^#/)
			line.chomp!
			puts "line #{line}"
			info = Array.new
			info = line.split(/,/)
			puts "#{info}"
			
			next if info[4].nil? or info[4].empty? 
            study = Study.find_by_tag(info[0])
			puts "study #{study.inspect}"
			family_id = info[0]+'-'+info[1]
			pedigree = Pedigree.find_by_name(family_id) || Pedigree.new
			pedigree.name = family_id if pedigree.name.nil? 
			pedigree.isb_pedigree_id = family_id if pedigree.isb_pedigree_id.nil?
			pedigree.tag = family_id if pedigree.tag.nil?
			pedigree.study_id = study.id if pedigree.study_id.nil?
			
            puts "pedigree valid? #{pedigree.valid?}"
            puts "pedigree #{pedigree.inspect}"

            raise "Pedigree not valid #{pedigree.errors.inspect}" unless pedigree.valid?
            pedigree.save

            # create person
            puts "info[3] #{info[3]}"
            if info[3].match("^NA$") then
                puts "skipping person because name is NA - #{info.inspect}"
                next
            end
            person = Person.find_by_collaborator_id(info[3]) || Person.new
            person.collaborator_id = info[3] if person.collaborator_id.nil? or person.collaborator_id.empty?
            # for the inova studies gender is defined by the collaborator id
            if info[3].match(/^M-/) then
                gender = "female"
            elsif info[3].match(/^F-/) then
                gender = "male"
			elsif info[2].match(/Grandmother/) then
				gender = "female"
			elsif info[2].match(/Grandfather/) then
				gender = "male"
			elsif info[2].match(/Aunt/) then
				gender = "female"
			elsif info[2].match(/Uncle/) then
				gender = "male"
            else
                gender = "Unknown"  # all newborns will be this until later when we upload the clinical file
            end
            person.gender = gender if person.gender.nil? or person.gender.empty?
            puts "person #{person.inspect}"
            puts "person valid? #{person.valid?}"

            raise "Person not valid #{person.errors.inspect}" unless person.valid?
            # create membership
            person.pedigree = pedigree
            person.save

			if info[6].nil? or info[6].empty? then
				puts "skipping files for person #{person.inspect} since they have no file"
				next
			end

			sequence_type = nil
			sample_vendor_id = nil
			assay_name = nil
			assembly_name = nil
			assay_technology = nil
			location = nil
			filename = nil
			assay_type = nil
            # create sample
            # microRNA
			if (info[4].match(/microRNA/) )
				sample_vendor_id,cell,suffix = info[8].split(/\./)
				topdir,eadir,assay_name,filename=info[6].split(/\//)
				assay_technology="EA microRNA"
				assembly_name = assay_name
				location = "s3://#{info[7]}/#{topdir}/#{eadir}/#{assay_name}/"
				sequence_type = "microRNA"
				assay_type = "microRNA"
            #
            # RNAseq
            elsif (info[4].match(/RNAseq/))
				if (info[6].split(/\//).length == 4) then
					topdir,eadir,assay_name,filename = info[6].split(/\//)
				else
					topdir,eadir,assay_name,statsdir,filename = info[6].split(/\//)
				end
				sample_vendor_id,version,merge,suffix = info[8].split(/\./)
				assay_technology="EA RNAseq GlobinClear"
				assembly_name = assay_name
				location = "s3://#{info[7]}/#{topdir}/#{eadir}/#{assay_name}/"
				sequence_type = "RNAseq"
				assay_type ="microRNA"
            #
            #WGS
			elsif (info[4].match(/WGS/))
				assay_type = "sequencing"
				if info[7].match(/illumina/) then
					file_array = info[6].split(/\//)
					print "file array #{file_array.inspect}\n"
					if file_array.count == 3 then
						sample_vendor_id,dir, filename = info[6].split(/\//)
					else 
						sample_vendor_id, filename = info[6].split(/\//)
					end
					assay_name = info[11]
					assay_technology = "Illumina"
					assembly_name = assay_name
					sequence_type = "Illumina"
					location = "s3://#{info[7]}/#{sample_vendor_id}"
				else
					assay_name, assembly_name, sample_vendor_id, lib, library, filename = info[6].split(/\//)
					assay_technology = "Standard WGS"
					sequence_type = "CGI"
					location = "s3://#{info[7]}/#{assay_name}/#{assembly_name}/#{sample_vendor_id}/ASM"
				end
			else
				raise "Unknown analysisType in spreadsheet #{info[4]} for #{info.inspect}"
			end
            puts "sample_vendor_id #{sample_vendor_id} assay_name #{assay_name}"
			if filename.match(/md5sum.txt/) then
				puts "not storing md5sum\n"
				next
			end
			customer_sample_id = info[4]+"_"+info[3]
            sample = Sample.find_by_sample_vendor_id(sample_vendor_id) || Sample.find_by_customer_sample_id(customer_sample_id) || Sample.new
            sample.sample_vendor_id = sample_vendor_id if sample.sample_vendor_id.nil? or sample.sample_vendor_id.empty?
			sample.customer_sample_id = customer_sample_id
            sample_type = SampleType.find_by_name("blood") # these are all blood
			sample.sample_type_id = sample_type.id if sample.sample_type_id.nil? 
            puts "sample #{sample.inspect}"
            # sample status should be one of the following
            # | sequenced |
            # | failed qc |
            # | submitted |
            # | passed QC |
            # | failed    |
            sample.status = "sequenced"
            
            puts "sample valid? #{sample.valid?}"
            puts "sample #{sample.inspect}"

            raise "Sample not valid #{sample.errors.inspect}" unless sample.valid?
            sample.save
            sample.person = person

            # create assay
            assay = Assay.find_by_name(assay_name) || Assay.new
            assay.name = assay_name if assay.name.nil? or assay.name.empty?
            # assay_type should be sequencing or exome
            assay.assay_type = assay_type
            # assay_technology should be:
            #  Standard WGS                     
            #  Illumina                        
            #  Cancer WGS                       
            #  Agilent SureSelect 50Mb platform 
            assay.technology = assay_technology
            puts "assay #{assay.inspect}"
            puts "assay valid? #{assay.valid?}"
            raise "Assay not valid #{assay.errors.inspect}" unless assay.valid?
            assay.sample = sample
            assay.save
            puts "assay is #{assay.inspect}" 
            # create assembly
            # need name, genome_reference_id, assay, location, software, software_version
            assembly = Assembly.find_by_name(assembly_name) || Assembly.new
            assembly.name = assembly_name if assembly.name.nil? or assembly.name.empty?
            assembly.genome_reference_id = 1 # hg19
			assembly.location = location
			if (assembly.software_version.nil?) then
				puts "RETRIEVING FILE TO FIND SOFTWARE VERSION\n"
				software = nil
				summaryFile = nil
				summaryPath = nil
				if sequence_type.match(/CGI/) then
					software = "cgatools"
					summaryFile = "summary-#{assembly_name}.tsv"
					summaryPath = "#{location}/#{summaryFile}"
				elsif sequence_type.match(/Illumina/) then
					software = "IsaacVariantCaller"
					summaryFile = "#{sample_vendor_id}.GenotypingReport.txt"
					summaryPath = "#{location}/Genotyping/#{summaryFile}"
				elsif sequence_type.match(/RNAseq/) then
					parts = filename.split(/\./)
					if (parts[1].match(/^D/) or parts[1].match(/^L/) or parts[1].match(/^V/)) then
						summaryFile = "#{parts[0]}.#{parts[1]}.summary.txt"
						summaryPath = "#{location}#{summaryFile}"
					else
						summaryFile = "#{parts[0]}.summary.txt"
						summaryPath = "#{location}#{summaryFile}"
					end
				elsif sequence_type.match(/microRNA/) then
					parts = filename.split(/\./)
					summaryFile = "#{parts[0]}.#{parts[1]}.sam.stats"
					summaryPath = "#{location}#{summaryFile}"
				else
					raise "no summary Path creation for type #{sequence_type}"
				end
				software_version = nil
				localPath = "#{workspace}/#{summaryFile}"
				puts "getting SummaryFile #{summaryPath}"
				begin
					system("s3cmd get #{summaryPath} #{localPath} --force")
				rescue Exception => e
					puts "exception #{e.inspect}"
					raise "Couldn't get file from s3 #{summaryPath}"
				end
				begin
					s = File.open(localPath, "r")
				rescue Exception => e
					next if (sequence_type.match(/microRNA/) and (filename.match(/M-101-018_L4\.LB27/) or filename.match(/M-101-102_L7\.LB35/) or filename.match(/M-101-179_L7.LB27/)))
					if (sequence_type.match(/RNAseq/)) then
						begin
							next if (filename.match(/102-08-01285-01_mg_L4/) or filename.match(/102-08-01286-01_mg/) or filename.match(/102-08-01289-01_mg/) or filename.match(/102-08-01290-01_mg/) or filename.match(/102-08-01293-01_mg/) or filename.match(/102-08-01308-01_mg/))
							puts "sequence_type #{sequence_type} filename #{filename}"
							parts = filename.split(/\./)
							versions = parts[1].split(/_/)
							versions.pop
							summaryFile = "#{parts[0]}.#{versions.join("_")}.summary.txt"
							summaryPath = "#{location}#{summaryFile}"
							system("s3cmd get #{summaryPath} #{localPath} --force")
							s = File.open(localPath,"r")
						rescue Exception => e
							puts "exception #{e.inspect}"
							raise "Couldn't get file from s3 #{summaryPath}"	
						end
					else
						raise "Couldn't get file from s3 #{summaryPath}"
					end
				end
				s.each_line do |line|
					break if line.match("^$")
					if line.match("^#SOFTWARE_VERSION") then
						puts "found software version #{line.inspect}"
						line.strip!
						(key, software_version) = line.split("\t")
						software = "cgatools"
						break
					elsif line.match(/^GSGT Version/) then
						puts "found illumina software version #{line.inspect}"
						line.strip!
						software, software_version = line.split("\t")
						break
					elsif line.match(/^version/) then
						puts "found microRNA sam stats version #{line.inspect}"
						line.strip!
						software = "SAM"
						version, software_version = line.split("\t")
						break
					elsif line.match(/^analysis--quantifier used/) then
						puts "found RNAseq version #{line.inspect}"
						line.strip!
						key, value = line.split("\t")
						software,software_version = value.split(" ")
						break
					end
				end
				s.close
				puts "removing localPath #{localPath}"
				begin
					system("rm #{localPath}")
				rescue Exception => e
					puts "Couldn't delete local file exception #{e.inspect}"
				end

				assembly.software = software
				assembly.software_version = software_version
				puts "software version #{software_version} software #{software}"
			end
            assembly.assay = assay
            puts "assembly #{assembly.inspect}"
            puts "assembly valid? #{assembly.valid?}"
            raise "Assembly not valid #{assembly.errors.inspect}" unless assembly.valid?
            assembly.save

			assembly_file = AssemblyFile.find_by_name(filename) || AssemblyFile.new
			assembly_file.genome_reference_id = 1 if assembly_file.genome_reference.nil?
			file_type = nil
			puts "filename is #{filename}"
			if (filename.match(/^var/)) then
				file_type = "VAR-ANNOTATION"
			elsif (filename.match(/^gene-/)) then
				file_type = "GENE-ANNOTATION"
			elsif (filename.match(/^geneVarSummary-/)) then
				file_type = "GENE-VAR-SUMMARY-REPORT"
			elsif (filename.match(/^masterVarBeta/)) then
				file_type = "VAR-OLPL"
			elsif (filename.match(/^ncRNA/)) then
				file_type = "NCRNA-ANNOTATION"
			elsif (filename.match(/^summary-/)) then
				file_type = "SUMMARY"
			elsif (filename.match(/^cnv/)) then
				file_type = "CNV-SEGMENTS"
			elsif (filename.match(/Junctions/)) then
				file_type = "JUNCTIONS"
			elsif (filename.match(/allSvEventsBeta/)) then
				file_type = "SVEVENTS"
			elsif (filename.match(/vcf/)) then
				file_type = "VCF-ANNOTATION"
			elsif (filename.match(/bam/)) then
				file_type = "BAM"
			elsif (filename.match(/\.cel/)) then
				file_type = "CEL"
			elsif (filename.match(/coverage-matrix/)) then
				file_type = "COVERAGE-MATRIX"
			elsif (filename.match(/rsem.genes.results/)) then
				file_type = "RNASEQ-GENES"
			elsif (filename.match(/rsem.isoforms.results/)) then
				file_type = "RNASEQ-ISOFORMS"
			elsif (filename.match(/rsem.cnt/) or filename.match(/rsem.model/) or filename.match(/rsem.theta/)) then
				file_type = "RNASEQ-RSEM-STATS"
			elsif (filename.match(/sam.stats/)) then
				file_type = "MICRORNA-SAM-STATS"
			elsif (filename.match(/summary.txt/)) then
				file_type = "RNASEQ-SUMMARY"
			elsif (filename.match(/transcript.stats/)) then
				file_type = "RNASEQ-TRANSCRIPT-STATS"
			elsif (filename.match(/.ercc.pdf$/)) then
				file_type = "RNASEQ-ERCC-REPORT"
			elsif (filename.match(/.mquant$/)) then
				file_type = "RNASEQ-MQUANT"
			elsif (filename.match(/SummaryReport.pdf$/)) then
				file_type = "ILLUMINA-SUMMARY-REPORT"
			elsif (filename.match(/.LOD.pdf$/)) then
				file_type = "RNASEQ-LOD"
			elsif (filename.match(/.knownGene.counts.gz/)) then
				file_type = 'MICRORNA-KNOWNGENE'
			elsif (filename.match(/.insert$/)) then
				file_type = "RNASEQ-INSERT"
			elsif (filename.match(/.wig$/) or filename.match(/.wig.gz$/)) then
				file_type = "RNASEQ-WIG"
			elsif (filename.match(/.sspec/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-SSPEC"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-SSPEC"
				else
					raise "filename #{filename} isn't sspec microRNA or RNAseq?? #{sequencing_type}"
				end

			elsif (filename.match(/.exprsum/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-EXPRSUM"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-EXPRSUM"
				else
					raise "filename #{filename} isn't exprsum microRNA or RNAseq?? #{sequencing_type}"
				end

			elsif (filename.match(/.adapters/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-ADAPTERS"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-ADAPTERS"
				else
					raise "filename #{filename} isn't adapters microRNA or RNAseq?? #{sequencing_type}"
				end

			elsif (filename.match(/.gc.out$/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-GC"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-GC"
				else
					raise "filename #{filename} isn't gc.out microRNA or RNAseq?? #{sequencing_type}"
				end
	
			elsif (filename.match(/.fastx$/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-FASTX"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-FASTX"
				else
					raise "filename #{filename} isn't microRNA or RNAseq?? #{sequencing_type}"
				end
			elsif (filename.match(/.fastq/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-FASTQ"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-FASTQ"
				else
					raise "filename #{filename} isn't microRNA or RNAseq?? #{sequencing_type}"
				end

			elsif (filename.match(/.fastx.png/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-FASTX-PNG"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-FASTX-PNG"
				else
					raise "filename #{filename} isn't microRNA or RNAseq?? #{sequencing_type}"
				end

			elsif (filename.match(/.fastq.stats/)) then
				if (sequence_type.match(/RNAseq/)) then
					file_type = "RNASEQ-FASTQ-STATS"
				elsif (sequence_type.match(/microRNA/)) then
					file_type = "MICRORNA-FASTQ-STATS"
				else
					raise "filename #{filename} isn't microRNA or RNAseq?? #{sequencing_type}"
				end

			else
				raise "file #{filename} doesn't match a file_type switch"
			end
				
			assembly_file.file_type_id = FileType.find_by_type_name(file_type)
			assembly_file.location = "s3://#{info[7]}/#{info[6]}"
			file_date = nil
			r, io = IO.pipe
			system("s3cmd ls #{assembly_file.location}",out: io, err: :out)
			io.close
			r.each_line{|l| file_date,file_rest = l.chomp.split(/  /) }
			puts "file_date #{file_date}"
			assembly_file.file_date = file_date
			assembly_file.software = assembly.software
			assembly_file.software_version = assembly.software_version
			assembly_file.name = filename
			assembly_file.assembly = assembly
			puts "assembly_file #{assembly_file.inspect}"
            puts "assembly_file valid? #{assembly_file.valid?}"
            raise "Assembly_file not valid #{assembly_file.errors.inspect}" unless assembly_file.valid?
            assembly_file.save

            puts "\n\n"

		end
		f.close
    end

######################################################################################################
######################################################################################################
######################################################################################################
# Import ITMIObfuscatedClinicalData
######################################################################################################
######################################################################################################
######################################################################################################


	#itmisubjectID,analysisQuestion,analysisAnswer,crfName,fieldValueOrdinal,studyName
	# load into assembly_files
    desc "Import ITMIObfuscatedClinicalDAta type file"
    task :import_itmi_obfuscated_clinical_data, [:filename]=> [:environment] do |t,args|
        raise "No filename provided" unless args[:filename]

		workspace="/tmp"
#itmisubjectID|analysisQuestion|analysisAnswer|crfName|fieldValueOrdinal|studyName
        f = File.open(args[:filename],"r:UTF-8")
        f.each_line do |line|
			puts "encoding #{line.encoding}"
			line.encode!('UTF-16', :undef => :replace, :invalid => :replace, :replace => "")
			line.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => "")
			
			puts "line #{line}"
			next if line.match(/^#/)
			line.chomp!
			info = Array.new
			line.gsub!(/I:0#\.F\|ADMEMBERS\|/,"I:0#.F;ADMEMBERS;")
			info = line.split(/\|/)
			raise "Incorrect number of lines #{info.inspect}" unless info.length == 6
			info[2] = info[2].titleize
			info[2].strip!
			info[2].lstrip!
			puts "#{info}"
			# find person
			p = Person.find_by_collaborator_id(info[0]) 
			puts "person #{info[0]} #{p.inspect}"
			if p.nil? then
				if info[0].match(/^F|M|NB/) then
					puts "creating new person with 101 study id"
					p = Person.new
					p.collaborator_id = info[0]
					p.isb_person_id = info[0]
					p.gender = 'Unknown'
					p.gender = 'female' if info[0].match(/^M/) # mother
					p.gender = 'male' if info[0].match(/^F/) # father
					idInfo = info[0].split(/-/)
					if (idInfo.length == 4) then
						member = idInfo[0..1].join("-")
						idInfo = idInfo[2..3]
					else
						member = idInfo.shift
					end
					puts "idInfo #{idInfo.inspect} member #{member}"
					study_tag = idInfo[0]
					family = idInfo.join("-")
				else
					puts "creating new person with 102 or 103 study id"
					p = Person.new
					p.collaborator_id = info[0]
					p.isb_person_id = info[0]
					p.gender = 'Unknown'
	#				p.gender = 'female' if info[0].match(/01$/) # mother
	#				p.gender = 'male' if info[0].match(/02$/) # father
					idInfo = info[0].split(/-/)
					member = idInfo.pop # end
					study_tag = idInfo[0]
					family = idInfo.join("-")
				end
				ped = Pedigree.find_by_name(family) || Pedigree.new
				ped.name = family
				ped.tag = family
				study = Study.find_by_tag(study_tag)
				raise "No study #{study} found" unless study
				puts "study #{study.inspect}"
				ped.study = study
				puts "ped #{ped.inspect} #{ped.valid?}"
				raise "Pedigree not valid #{ped.errors.inspect}" unless ped.valid?
				ped.save
				p.pedigree_id = ped
				puts "p #{p.inspect} #{p.valid?}"
				p.save
			end

			if info[1].match(/Gender/) and p.gender.match(/Unknown/) then
				p.gender = info[2].downcase!;
				raise "Person not valid #{p.inspect} #{p.errors.inspect}" unless p.valid?
				p.save
			end
			# find phenotype
			if (info[1].match(/Other Condition Type/)) then
				info[1] = info[2]
				info[2] = "True"
			end	
			pheno = Phenotype.find_by_name(info[1]) || Phenotype.new
			pheno.name = info[1] if pheno.name.nil?
			pheno.tag = info[1].gsub(/ /,"_").gsub(/,/,'').strip
			if (pheno.name.match(/Country of Birth/)) then
				pheno.phenotype_type = "Country of Birth"
			end
			raise "Phenotype not valid #{pheno.errors.inspect}" unless pheno.valid?
			puts "pheno valid #{pheno.inspect} #{pheno.valid?}"
			pheno.save

			next if info[2].match(/False/)
			next if (pheno.name.match(/Self Rpt Family Hx PTB/) and (info[2].match(/False/) or info[2].match(/True/) or info[2].match(/^Unknown$/)))
			next if (pheno.name.match(/Participant Medical History/) and (info[2].match(/False/) or info[2].match(/^No$/) or info[2].match(/^None$/)))
			# find or create trait
			puts "finding trait with #{pheno.id} #{p.id} BEG#{info[2]}END"
			trait = Trait.find(:first, :conditions => { :phenotype_id => pheno.id, :person_id => p.id, :trait_information => info[2]}) || Trait.new
			puts "trait before setting is #{trait.inspect}"
			trait.phenotype = pheno if trait.phenotype_id.nil?
			trait.person = p if trait.person_id.nil?
			trait.trait_information = info[2] if trait.trait_information.nil?
			raise "Trait not valid #{trait.errors.inspect}" unless trait.valid?
			puts "trait #{trait.inspect} #{trait.valid?}"
			trait.save
			puts "###################\n\n"
		end
		f.close
	end

######################################################################################################
######################################################################################################
######################################################################################################
######################################################################################################
######################################################################################################
######################################################################################################

    desc "Import  type file"
    task :import_itmi, [:filename]=> [:environment] do |t,args|
        raise "No filename provided" unless args[:filename]

		workspace="/tmp"
        f = File.open(args[:filename],"r")
        f.each_line do |line|
			next if line.match(/^#/)
			line.chomp!
			puts "line #{line}"
			info = Array.new
			info = line.split(/,/)
		end
		f.close
	end

end
