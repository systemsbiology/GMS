namespace :sample do

  desc "Update sample status based on assembly_files presence"
  task :update_sample_status, [:pedigree_id] => :environment do |t, args|
    peds = Array.new
    if args[:pedigree_id]
      peds.push(args[:pedigree_id])
    else
      Pedigree.all.each do |ped|
        peds.push(ped.id)
      end
    end

    peds.each do |ped_id|
      ped = Pedigree.find(ped_id)
      ped.people.each do |person|
        person.samples.where(:status => "submitted").each do |sample|
	  if sample.varfile == true then
            sample.status = "sequenced"
            print "Updated sample #{sample.inspect} to be sequenced\n"
	    sample.save!
	  end
	end
      end
    end
  end

  desc "Retrieve varFile metadata for a sample directory"
  task :var_metadata, [:filename] => [:environment] do |t, args|
    raise "No filename of samples provided" unless args[:filename]
    f = File.open(args[:filename], "r")
    f.each_line do |line|
        line.strip!
        sample = line.split(/\//).last
        s = Sample.find_by_sample_vendor_id(sample)
        assem = s.assays.first.assemblies.first
        if assem.software_version.to_i < 2 then
            #puts "skipping sample due to age #{assem.software_version}"
        else
            varFile = assem.assembly_files.where(file_type_id: 1).first
            puts [s.sample_vendor_id, assem.isb_assembly_id, varFile.location, varFile.software_version].join("\t")
        end
    end
    f.close
  end

end
