namespace :assay do

  desc "Update assay status based on assembly_files presence"
  task :update_assay_status, [:pedigree_id] => :environment do |t, args|
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
        person.samples.each do |sample|
          sample.assays.where(:status => "created").each do |assay|
	    print "processing assay #{assay.inspect}"
  	    if assay.varfile == true then
              assay.status = "Received"
              print "Updated assay #{assay.inspect} to be Received\n"
	      assay.save!
	    end
	  end
	end
      end
    end
  end

end
