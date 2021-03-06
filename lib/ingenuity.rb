require 'tmpdir'

def check_ingenuity(filename)

    skips = ['diversity_P1', 'YRI_trio_P1', 'LVNC_P1', 'PUR_trio_P1', 'ceph_1463']
    Rails.logger.debug "filename is #{filename}"
    ingenuity = Array.new
    begin
        File.open(filename, "r") do |f|
        while (line = f.gets)
	        # columns should be Barcode (assembly id), Name (some pseudo random well number and pedigree number?),
	        # description (roughly space delimited), subject id (GS0XXXX-DNA_XXX), Files (semicolon delmited)
	        columns = line.split("\t")
	        # easiest one to find in the system is going to be assembly
	        assembly_id = columns[0]
	        next if assembly_id.match("Barcode")
            assembly_id.gsub!("_masterVar","")
            if (!assembly_id.match("-ASM")) then
#                Rails.logger.debug "adding ASM to end"
                assembly_id = assembly_id+'-ASM'
            end
#            Rails.logger.debug "finding assembly #{assembly_id}"
            asm = Assembly.find_by_name(assembly_id)
	        asm = Assembly.find(:all, :conditions => ["name LIKE ?", "#{assembly_id}%"]) if asm.nil?
	        raise "More than one assembly found with #{assembly_id}" if asm.instance_of?(Array) && asm.size > 1
	        if asm.instance_of?(Array)
	            asm = asm.first
	        end
	        if asm.nil? then
	            # second best find is by name since most of the ones that are not found by barcode have a 
	            # sample id in the name column
	            sample = Sample.find_by_sample_vendor_id(columns[1])
	            if sample.nil? then
	                Rails.logger.debug "Didn't find #{assembly_id} or #{columns[1]}"
	            else 
#	                Rails.logger.debug "found sample #{sample.inspect}"
                    # getting the last assembly should be proper since that should be the current one
                    asm = sample.assays.last.assemblies.last 
#	                Rails.logger.debug "found asm #{asm.inspect} for sample #{sample.inspect}"
	                ingenuity.push(asm)
	            end
	        else
#	            Rails.logger.debug "found asm #{asm.inspect}"
                ingenuity.push(asm)
            end
        end
    end
    rescue => err
      Rails.logger.debug "Exception: #{err}"
    end

#    Rails.logger.debug "size is #{ingenuity.size}"
    timestamp = Time.new.strftime("%Y%m%d%H%M%S")
    outfilename = "ingenuity_add_#{timestamp}.txt"
    path = File.join(Dir::tmpdir, outfilename)
    outfile = File.open(path, "w+")
    outfile.write("Assembly Name\tAssembly Location\tPedigree\tSample Vendor ID\tISB Person ID\tCollaborator ID\n")
    Assembly.all.each do |assembly|
      if ingenuity.include? assembly then
#      	Rails.logger.debug "skipping assembly because it's included in list #{assembly.inspect}"
	    next
      end
#      Rails.logger.debug "Need to add #{assembly.inspect} to ingenuity"
      Rails.logger.debug "assembly #{assembly.inspect} does not have an assay association!!" unless assembly.assay
      next unless assembly.assay
      Rails.logger.debug "assembly #{assembly.inspect} assay #{assembly.assay.inspect} does not have a sample association!!" unless assembly.assay.sample
      next unless assembly.assay.sample
      next if skips.include? assembly.assay.sample.person.pedigree.tag
      outfile.write("#{assembly.name}\t#{assembly.location}\t#{assembly.assay.sample.person.pedigree.tag}\t#{assembly.assay.sample.sample_vendor_id}\t#{assembly.assay.sample.person.isb_person_id}\t#{assembly.assay.sample.person.collaborator_id}\n")
    end
    outfile.close
    return path
end

