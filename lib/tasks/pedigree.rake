require 'pedigree_info' 

namespace :pedigree do

  desc "Write PedigreeDB datastore"
  task :write_pedigree_datastore => :environment do
    data_store = pedindex
    peddir_exists
    #json_data_store = ActiveSupport::JSON.encode(data_store)
    json_data_store = JSON.pretty_generate(data_store)
    data_store_filename = PEDFILES_DIR+PEDIGREE_DATA_STORE
    puts "writing data store #{data_store_filename}"
    File.open(data_store_filename, 'w') do |f|
      f.puts json_data_store
    end
    raise "Error: Data store #{data_store_filename} not created" unless File.exists?(data_store_filename)
  end

  desc "Write all PedigreeDB data JSON files."
  task :write_pedigrees => :environment do

    peddir_exists
    peds = Array.new
    puts "adding all pedigrees to list"
    Pedigree.all.each do |ped|
      peds.push(ped.id)
    end

    peds.each do |ped_id| 
      ped_hash = pedfile(ped_id)
      parent_rels = pedigree_relationships(ped_id)
      ped_hash["relationships"] = parent_rels
      #json_pedigree = ActiveSupport::JSON.encode(ped_hash) # no whitespace
      json_pedigree = JSON.pretty_generate(ped_hash)
      output_file = PEDFILES_DIR+pedigree_output_filename(Pedigree.find(ped_id))
      puts "writing file #{output_file}"
      File.open(output_file, 'w') do |f|
        f.puts json_pedigree
      end
      raise "Error: Pedfile #{output_file} not created" unless File.exists?(output_file)
    end

  end

  desc "Dump Pedigree relationships"
  task :dump_pedigree_relationships, [:pedigree_id] => :environment do |t, args|
    peds = Array.new
    puts "args is #{args.inspect}"
    if args[:pedigree_id].nil? then
      puts "adding all pedigrees to list"
      Pedigree.all.each do |ped|
        puts "addinng #{ped.id} to list"
        peds.push(ped.id)
      end
    else
      puts "adding pedigree to list #{args[:pedigree_id]}"
      peds.push(args[:pedigree_id])
    end

    peds.each do |ped_id|
      rels = pedigree_relationships(ped_id)
      puts "rels for pedigree #{ped_id} are #{rels.inspect}"
    end
  end

  desc "Write one PedigreeDB JSON file, must specify pedigree id"
  task :write_one_pedigree, [:pedigree_id] => :environment do |t, args|
    raise "No pedigree id provided" unless args[:pedigree_id]
    peddir_exists
    ped_id = args[:pedigree_id]
    ped_hash = pedfile(ped_id)
    parent_rels = pedigree_relationships(ped_id)
    ped_hash["relationships"] = parent_rels
    json_pedigree = JSON.pretty_generate(ped_hash)
    output_file = PEDFILES_DIR+pedigree_output_filename(Pedigree.find(ped_id))
    puts "writing file #{output_file}"
    File.open(output_file, 'w') do |f|
      f.puts json_pedigree
    end
    raise "Error: Pedfile #{output_file} not created" unless File.exists?(output_file)

  end

  def parse_json(filename)
    index_contents = File.read(filename)
    ActiveSupport::JSON.decode(index_contents)
  end

end
