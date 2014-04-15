#
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
                gender = "Female"
            elsif person_name.match(/^F-/) then
                gender = "Male"
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
            software_version = nil
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

end
