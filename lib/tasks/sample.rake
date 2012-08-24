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

end
