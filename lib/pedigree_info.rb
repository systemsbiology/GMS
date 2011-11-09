#
def peddir_exists
  if !File.exists?(PEDFILES_DIR) then
    Dir.mkdir(PEDFILES_DIR)
  end
end

def pedindex
  data_store = Hash.new
  data_store["pedigree_databases_name"] = "ISB Locally Stored Pedigrees"
  data_store["pedigree_databases_version"] = Time.now
  data_store["pedigree_databases_last_updated"] = Time.now
  data_store["pedigree_studies_root"] = PEDIGREE_ROOT
  data_store["pedigree_databases"] = Array.new

  Pedigree.all.each do |ped|
      local_hash = Hash.new
      local_hash["pedigree_id"] = ped.tag
      local_hash["database_file"] = pedigree_output_filename(ped)

      data_store["pedigree_databases"].push(local_hash)
  end

  return data_store
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

  individuals = Array.new
  ped.people.each do |ind|
    person = Hash.new
    person["id"] = ind.isb_person_id
    person["collaborator_id"] = ind.collaborator_id
    person["gender"] = ind.gender
    person["DOB"] = ind.dob
    person["DOD"] = ind.dod
    person["deceased"] = ind.deceased
    person["phenotype"] = ind.phenotypes.map(&:name).join(", ")
    person["comments"] = ind.comments

    samples_list = Array.new
    ind.samples.each do |sample|
      ind_sample = Hash.new
      #puts "sample is #{sample.inspect}"
      ind_sample["sample_id"] = sample.isb_sample_id
      if sample.sample_type.nil?
        ind_sample["sample_type"] = 'unknown'
      else
        ind_sample["sample_type"] = sample.sample_type.name
      end
      ind_sample["sample_desc"] = sample.comments
      ind_sample["sample_protocol"] = sample.protocol
      ind_sample["sample_date"] = sample.date_received
      ind_sample["sample_vendor_id"] = sample.vendor_id
      #ind_sample["assays"] = Array.new
      #assay_hash = Hash.new
      assays = sample.assays
      next if assays.size == 0
      assay_holder = Array.new
      assays.group_by { |t| t.assay_type }.each do |assay_type_group, assay_array|
        #assay_hash[assay_type_group] = Array.new
        #puts "assay_array is #{assay_array}"
        assay_array.each do |assay|
	  #puts "assay is #{assay.inspect}"
          assay_info = Hash.new
          assay_info["assay_name"] = assay.name
          assay_info["assay_type"] = assay.assay_type
          assay_info["assay_technology"] = assay.technology
          assay_info["assay_desc"] = assay.description
	  assay_info["assemblies"] = Array.new

	  assay.assemblies.each do |assembly|
    	      #puts "assembly #{assembly.inspect}"
              asm_list = Hash.new
              asm_list["assembly_id"] = assembly.name
	      asm_list["assembly_date"] = assembly.file_date
	      asm_list["assembler_swversion"] = assembly.software_version
	      asm_list["assembly_desc"] = assembly.description
	      asm_list["reference"] = assembly.genome_reference.name
	      asm_list["assembly_directory"] = assembly.location
	      asm_list["assembly_current"] = assembly.current
 
              af_list = assembly.assembly_files
              file_list = Array.new
              af_list.group_by {|t| t.file_type }.each do |assay_key, assembly_file_array|
                #puts "assay_key is #{assay_key.inspect} asasy_file_array is #{assembly_file_array.inspect}"
                next if assay_key == "ASSEMBLY" 
                assembly_file_array.each do |assembly_file|
                  file_info = Hash.new
	          file_info["file_type"] = assay_key
                  file_info["assembly_id"] = assembly_file.name
                  file_info["assembly_date"] = assembly_file.file_date
                  file_info["assember_swversion"] = assembly_file.software_version
                  file_info["assembly_desc"] = assembly_file.description
                  file_info["reference"] = assembly_file.genome_reference.name
                  file_info["file"] = assembly_file.location

                  file_list.push(file_info)
                end
              end # end assay.assembly_files.all
          
              asm_list["files"] = file_list unless file_list.size == 0
              assay_info["assemblies"].push(asm_list) unless asm_list.size == 0
          end

	  assay_info.delete("assemblies") if assay_info["assemblies"].size == 0
          #assay_hash[assay_type_group].push(assay_info)
	  #puts "adding assay_info to assay_array #{assay_info.inspect}"
	  assay_holder.push(assay_info)
        end # end assay_array.each
      end # end assays.group_by.each

      #ind_sample["assays"].push(assay_hash)
      ind_sample["assays"] = assay_holder
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
    madeline_people = Pedigree.find(pedigree_id).people
  else
    root_person = find_root(pedigree_id)

    puts "ERROR: no root person!" if root_person.nil?

    people = traverse(root_person)
    #madeline_people.push(root_person)
    #root_person.spouses.each do |spouse_rels|
    #  spouse = spouse_rels.relation
    #  madeline_people.push(spouse)
    #  spouse.parents.each do |spouse_parent_rels|
    #    madeline_people.push(spouse_parent_rels.relation)
    #  end
    #end 
  end

  puts "madeline_people #{madeline_people.inspect}"
  return madeline_people
end

# call up_branch and down_branch
def traverse(person)
  puts "traversing person #{person.inspect}"
  people = Array.new
  people = side_branch(person, people)
  people = up_branch(person, people)
  people = down_branch(person, people)
  return people
end

def side_branch(person, previous)
  return 0 if person.spouses.size == 0
  person.spouses.each do |spouse_rel|
    puts "sidebranch for person #{person.inspect}"
    puts "found #{spouse_rel.relation.inspect}"
    puts "sidebranch #{person.id} -> #{spouse_rel.relation.id}"
    spouse = spouse_rel.relation
    if !previous.include?(spouse) then
      previous.push(spouse)
      up_branch(spouse, person)
      down_branch(spouse, person)
    end
  end
end

def up_branch(person, previous)
  # go up parents until you don't find any
  return 0 if person.parents.size == 0
  person.parents.each do |parent_rel|
    puts "upbranch for person #{person.inspect}"
    puts "found #{parent_rel.relation.inspect}"
    puts "upbranch #{person.id} -> #{parent_rel.relation.id}"
    parent = parent_rel.relation
    if !previous.include?(parent) then
      previous.push(parent)
      up_branch(parent, person)
      side_branch(parent, person)
    end 
  end
end

def down_branch(person, previous)
  return 0 if person.offspring.size == 0
  puts person.id
  person.offspring.each do |offspring_rel|
    puts "downbranch person #{person.inspect}"
    puts "found #{offspring_rel.relation.inspect}"
    puts "downbranch #{person.id} -> #{offspring_rel.relation.id}"
    child = offspring_rel.relation
    if !previous.include?(child) then
      previous.push(child)
      side_branch(child, person)
      down_branch(child, previous)
      up_branch(child, person)
    end
  end
end

def find_root(pedigree_id)

   if Pedigree.find(pedigree_id).tag.downcase.match("unrelateds") then
     first = Pedigree.find(pedigree_id).people.first
     puts "Returned one root for unrelated pedigree #{pedigree_id}"
     return first
   end

   if Pedigree.find(pedigree_id).tag.downcase.match("diversity") then
     # diversity shoudl be split into multiple pedigrees, but for now just return the first
     first = Pedigree.find(pedigree_id).people.first
     puts "Returned one root for diversity pedigree #{pedigree_id}"
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


   if roots.size > 1
     puts "Error: Found multiple roots for pedigree #{pedigree_id}."
   elsif roots.size == 1
     puts "Found one root for pedigree #{pedigree_id}"
   else
     puts "Found no root for pedigree #{pedigree_id}"
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


