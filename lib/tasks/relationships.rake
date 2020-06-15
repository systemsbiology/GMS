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
    relationships = Relationship.where(relationship_type: "undirected")
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
             if add[person].nil? then
	       add[person] = Hash.new
	     end
	     add[person][spouse] = name
	  end
	end # end if check_person[spouse].nil?
#	puts "****************"
      end #end spouses each
    end # end check_person each

    return add
  end

 #############################################################################################################
 ## PARENT/CHILD RELATIONSHIPS
 #############################################################################################################

  desc "Check relationships table for missing parent/child relationships"
  task :check_missing_offspring => :environment do
    missing_offspring = get_missing_offspring
    if missing_offspring.empty? then
      puts "no missing offspring"
    else
      missing_offspring.each do |person, missings|
        missings.each do |missing, value|
          puts "missing #{value} relationship between #{Person.find(person).collaborator_id} and #{Person.find(missing).collaborator_id}"
        end
      end
    end
  end

  ####################################################################################

  desc "Add missing offspring to relationships table"
  task :add_missing_offspring => :environment do
    missing_offspring = get_missing_offspring
    if missing_offspring.empty? then
      puts "no missing offspring"
      exit
    else
      missing_offspring.each do |person, missing_children|
        missing_children.each do |missing_child, rel_type|
          puts "processing person #{person.inspect} and child #{missing_child.inspect} with rel_type #{rel_type}"
          rel = Relationship.new
  	  rel.person_id = person
	  rel.relation_id = missing_child
          if rel_type == "parent" then
            if Person.find(person).gender == "male" then
              rel.name = "father"
            elsif Person.find(person).gender == "female" then
              rel.name = "mother"
            end
          elsif rel_type == "child" then
            if Person.find(person).gender == "male" then
              rel.name = "son"
            elsif Person.find(person).gender == "female"
              rel.name = "daughter"
            end
          end
	  rel.relationship_type = rel_type

	  rev_rel = Relationship.where(:person_id => missing_child, :relation_id => person).first
	  puts "foudn rev_rel #{rev_rel.inspect}"
	  if rev_rel.relation_order == 0 then
	    rev_rel.relation_order = 1
	    rev_rel.save
	  end

	  puts "assigning relation_order #{rev_rel.relation_order} to relatino"
	  rel.relation_order = rev_rel.relation_order

          check = Relationship.where(:person_id => rel.person_id, :relation_id => rel.relation_id, :relationship_type => rel.relationship_type, :name => rel.name)
          #puts "check #{check.inspect}"
          raise "Found duplicate relationship.  debug the code or manually check the database!" unless check.empty?
	  if rel.save
	    puts "created relationship between #{Person.find(person).collaborator_id} (#{Person.find(person).isb_person_id}) and #{Person.find(missing_child).collaborator_id} (#{Person.find(missing_child).isb_person_id})"
            puts "rel #{rel.inspect}"
	  else
	    raise "Error creating relationship #{rel.inspect} #{rel.errors.inspect}"
	  end
         puts "##############################"
        end
      end
    end
  end



  ####################################################################################
  ###### METHODS #####
  ####################################################################################

  # currently this has to be run at least twice to get all of the missing
  # child relationships.  the first run gets the same sex parents and the
  # second run gets the opposite sex parents.  I could probably fix it, but why? ;)
  # this does not find cases where there are no relationships at all
  def get_missing_offspring
    puts "in missing_offspring"
    # get all of the parent relationships and add them to the hash
    # then get all of the child relationships and check that the ones in the parent exist there
    parent_relationships = Relationship.where(relationship_type: "parent")
    check_parent = Hash.new
    parent_relationships.each do |relationship|
      pid = relationship.person_id
      raise "Parent id is null " if pid.nil?
      rid = relationship.relation_id
      raise "Child id is null " if rid.nil?

      if check_parent[pid].nil? then
        check_parent[pid] = Hash.new
      end
      check_parent[pid][rid] = relationship.name
    end


    child_relationships = Relationship.where(relationship_type: "child")
    check_child = Hash.new
    child_relationships.each do |relationship|
      pid = relationship.person_id
      raise "Parent id is null " if pid.nil?
      rid = relationship.relation_id
      raise "Child id is null " if rid.nil?

      if check_child[pid].nil? then
        check_child[pid] = Hash.new
      end
      check_child[pid][rid] = relationship.name
    end

    add = Hash.new

    check_parent.each do |person, children|
      puts "person #{person} #{check_parent[person]}"
      children.each do |child, name|
         puts "child #{child} #{check_parent[child]} name #{name}"
         if check_child[child].nil? then
	        puts "making child entry #{child}"
	        add[child] = Hash.new
	        add[child][person] = 'child'
	     else
            if check_parent[person][child] and check_child[child][person] then
	           puts "found reciprocal relationships for #{person} and #{child}"
  	        elsif check_parent[person][child] and check_child[child][person].nil? then
                puts "missing child relationship between #{child} and #{person}"
	            puts "add child #{add[child]}"
	            if add[child].nil? then
	                add[child] = Hash.new
	            end
	            add[child][person] = 'child'
	        elsif check_parent[person][child].nil? and check_child[child][person] then
                puts "missing parent relationship between #{person} and #{child}"
                if add[person].nil? then
	              add[person] = Hash.new
	            end
	            add[person][child] = 'parent'
	        end
	     end # end if check_child[child].nil?
	     puts "****************"
      end #end children each
      puts "##################################"
    end # end check_parent each

    return add
  end

end
