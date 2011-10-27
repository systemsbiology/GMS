
def pedindex
  data_store = Hash.new
  data_store["pedigree_databases_name"] = "ISB Locally Stored Pedigrees"
  data_store["pedigree_databases_version"] = Time.now
  data_store["pedigree_databases_last_updated"] = Time.now
  data_store["pedigree_studies_root"] = PEDIGREE_ROOT
  data_store["pedigree_databases"] = Array.new

end


# this method outputs a JSON pedfile
def pedfile(pedigree_id, filename)

  peds = Array.new
  if pedigree_id.blank? then
    Pedigree.all.each do |ped|
    peds.push(ped.id)
    end
  else
    peds.push(pedigree_id)
  end

    Pedigree.all.each do |ped|
      output_pedigree = Hash.new
      output_pedigree["pedigree_name"] = ped.name
      output_pedigree["pedigree_study"] = ped.study.name
      output_pedigree["pedigree_desc"] = ped.description
      output_pedigree["pedigree_version"] = ped.version
      output_pedigree["pedigree_subDir"] = ped.directory

      individuals = Array.new
      ped.people.each do |ind|
        person = Hash.new
        person["id"] = ind.isb_person_id
        person["subject_id"] = ind.collaborator_id
        person["gender"] = ind.gender
        person["DOB"] = ind.dob
        person["DOD"] = ind.dod
        person["deceased"] = ind.deceased
        person["phenotype"] = ind.phenotypes.map(&:name).join(", ")
        person["comments"] = ind.comments

        samples_list = Array.new
        ind.samples.each do |sample|
          ind_sample = Hash.new
#         puts "sample is #{sample.inspect}"
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
          assay_hash = Hash.new
          assays = sample.assays
          assays.group_by { |t| t.assay_type }.each do |assay_type_group, assay_array|
            assay_hash[assay_type_group] = Array.new

            assay_array.each do |assay|
              assay_info = Hash.new
              assay_info["assay_name"] = assay.name
              assay_info["assay_type"] = assay.assay_type
              assay_info["assay_technology"] = assay.technology
              assay_info["assay_desc"] = assay.description

              asm_list = Array.new
              af_list = assay.assay_files
              af_list.group_by {|t| t.file_type }.each do |assay_key, assay_file_array|
                puts "assay_key is #{assay_key.inspect} asasy_file_array is #{assay_file_array.inspect}"
                next unless assay_key == "VAR-ANNOTATION" # this skips all files except for the varfile - may want to add other files eventually but will need different keys
                assay_file_array.each do |assay_file|
                  file_info = Hash.new
                  file_info["assembly_id"] = assay_file.name
                  file_info["assembly_date"] = assay_file.file_date
                  file_info["assember_swversion"] = assay_file.software_version
                  file_info["assembly_desc"] = assay_file.description
                  file_info["reference"] = assay_file.genome_reference.name
                  file_info["variation_file"] = assay_file.location

                  asm_list.push(file_info)
                end
              end # end assay.assay_files.all

              assay_info["assemblies"] = asm_list
              assay_hash[assay_type_group].push(assay_info)
            end # end assay_array.each
          end # end assays.group_by.each

          #ind_sample["assays"].push(assay_hash)
          ind_sample["assays"] = assay_hash
          samples_list.push(ind_sample)
        end # end ind.samples.each

        person["samples"] = samples_list
        individuals.push(person)
      end # end ped.people.each

      output_pedigree["individuals"] = individuals
      json_pedigree = ActiveSupport::JSON.encode(output_pedigree)
      output_file = "#{ped.tag}.ped"
      puts "writing file #{output_file}"
      File.open(output_file, 'w') do |f|
        f.puts json_pedigree
      end
#      puts json_pedigree
      local_hash = Hash.new
      local_hash["pedigree_id"] = ped.name
      local_hash["database_file"] = output_file

      data_store["pedigree_databases"].push(local_hash)

    end  # end pedigree

    return data_store
end
