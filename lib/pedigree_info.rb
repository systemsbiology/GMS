
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
