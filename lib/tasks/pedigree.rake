namespace :pedigree do

  # create directory for files we're creating to upload
  directory "data/PedigreeDB"

  # data is located here TODO: Should this be a parameter passed in?
  $ped_loc = "/users/dmauldin/PedigreeDB/data"
  $index_file = "isb-pedigrees.dat"

  desc "Reads PedigreeDB JSON files and updates the database with that information"
  task :json_to_db => :environment do
    index = parse_index_file
    index["pedigree_databases"].each do |db|
      puts "Reading #{db["database_file"]}"
      db_file_loc = "#{$ped_loc}/#{db["database_file"]}"
      ped_db = parse_json(db_file_loc)
      # handle pedigree_name, pedigree_desc, pedigree_version, individuals, relationships
      cur_ped = Pedigree.new
      ped_map = Hash.new
      ped_db.each do |ped_key,v|

        unless (cur_ped.name.nil? || cur_ped.description.nil? || cur_ped.version.nil?)
          puts cur_ped.inspect
          cur_ped.save
          cur_ped.isb_pedigree_id = "isb_ped: #{cur_ped.id}"
          cur_ped.save
        end

        case ped_key
	when "pedigree_name"
	  cur_ped.name = v
	when "pedigree_desc"
	  cur_ped.description = v
	when "pedigree_version"
	  cur_ped.version = v
	when "pedigree_study"
	  # don't need to do anything because this is taken care of later
	when "pedigree_subdir"
	  cur_ped.directory = v
	when "individuals"
	  cur_per = ''
	  cur_json_id = ''
	  gata4_trait = ''
	  v.each do |ind|
	    cur_per = Person.new
            gata4_trait = Trait.new
	    puts "ind #{ind}"
	    ind.each do |k1, v1|
	      next if v1.nil?
	      next if v1 == ""
	      puts "k #{k1} v #{v1}"
	      case k1
	      when "id"
	        cur_json_id = v1
              when "subject_id"
	        cur_per.collaborator_id = v1
              when "gender"
                unless v1.nil?
  	          cur_per.gender = v1
		end
              when "DOB"
	        unless v1.nil? 
	          cur_per.dob = v1
		end 
	      when "DOD"
	        unless v1.nil?
	          cur_per.dod = v1
		end
              when "deceased"
	        unless v1.nil?
	          cur_per.deceased = 1
		end
              when "phenotype"
	        unless v1 == "unaffected"
		  if v1 =~ /gata4/
		    rem_gata4status = v1.sub(/gata4_pos/,"")
		    rem_gata4status = rem_gata4status.sub(/gata4_neg/,"")
		    rem_gata4status = rem_gata4status.sub(/  /, " ")
		    next if rem_gata4status.nil?
		    v1 = rem_gata4status
		  end

		  # get rid of unaffected or unknown after correcting for gata4 status
		  v1 = v1.sub(/ $/, "") 
		  next if v1 == "unaffected"
		  next if v1 == "unknown"
		  puts "phenotype found !! #{v1}"

		  splitter = ''
		  if v1 =~ /,/
  		    splitter = ','
		  else 
		    splitter = ' '
		  end

		  if cur_ped.name == 'Diversity Study'
		    # we don't want this entry split, so make splitter into something that won't match
		    splitter = 'kjfdlkajflkdaklfdjalkjfdklajfdkljaklfjdkaljfk'
		  end

		  phenos = v1.split(splitter)
		  phenos.each do |p|
		    pheno = cur_ped.name + ' ' + p
		    cur_pheno = Phenotype.find_by_name(pheno)
		    if cur_pheno.nil?
		      puts "didn't find #{pheno}"
		      cur_pheno = Phenotype.new
		      cur_pheno.name = pheno
		      cur_pheno.save

		    end


	            cur_per.save
                    cur_per.isb_person_id = "isb_ind: "+cur_per.id.to_s
	            cur_per.save

		    new_trait = Trait.new(:person_id => cur_per.id, :phenotype_id => cur_pheno.id)
		    new_trait.save
		    puts cur_pheno.inspect

		  end
		end
	      when "desc"
	        # contains GATA4 mutation status, failed sample QC, errors from CGI
		# Gata4 status is a trait
                # failed sample qc is a comment on the samples table and also on a putative assembly
		# errors from CGI are on the assembly in the assay_files table
                # skip anything that's not the GATA4 stuff and do that stuff by hand
		if v1 =~ /GATA4/
		  gata4_pheno = Phenotype.find_by_name("GATA4 mutation")
		  if gata4_pheno.nil?
		    # create the object once
		    gata4_pheno = Phenotype.new(:name => "GATA4 mutation")
		    gata4_pheno.save
		  end
		  gata4_trait = Trait.new(:phenotype_id => gata4_pheno.id)
		  /GATA4(.*)/ =~ v1
		  gata4_trait.value = $1
		else 
		  cur_per.comments = v1
		end
              when "samples"
	        # go through the array
	        v1.each do |s|
		  # go through each sample hash in the array
		  cur_sample = Sample.new
		  s.each do |k3, v3| 
		    next if v3 == ""
		    next if v3.nil?
		    puts "k3 #{k3} v3 #{v3}"
                    case k3
  		    when "sample_id"
		      puts " vendor sample id is #{v3}\n"
		      cur_sample.vendor_id = v3
		    when "sample_type"
		      unless v3.nil?
		      # not tested..
		        st = SampleType.find_by_name(v3)
			if st.nil?
                          st = SampleType.new(:name => v3)
			  st.save
			end
			puts "st "+st.inspect
			cur_sample.sample_type_id = st.id
		      end
		    when "sample_desc"
		      unless v3.nil?
		        puts "setting sample desc to #{v3}\n"
			cur_sample.description = v3
		      end
		    when "sample_protocol"
		      unless v3.nil?
		        puts "setting sample protocol to #{v3}\n"
			cur_sample.protocol = v3
	              end
		    when "sample_date"
		      unless v3.nil?
		        puts "setting sample date to #{v3}\n"
			cur_sample.date_received = v3
	              end
		    when "sequencing"
		      puts "cur_sample info #{cur_sample.inspect}"
		      puts "saving sample #{cur_sample.inspect}"
		      cur_sample.save
		      cur_sample.isb_sample_id = "isb_sample: #{cur_sample.id}"
		      cur_sample.save
		      unless cur_per.id.nil?
	                cur_per.save
                        cur_per.isb_person_id = "isb_ind: "+cur_per.id.to_s
	                cur_per.save
                        cur_acq = Acquisition.find_by_person_id_and_sample_id(cur_per.id, cur_sample.id)
		        if cur_acq.nil?
		          cur_acq = Acquisition.new(:person_id => cur_per.id, :sample_id => cur_sample.id)
		          cur_acq.save
			end
	              end

		      # go through the array of sequencings
		      v3.each do |seq|
		        puts "seq #{seq}\n"
			# we know that all of the current assays in the json file are sequencing results
			assay_info = Hash.new
		        seq.each do |k4, v4|
		          next if v4 == ""
			  puts "k4 #{k4} v4 #{v4}\n"
			  case k4 
			  when "sequencing_date"
			    assay_info["date"] = v4
			  when "sequencing_tech"
			    assay_info["technology"] = v4.upcase
			  when "sequencing_desc"
			    assay_info["description"] = v4
			  when "assemblies"
			    # go through the array of assemblies
			    v4.each do |asm|
			      # BUG: TODO: need to add a find Assay because things that have multiple
			      # assemblies shouldn't have multiple assays
			      puts "assay_info is #{assay_info.inspect}"
			      cur_assay = Assay.new(:assay_type => 'sequencing')
			      cur_assay.date = assay_info["date"]
			      cur_assay.technology = assay_info["technology"]
			      cur_assay.description = assay_info["description"]
                              cur_assay.save

			      cur_asm = AssayFile.new(:file_type => "assembly", :software => "dbsnptool", :assay_id => cur_assay.id)
                              asm.each do |asm_key, asm_val|
                                case asm_key
				when "assembly_id"
				 cur_asm.name = asm_val
				when "assembly_date"
				 cur_asm.file_date = asm_val
				when "assembler_swversion"
				  cur_asm.software_version = asm_val
				when "assembly_desc"
				  cur_asm.description = asm_val
				when "assembly_deprecated"
				  if asm_val == "1"
				    cur_asm.current = 0
				  else
				    cur_asm.current = 1
				  end
				when "reference"
				  if asm_val == ""
				    puts "WARNING: THERE IS NO REFERENCE FOR ASSEMBLY"
				    next
				  end
				  puts "reference value is #{asm_val}"
				  cur_ref = GenomeReference.find_by_name(asm_val)
				  if cur_ref.nil?
				    cur_ref = GenomeReference.new(:name => asm_val)
				    cur_ref.save
				  end
				  puts "reference "+cur_ref.inspect
				  cur_asm.genome_reference_id = cur_ref.id
				when "variation_file"
				  cur_asm.location = asm_val
				else 
				  puts "unhandled assembly key #{asm_key}\n"
				end
			      end
                              puts "cur_asm "+cur_asm.inspect
			      cur_asm.save

			      sample_assay_link = SampleAssay.new(:sample_id => cur_sample.id, :assay_id => cur_assay.id)
			      sample_assay_link.save
			    end
			  else
			    puts "unhandled sequencing key #{k4}\n"
			  end
			end
		      end
		    else 
                      puts "unhandled sample #{k3}\n"
		    end
 
                    puts "checking that sample was saved #{cur_sample.inspect}"
		    if cur_sample.id.nil?
		       puts "saving sample as a last ditch\n"
		      cur_sample.save
		      cur_sample.isb_sample_id = "isb_sample: #{cur_sample.id}"
		      cur_sample.save

  	              cur_per.save
                      cur_per.isb_person_id = "isb_ind: "+cur_per.id.to_s
	              cur_per.save
                      cur_acq = Acquisition.find_by_person_id_and_sample_id(cur_per.id, cur_sample.id)
		      if cur_acq.nil?
		        cur_acq = Acquisition.new(:person_id => cur_per.id, :sample_id => cur_sample.id)
		        cur_acq.save
	              end
		    end

                    cur_acq = Acquisition.find_by_person_id_and_sample_id(cur_per.id, cur_sample.id)
		    if cur_acq.nil?
  	              cur_per.save
                      cur_per.isb_person_id = "isb_ind: "+cur_per.id.to_s
	              cur_per.save
		      cur_acq = Acquisition.new(:person_id => cur_per.id, :sample_id => cur_sample.id)
		      cur_acq.save
		    end


                  end
		end
	      
              else
	        print "unhandled individual key #{k1}\n"
	      end


	    end

            if cur_per.id.nil?
  	      cur_per.save
              cur_per.isb_person_id = "isb_ind: "+cur_per.id.to_s
	      cur_per.save
	    end
	    ped_map[cur_json_id.to_s] = cur_per.id
	    puts "added cur_json_id #{cur_json_id} to ped map with cur_per id #{cur_per.id}\n";
	    puts cur_per.inspect
	    puts ped_map.inspect

  	    if gata4_trait.value?
	      gata4_trait.person_id = cur_per.id
	      puts gata4_trait.inspect
	      gata4_trait.save
	    end

            cur_mem = Membership.new(:person_id => cur_per.id, :pedigree_id => cur_ped.id)
	    cur_mem.save

	  end

	when "relationships"
	  puts "ped_val #{v}"
          v.each do |rel|
	    rel_self = ''
	    rel_mother = ''
	    rel_father = ''
	    rel.each do |rel_key, rel_val|
	      case rel_key
  	      when "individual_id"
	        rel_self = rel_val
	      when "father_id"
	        rel_father = rel_val
	      when "mother_id"
	        rel_mother = rel_val
	      else
	        puts "unhandled relationhip key #{rel_key}\n"
	      end
            end 

            puts "rel_self #{rel_self} rel_mother #{rel_mother} rel_father #{rel_father}\n"
	    puts "ped_map #{ped_map.inspect}"
	    puts "find id #{ped_map[rel_self.to_s]}\n"

            child = Person.find_by_id(ped_map[rel_self.to_s])
	    puts "found child #{child.inspect} for rel_self #{rel_self} pedmap #{ped_map[rel_self.to_s]}\n"
	    mother = Person.find_by_id(ped_map[rel_mother.to_s])
            puts "found mother #{mother.inspect} for rel_mother #{rel_mother} pedmap #{ped_map[rel_mother.to_s]}\n"
	    father = Person.find_by_id(ped_map[rel_father.to_s])
            puts "found father #{father.inspect} for rel_father #{rel_father} pedmap #{ped_map[rel_father.to_s]}\n"

            if child.nil? or mother.nil? or father.nil?
	      puts "ERROR: NO INFORMATION FOR RELATIONSHIP\n"
	    end

	    rel_name = ''
	    if child.gender == "male"
              rel_name = 'son'
	    elsif child.gender == "female"
	      rel_name = 'daughter'
            else
	      rel_name = "child"
            end

            unless mother.nil? 
              rel_mom = Relationship.find_by_parent_and_child(mother.id, child.id)
	      if rel_mom.nil?
	        rel_mom = Relationship.new(:parent => mother.id, :child => child.id, :name => rel_name, :relationship_type => "directed")
	        rel_mom.save
	      end
              puts "rel mom #{rel_mom.inspect}"
	    end
	    unless father.nil?
  	      rel_dad = Relationship.find_by_parent_and_child(father.id, child.id)
	      if rel_dad.nil?
	        rel_dad = Relationship.new(:parent => father.id, :child => child.id, :name => rel_name, :relationship_type => "directed")
	        rel_dad.save
	      end
              puts "rel dad #{rel_dad.inspect}"
            end

            unless mother.nil? or father.nil?
  	      rel_parents = Relationship.new(:parent => father.id, :child => mother.id, :name => "married", :relationship_type => "undirected")
	      rel_parents.save
            end
	  end
	else 
	  puts "unhandled #{ped_key}"
	end
      end
      ped_map = Hash.new
    end
  end

  desc "Write PedigreeDB JSON files"
  task :write_pedigree => :environment do
    Pedigree.all.each do |ped|
      output_pedigree = Hash.new
      output_pedigree["pedigree_name"] = ped.name
      output_pedigree["pedigree_desc"] = ped.description
      output_pedigree["pedigree_version"] = ped.version

      individuals = Array.new
      ped.people.each do |ind|
        person = Hash.new
	person["id"] = ind.isb_person_id
	person["subject_id"] = ind.collaborator_id
	person["gender"] = ind.gender
	person["dob"] = ind.dob
	person["dod"] = ind.dod
	person["deceased"] = ind.deceased
	person["comments"] = ind.comments

        samples_list = Array.new
	ind.samples.each do |sample|
          ind_sample = Hash.new
	  ind_sample["sample_id"] = sample.isb_sample_id
	  ind_sample["sample_type"] = sample.sample_type.name
	  ind_sample["sample_desc"] = sample.comments
	  ind_sample["sample_protocol"] = sample.protocol
	  ind_sample["sample_date"] = sample.date_received

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
          
	  ind_sample["assays"] = assay_hash
          samples_list.push(ind_sample)
	end # end ind.samples.each
	
	person["samples"] = samples_list
	individuals.push(person)
      end # end ped.people.each

      output_pedigree["individuals"] = individuals

      json_pedigree = ActiveSupport::JSON.encode(output_pedigree)
      puts json_pedigree
      
    end  # end pedigree
  end

  def parse_index_file
    path_index_file = "#{$ped_loc}/#{$index_file}"
    parse_json(path_index_file)
  end

  def parse_json(filename)
    index_contents = File.read(filename)
    ActiveSupport::JSON.decode(index_contents)
  end

end
