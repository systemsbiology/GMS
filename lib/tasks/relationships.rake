namespace :relationships do

  desc "Check relationships table for missing marriages"
  task :check_missing_marriages => :environment do
    missing_marriages = get_missing_marriages
    if missing_marriages.empty? then
      puts "no missing marriages"
    else 
      missing_marriages.each do |person, missings|
        missings.each do |missing, value|
          puts "missing relationship between #{Person.find(person).collaborator_id} and #{Person.find(missing).collaborator_id}"
        end
      end
    end
  end

  ####################################################################################

  desc "Add missing marriages to relationships table"
  task :add_missing_marriages => :environment do
    missing_marriages = get_missing_marriages
    if missing_marriages.empty? then
      puts "no missing marriages"
      exit
    else 
      missing_marriages.each do |person, missing_spouses|
        missing_spouses.each do |missing_spouse, name|
          rel = Relationship.new
  	  rel.person_id = person
	  rel.relation_id = missing_spouse
	  rel.relationship_type = "undirected"
	  rel.name = name
	  if rel.save
	    puts "created relationship between #{Person.find(person).collaborator_id} (#{Person.find(person).isb_person_id}) and #{Person.find(missing_spouse).collaborator_id} (#{Person.find(missing_spouse).isb_person_id})"
	  else 
	    raise "Error creating relationship"
	  end
        end
      end
    end
  end

  ####################################################################################

  desc "Update the relationship name based on the relationship type and gender of person"
  task :update_relationship_name => :environment do
    relationships = Relationship.all
    rel_types = Hash.new
    rel_types["undirected"] = Hash.new
    rel_types["undirected"]["female"] = "wife"
    rel_types["undirected"]["male"] = "husband"
    rel_types["directed"] = Hash.new
    rel_types["directed"]["person"] = Hash.new
    rel_types["directed"]["person"]["female"] = "mother"
    rel_types["directed"]["person"]["male"] = "father"
    rel_types["directed"]["relation"] = Hash.new
    rel_types["directed"]["relation"]["female"] = "daughter"
    rel_types["directed"]["relation"]["male"] = "son"

    puts "rel_types #{rel_types.inspect}"
    relationships.each do |rel|
      puts "rel is #{rel.inspect}"
      person_gender = Person.find(rel.person).gender
      relation_gender = Person.find(rel.relation).gender
      puts "person_gender #{person_gender} relation_gender #{relation_gender}"
      # this takes the form of person is the X of relation.  ex:
      # person is the son of relation
      # person is the daughter of relation
      # person is the mother of relation
      # person is the wife of relation
      # person is the husband of relation
      if rel.relationship_type == 'undirected' then
 
        if rel_types[rel.relationship_type] then
  	  if rel_types[rel.relationship_type][person_gender] then
            new_rel_name = rel_types[rel.relationship_type][person_gender]
            puts "changing rel.name #{rel.name} to new_rel_name #{new_rel_name}"
            puts "person #{rel.person.collaborator_id} is the #{new_rel_name} of #{rel.relation.collaborator_id}"
	    rel.name = new_rel_name
	    if rel.save then
	      puts "successfully updated relationship"
	    else
	      puts "failed to update relationship"
	    end
          else 
            puts "person gender was nil #{rel_types[rel.relationship_type]}"
  	  end
        else
          puts "ERROR: rel.relationship_type #{rel.relationship_type} not found in hash"
        end
       
           
      elsif rel.relationship_type == 'directed' then

        if rel_types[rel.relationship_type] then
          if rel_types[rel.relationship_type]["person"] then
  	    if rel_types[rel.relationship_type]["person"][person_gender] then
              new_rel_name = rel_types[rel.relationship_type]["person"][person_gender]
              puts "changing rel.name #{rel.name} to new_rel_name #{new_rel_name}"
              puts "person #{rel.person.collaborator_id} is the #{new_rel_name} of #{rel.relation.collaborator_id}"
	      rel.name = new_rel_name
	      if rel.save then
	        puts "successfully updated relationship"
	      else
	        puts "failed to update relationship"
	      end
            else 
              puts "person gender was nil #{rel_types[rel.relationship_type]["person"]}"
  	    end
          else 
            puts "person was nil #{rel_types[rel.relationship_type]}"
          end
        else
          puts "ERROR: rel.relationship_type #{rel.relationship_type} not found in hash"
        end
      else
         puts "ERROR: unhandled relationship type #{rel.relationship_type}"
      end
      puts "********************"
    end
  end



  ####################################################################################
  ###### METHODS #####
  ####################################################################################

  def get_missing_marriages 
    relationships = Relationship.find_all_by_relationship_type("undirected")
    check_person = Hash.new
    relationships.each do |relationship|
      pid = relationship.person_id
      raise "Parent id is null " if pid.nil?
      rid = relationship.relation_id
      raise "Child id is null " if rid.nil?

      if check_person[pid].nil? then
        check_person[pid] = Hash.new
      end
      check_person[pid][rid] = relationship.name
    end

    add = Hash.new
    check_person.each do |person, spouses|
#      puts "person #{person} #{check_person[person]}"
      spouses.each do |spouse, name|
#       puts "spouse #{spouse} #{check_person[spouse]} name #{name}"
        if check_person[spouse].nil? then
#	  puts "making spouse entry #{spouse}"
	  add[spouse] = Hash.new
	  add[spouse][person] = name
	else 
          if check_person[person][spouse] and check_person[spouse][person] then
#	     puts "found reciprocal relationships for #{person} and #{spouse}"
  	  elsif check_person[person][spouse] and check_person[spouse][person].nil? then
#            puts "missing relationship between #{spouse} and #{person}"
#	    puts "add spouse #{add[spouse]}"
	    if add[spouse].nil? then
	      add[spouse] = Hash.new
	    end
	    add[spouse][person] = name
	  elsif check_person[person][spouse].nil? and check_person[spouse][person] then
#            puts "missing relationship between #{person} and #{spouse}"
             if add[spouse].nil? then
	       add[spouse] = Hash.new
	     end
	     add[person][spouse] = name
	  end
	end # end if check_person[spouse].nil?
#	puts "****************"
      end #end spouses each
    end # end check_person each

    return add
  end

end
