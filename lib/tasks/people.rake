namespace :people do

  desc "Update person sequencing status"
  task :update_sequencing_status, [:pedigree_id] => :environment do |t,args|
    peds = Array.new
    if args[:pedigree_id]
      peds.push(Pedigree.find(args[:pedigree_id]))
    else
      Pedigree.all.each do |ped|
        peds.push(ped)
      end
    end

    peds.each do |ped|
      ped.people.each do |person|
        person.check_sequencing_status
      end
      puts "finished ped #{ped.tag}\n"
    end
  end

  desc "Find Problem people"
  task :find_problem_people do
	People.all.each do |person|
		puts "#{person.inspect} doesn't have a pedigree" if person.membership.nil?
	end
  end

end
