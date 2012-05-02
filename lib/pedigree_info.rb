# test the pedfile directory exists
def peddir_exists
  if !File.exists?(PEDFILES_DIR) then
    Dir.mkdir(PEDFILES_DIR)
  end
end

def pedindex(protocol,id_type)
  data_store = Hash.new
  if protocol.match('REST') then
    data_store["pedigree_databases_name"] = "ISB GMS Pedigrees"
  else 
    data_store["pedigree_databases_name"] = "ISB Locally Stored Pedigrees"
  end

  data_store["pedigree_databases_version"] = Time.now
  data_store["pedigree_databases_last_updated"] = Time.now
  data_store["pedigree_studies_root"] = PEDIGREE_ROOT
  data_store["pedigree_studies"] = Array.new
  Study.all.each do |study|
    study_hash = Hash.new
    study_hash["study_id"] = "isb_study_"+study.id.to_s
    study_hash["study_name"] = study.name
    study_hash["study_tag"] = study.tag
    study_hash["study_version"] = 1 # placeholder TODO: make version method
    study_peds = Array.new
    study.pedigrees.each do |ped|
      local_hash = Hash.new
      local_hash["pedigree_id"] = "isb_ped_"+ped.id.to_s
      local_hash["pedigree_tag"] = ped.tag
      local_hash["database_file"] = pedigree_output_filename(ped)
      study_peds.push(local_hash)
    end
    study_hash["study_pedigrees"] = study_peds
    data_store["pedigree_studies"].push(study_hash)
  end

  return data_store
end

def study_pedigree_index(study_id)
  study = Study.find(study_id)
  peds = study.pedigrees
  ped_array = Array.new
  peds.each do |pedigree|
    ped_array << "isb_ped_"+pedigree.id.to_s
  end
  study_to_peds = Hash.new
  study_to_peds[study_id] = ped_array

  return study_to_peds
end


# this method outputs a JSON hash
def pedfile(pedigree_id)

  puts "Creating JSON File for pedigree #{pedigree_id}"
  ped = Pedigree.find(pedigree_id)

  output_pedigree = Hash.new
  output_pedigree["pedigree_name"] = ped.tag
  output_pedigree["pedigree_study"] = ped.study.name
  output_pedigree["pedigree_study_tag"] = ped.study.tag
  output_pedigree["pedigree_desc"] = ped.description
  output_pedigree["pedigree_version"] = ped.version
  output_pedigree["pedigree_subDir"] = ped.directory
  output_pedigree["pedigree_complete"] = ped.complete
  founders = Array.new
  parentless_people(pedigree_id).each do |person|  # PARENTLESS PEOPLE IS A SIMPLE WAY OF FINDING FOUNDERS
    founders.push(person.isb_person_id)
  end
  output_pedigree["pedigree_founders"] = founders

  check = ped.people.count
  if check <= 0 then
    puts "No people for this pedigree, skipping"
    return output_pedigree
  end

  ordered_ped = ordered_pedigree(pedigree_id)
  output_ordered = Array.new
  ordered_ped.each do |person|
    output_ordered << person.isb_person_id  # can use other identifiers here instead...
  end
  output_pedigree["ordered_pedigree"] =  output_ordered

  individuals = Array.new
  #ped.people.each do |ind|
  ordered_ped.each do |ind|
    person = Hash.new
    person["person_id"] = ind.isb_person_id
    person["collaborator_id"] = ind.collaborator_id
    aliases = Array.new
    ind.person_aliases.each do |ali|
      aliases << ali.value if ali.name == 'collaborator_id'
    end
    person["aliases"] = aliases.size > 0 ? aliases : nil
    person["gender"] = ind.gender
    person["DOB"] = ind.dob
    person["DOD"] = ind.dod
    person["deceased"] = ind.deceased
    person["phenotype"] = person_traits(ind)
    person["diseases"] = person_diseases(ind)
    person["comments"] = ind.comments
    person["to_be_sequenced"] = ind.planning_on_sequencing
    if founders.include? ind.isb_person_id then
      person["founder"] = true
    else
      person["founder"] = false
    end

    samples_list = Array.new
    ind.samples.each do |sample|
      ind_sample = Hash.new
      #puts "sample is #{sample.inspect}"
      # has isb_sample_ in front already
      ind_sample["sample_id"] = sample.isb_sample_id
      if sample.sample_type.nil?
        ind_sample["sample_type"] = 'unknown'
      else
        ind_sample["sample_type"] = sample.sample_type.name
      end
      ind_sample["sample_desc"] = sample.comments
      ind_sample["sample_protocol"] = sample.protocol
      ind_sample["sample_date"] = sample.date_received
      ind_sample["sample_vendor_id"] = sample.sample_vendor_id
      ind_sample["sample_status"] = sample.status
      ind_sample["sample_updated"] = sample.updated_at
      #ind_sample["assays"] = Array.new
      #assay_hash = Hash.new
      assays = sample.assays
      if assays.size > 0 then
        assay_holder = Array.new
        assays.group_by { |t| t.assay_type }.each do |assay_type_group, assay_array|
          #assay_hash[assay_type_group] = Array.new
          #puts "assay_array is #{assay_array}"
          assay_array.each do |assay|
	    #puts "assay is #{assay.inspect}"
            assay_info = Hash.new
	    assay_info["assay_id"] = "isb_asy_"+assay.id.to_s
            assay_info["assay_name"] = assay.name
            assay_info["assay_type"] = assay.assay_type
            assay_info["assay_technology"] = assay.technology
            assay_info["assay_desc"] = assay.description
	    assay_info["assay_status"] = assay.status
	    assay_info["assay_updated"] = assay.updated_at
	    assay_info["assemblies"] = Array.new

	    assay.assemblies.each do |assembly|
    	        #puts "assembly #{assembly.inspect}"
                asm_list = Hash.new
		asm_list["assembly_id"] = "isb_asm_"+assembly.id.to_s
                asm_list["assembly_name"] = assembly.name
	        asm_list["assembly_date"] = assembly.file_date
  	        asm_list["assembler_swversion"] = assembly.software_version
	        asm_list["assembly_desc"] = assembly.description
	        asm_list["reference"] = assembly.genome_reference.name
	        asm_list["assembly_directory"] = assembly.location
	        asm_list["assembly_current"] = assembly.current
		asm_list["assembly_status"] = assembly.status
		asm_list["assembly_updated"] = assembly.updated_at
 
                af_list = assembly.assembly_files
                file_list = Array.new
                af_list.group_by {|t| t.file_type_id }.each do |file_type_id, assembly_file_array|
#                  puts "file_type_id is #{file_type_id.inspect} assay_file_array is #{assembly_file_array.inspect}"
		  assay_key = FileType.find(file_type_id).type_name
                  next if assay_key == "ASSEMBLY" 
                  assembly_file_array.each do |assembly_file|
                    file_info = Hash.new
	            file_info["file_type"] = assay_key
		    file_info["file_id"] = "isb_asmfile_"+assembly_file.id.to_s
                    file_info["file_name"] = assembly_file.name
                    file_info["assembly_date"] = assembly_file.file_date
                    file_info["assembler_swversion"] = assembly_file.software_version
                    file_info["assembly_desc"] = assembly_file.description
                    file_info["reference"] = assembly_file.genome_reference.name
                    file_info["file"] = assembly_file.location
 
                    file_list.push(file_info)
                  end
                end # end assay.assembly_files.all
           
                asm_list["files"] = file_list unless file_list.size == 0
                assay_info["assemblies"].push(asm_list) unless asm_list.size == 0
            end  # end assay.assemblies.each

  	    assay_info.delete("assemblies") if assay_info["assemblies"].size == 0
            #assay_hash[assay_type_group].push(assay_info)
	    #puts "adding assay_info to assay_array #{assay_info.inspect}"
	    assay_holder.push(assay_info)
          end # end assay_array.each
        end # end assays.group_by.each

        #ind_sample["assays"].push(assay_hash)
        ind_sample["assays"] = assay_holder
      end # end if assays.size > 0

      samples_list.push(ind_sample)
    end # end ind.samples.each

    person["samples"] = samples_list unless samples_list.size == 0 
    individuals.push(person)
  end # end ped.people.each

  # returns an array of hashes
  rels = pedigree_relationships(pedigree_id)
  output_pedigree["relationships"] = rels

  output_pedigree["individuals"] = individuals
  return output_pedigree

end  # end pedigree

def person_diseases(person)
  diseases = Array.new
  person.diagnoses.each do |diagnosis|
    if diagnosis.age_of_onset.nil? or diagnosis.age_of_onset == "" then
      diseases << diagnosis.disease.name
    else
      diseases << diagnosis.disease.name + ": "+diagnosis.age_of_onset
    end
  end

  if diseases.size == 0 then
    return nil
  else 
    return diseases
  end
end

def person_traits(person)
 
  traits = Array.new
  person.traits.each do |trait|
    pheno = trait.phenotype
    if trait.trait_information.nil? or trait.trait_information == "" then
      traits << pheno.name
    else
      traits << pheno.name+": "+trait.trait_information
    end
  end

  if traits.size == 0 then
    return nil
  else
    return traits
  end
end

def pedigree_relationships(pedigree_id)
  ped = Pedigree.find(pedigree_id)
  rel_info = Array.new
  ped.people.each do |person|
    mother = person.mother
    father = person.father
    next if mother.empty? and father.empty?
    person_rels = Hash.new
    person_rels["individual_id"] = person.isb_person_id

    if mother.size > 1 then 
      mothers = mother.map(&:isb_person_id).join(",")
    elsif mother.size == 1 then
      person_rels["mother"] = mother[0].isb_person_id
    end

    if father.size > 1 then
      fathers = father.map(&:isb_person_id).join(",")
    elsif father.size == 1 then 
      person_rels["father"] = father[0].isb_person_id
    end

    rel_info.push(person_rels)
  end
 
  return rel_info 
end


def pedigree_output_filename(ped)
    "#{ped.tag}.ped"
end



def ordered_pedigree(pedigree_id)
  # go through each person in the pedigree and find the relationships

  madeline_people = Array.new # an ordered array of people to draw
  if Pedigree.find(pedigree_id).tag.downcase.match("unrelateds") then
    madeline_people = Pedigree.find(pedigree_id).people.order("isb_person_id")
  else
    root_person = find_root(pedigree_id)
    #logger.debug("root person in ordered_pedigree is #{root_person.inspect}")
    puts "ERROR: no root person!" if root_person.nil?

    madeline_people = breadth_unrooted_traverse(root_person)
  end

  # if this is an unrelateds pedigree then breadth_traverse should return fewer people than
  # there are total, so we need to catch that and find the rest of the people - not all 
  # pedigrees are named 'unrelateds' so we need this check here
  unrelated_check = Pedigree.find(pedigree_id).people.order("isb_person_id")
  if unrelated_check.size > madeline_people.size then
    # add people that are only in unrelated_check to madeline_people at the end of the array
    madeline_people.concat(unrelated_check.delete_if { |per| madeline_people.include?(per) })
  end
  

  return madeline_people
end

# aka find founders, simply
def parentless_people(pedigree_id)
  ped = Pedigree.find(pedigree_id)
  founders = Array.new
  ped.people.each do |person|
    parents = person.parents
    if parents.size == 0 then
      founders.push(person)
    end
  end

  return founders
end



############################################################################################################
############################################################################################################
#
#   ####   ####   ####   ###   ####   #####  #   #     #####  ####    ###   #   #  #####  ####   ####  ####
#   #   #  #   #  #     #   #  #   #    #    #   #       #    #   #  #   #  #   #  #      #   #  #     #
#   ####   ####   ###   #####  #   #    #    #####       #    ####   #####  #   #  ####   ####    ##   ###
#   #   #  #  #   #     #   #  #   #    #    #   #       #    #  #   #   #   # #   #      #  #      #  #
#   ####   #   #  ####  #   #  ####     #    #   #       #    #   #  #   #    #    #####  #   #  ###   ####
#   
############################################################################################################
############################################################################################################


def breadth_traverse(person)
  people = Array.new
  people.push(person)
  madeline_people = Array.new
  madeline_people = people.dup
  current_gen = side_branch(person, [])
    #logger.debug("current_gen after side_branch #{current_gen}")
    people = people | current_gen
    #logger.debug("people after side_unrooted_branch #{people}")
    madeline_people = madeline_people | people
  #logger.debug("ENTERING LOOP")
  loop {
    #logger.debug("LOOP START")
    #logger.debug("breadth traverse people #{people}")

    #logger.debug("breadth traverse up_breadth_branch")
    people, current_gen = up_breadth_branch(people, current_gen)

    #logger.debug("breadth traverse down_breadth_branch")
    people, current_gen = down_breadth_branch(people, current_gen)
    #logger.debug("back from down_breadth_branch")
    #logger.debug("current gen is #{current_gen.inspect}")
    break if current_gen.empty?
    #logger.debug("after break in breadth_traverse")
    madeline_people = madeline_people | current_gen
    #logger.debug("madeline_people is #{madeline_people}")
    people = current_gen.dup
    #logger.debug("LOOP END\n\n\n")
  }

  return madeline_people
end

def down_breadth_branch(people, current_gen)
  #logger.debug("down_breadth_branch called with people #{people.inspect}")
  new_gen = Array.new
  people.each do |person|
    #logger.debug("down_breadth_branch loop for person #{person.inspect}")
    # offspring orders by relation_order
    #logger.debug("offspring is #{offspr}")
    person.offspring.each do |offspring_rel|
      child = offspring_rel.relation
      #logger.debug("down_breadth_branch child is #{child.inspect}")
      if !current_gen.include?(child) and !people.include?(child) then
        new_gen.push(child)
	current_gen.push(child) unless current_gen.include?(child)
	new_gen = side_branch(child, current_gen)
	#logger.debug("down_breadth_branch back from side_branch")
      end
    end
  end
  #logger.debug("exiting down_breadth_branch") 
  return people, new_gen
end

def up_breadth_branch(people, current_gen)
  #logger.debug("up_breadth_branch called")
  new_gen = Array.new
  people.each do |person|
    person.ordered_parents.each do |parent_rel|
      parent = parent_rel.relation
      #logger.debug("up_breadth_branch parent is #{parent.inspect}")
      if !current_gen.include?(parent) and !people.include?(parent) and !new_gen.include?(parent) then
        new_gen.push(parent)
	current_gen.push(parent) unless current_gen.include?(parent)
	new_gen = side_branch(parent, current_gen)
      end
    end
  end

  return people, new_gen
end

def side_branch(person, previous)
  #logger.debug("side_branch called")
  return previous if person.spouses.size == 0
  person.spouses.each do |spouse_rel|
    spouse = spouse_rel.relation
    #logger.debug("side_branch found spouse #{spouse.inspect}")
    if !previous.include?(spouse) then
      previous.push(spouse)
    end
  end

  return previous
end

# DEPTH TRAVERSE
def depth_traverse(person)
  people = Array.new
  people.push(person)
  people = side_branch(person, people)
  people = up_branch(person, people)
  people = down_depth_branch(person, people)
  return people
end

def up_branch(person, previous)
  #logger.debug("up_branch called")
  # go up parents until you don't find any
  return previous if person.parents.size == 0
  person.ordered_parents.each do |parent_rel|
    parent = parent_rel.relation
    #logger.debug("up_branch found parent #{parent.inspect}")
    if !previous.include?(parent) then
      previous.push(parent)
      previous = side_branch(parent, previous)
      previous = up_branch(parent, previous)
    end 
  end

  return previous
end

def down_depth_branch(person, previous)
  return previous if person.offspring.size == 0
  person.offspring.each do |offspring_rel|
    child = offspring_rel.relation
    if !previous.include?(child) then
      previous.push(child)
      previous = side_branch(child, previous)
      previous = up_branch(child, previous)
      previous = down_depth_branch(child, previous)
    end
  end

  return previous
end

# END DEPTH TRAVERSE

def find_root(pedigree_id)

   if Pedigree.find(pedigree_id).tag.downcase.match("unrelateds") then
     first = Pedigree.find(pedigree_id).people.first
    # puts "Returned one root for unrelated pedigree #{pedigree_id}"
     return first
   end

   if Pedigree.find(pedigree_id).tag.downcase.match("diversity") then
     # diversity shoudl be split into multiple pedigrees, but for now just return the first
     first = Pedigree.find(pedigree_id).people.first
     #puts "Returned one root for diversity pedigree #{pedigree_id}"
     return first
   end

   root_candidates = Person.has_pedigree(pedigree_id).joins(:offspring).where("relationships.person_id not in (?)", Relationship.has_pedigree(pedigree_id).where(:relationship_type => "child").map(&:person_id))

   #puts "root candidates #{root_candidates.inspect}"
   if root_candidates.empty?
     # this means that this pedigree has a single person (probably)
     root_candidates = Person.has_pedigree(pedigree_id)
     #puts "new root cands is #{root_candidates.inspect}"
   end

   roots = winnow_candidates(root_candidates)
   roots = prefer_male(roots)
   roots = prefer_male_children(roots)

   # to make logger.debug work with the rake task
   if (!defined?(logger)) then
     logger = Logger.new(STDOUT)
   end
   # to make logger.debug work in the console - can't combine and not sure why
   if (logger.nil?) then
     logger = Logger.new(STDOUT)
   end

   if roots.size > 1
     logger.debug("Error: Found multiple roots for pedigree #{pedigree_id}.")
   elsif roots.size == 1
#     logger.debug("Found one root for pedigree #{pedigree_id}")
   else
     logger.debug("Found no root for pedigree #{pedigree_id}")
   end

   root_array = roots.values
   return root_array.first
end

def winnow_candidates(root_candidates)

   roots = Hash.new
   root_candidates.each do |person|
     #puts "person #{person.inspect}"
     # check to see that this person isn't a child of someone else
     parent_relationships = person.parents
     #puts "parent_rels #{parent_relationships.inspect}"
     next if parent_relationships.size > 0

     # check marriages to see if spouse has parents
     spouse_relationships = person.spouses
     #puts "spouse_rels #{spouse_relationships.inspect}"
     flag = false
     spouse_relationships.each do |spouse_rels|
       spouse = spouse_rels.relation
       spouse_parents = spouse.parents
       #puts "spouse parents #{spouse_parents.inspect} #{spouse_parents.size}"
       if spouse_parents.size > 0 then
         flag = true
       end
     end
     next if flag
     #puts "adding person to root list"
     roots[person.id] = person

     #puts "________________"
   end

  return roots
end

def prefer_male(roots)
  new_roots = Hash.new
  roots.each do |id, root|
    if root.gender == "male"
      new_roots[id] = root
    end
  end

  if new_roots.size > 0
    return new_roots
  else
    return roots
  end
end

def prefer_male_children(roots)
     # find if one of the roots has a male child and use that one
     new_roots = Hash.new
     roots.each do |id, person|
       children_relationships = person.offspring
       children_relationships.each do |child_rel|
         child = child_rel.relation
	 if child.gender == "male"
	   new_roots[id] = person
	 end
       end
     end
     if new_roots.size > 0
       return new_roots
     else
       return roots
     end


end



############################################################################################################
############################################################################################################
#
#  ######  #####  #   #  ####      #   #  #   #  ####    ###    ###   #####  #####  ####
#  #         #    ##  #  #   #     #   #  ##  #  #   #  #   #  #   #    #    #      #   #
#  ####      #    # # #  #   #     #   #  # # #  ####   #   #  #   #    #    ###    #    #
#  #         #    #  ##  #   #     #   #  #  ##  #  #   #   #  #   #    #    #      #   #
#  #       #####  #   #  ####       ###   #   #  #   #   ###    ###     #    #####  ####
#
############################################################################################################
############################################################################################################

# right now this is just a duplicate of breadth_traverse.  Using the currently more simple parentless_people function

def pedigree_founders(pedigree_id)
  # go through each person in the pedigree and find the relationships

  madeline_people = Array.new # an ordered array of people to draw
  if Pedigree.find(pedigree_id).tag.downcase.match("unrelateds") then
    madeline_people = Pedigree.find(pedigree_id).people.order("isb_person_id")
  else
    root_person = find_root(pedigree_id)
    #logger.debug("root person in ordered_pedigree is #{root_person.inspect}")
    puts "ERROR: no root person!" if root_person.nil?

    madeline_people = breadth_unrooted_traverse(root_person)
  end

  madeline_people.each do |person|
    puts "#{person.id} - #{person.collaborator_id}"
  end

  return madeline_people
end


def breadth_unrooted_traverse(person)
  people = Array.new
  people.push(person)
#  people = side_branch(person, people)  # call side_branch so this person gets added 
  madeline_people = Array.new
  madeline_people = people.dup
  current_gen = side_unrooted_branch(person, [])
  puts("current_gen after side_unrooted_branch #{current_gen}")
  people = people | current_gen
  puts("people after side_unrooted_branch #{people}")
  madeline_people = madeline_people | people
  puts("ENTERING LOOP")
  loop {
    puts("LOOP START")
    puts("breadth traverse people #{people}")
    puts("breadth traverse up_breadth_unrooted_branch")
    people, current_gen = up_breadth_unrooted_branch(people, current_gen)

    puts("breadth traverse down_breadth_unrooted_branch")
    people, current_gen = down_breadth_unrooted_branch(people, current_gen)
    puts("back from down_breadth_unrooted_branch")
    puts("current gen is #{current_gen.inspect}")
    break if current_gen.empty?
    puts("after break in breadth_traverse")
    madeline_people = madeline_people | current_gen
    puts("madeline_people is #{madeline_people}")
    people = current_gen.dup
    puts("LOOP END\n\n\n")
  }

  return madeline_people
end

def down_breadth_unrooted_branch(people, current_gen)
  puts("down_breadth_unrooted_branch called with people #{people.inspect}")
  new_gen = Array.new
  people.each do |person|
    puts("down_breadth_unrooted_branch loop for person #{person.inspect}")
    # offspring orders by relation_order
    offspr = person.offspring
    puts("offspring is #{offspr}")
    person.offspring.each do |offspring_rel|
      child = offspring_rel.relation
      puts("down_breadth_unrooted_branch child is #{child.inspect}")
      if !current_gen.include?(child) and !people.include?(child) then
        new_gen.push(child)
	current_gen.push(child) unless current_gen.include?(child)
	new_gen = side_unrooted_branch(child, current_gen)
	puts("down_breadth_unrooted_branch back from side_unrooted_branch")
      end
    end
  end
  puts("exiting down_breadth_unrooted_branch") 
  return people, new_gen
end

def up_breadth_unrooted_branch(people, current_gen)
  puts("up_breadth_unrooted_branch called")
  new_gen = Array.new
  people.each do |person|
    person.ordered_parents.each do |parent_rel|
      parent = parent_rel.relation
      puts("up_breadth_unrooted_branch parent is #{parent.inspect}")
      if !current_gen.include?(parent) and !people.include?(parent) and !new_gen.include?(parent) then
        new_gen.push(parent)
	current_gen.push(parent) unless current_gen.include?(parent)
	new_gen = side_unrooted_branch(parent, current_gen)
      end
    end
  end

  return people, new_gen
end

def side_unrooted_branch(person, previous)
  puts("side_unrooted_branch called")
  return previous if person.spouses.size == 0
  person.spouses.each do |spouse_rel|
    spouse = spouse_rel.relation
    puts("side_unrooted_branch found spouse #{spouse.inspect}")
    if !previous.include?(spouse) then
      previous.push(spouse)
    end
  end

  return previous
end

