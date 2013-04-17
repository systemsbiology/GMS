namespace :assembly do

  desc "Test find_assembly_files"
  task :test_find_assembly_files => :environment do
    test = Assembly.find(132)
    files = test.find_assembly_files
    puts "files is #{files.inspect}"
  end

  desc "Test check_assembly_files"
  task :test_check_assembly_files => :environment do
    Assembly.all.each do |test|
      files = test.check_assembly_files
      if files.size > 0 then
      puts "files is #{files.inspect}"
      end
    end
  end

  desc "Test add_assembly_files"
  task :test_add_assembly_files => :environment do
    test = Assembly.find(717)
    puts "test #{test.inspect}"
    files = test.add_assembly_files
    puts "files is #{files.inspect}"
  end

  desc "Test update_assembly_files"
  task :test_update_assembly_files => :environment do
    test = Assembly.find(717)
    puts "test #{test.inspect}"
    files = test.update_assembly_files
    puts "files is #{files.inspect}"
  end

  desc "Run ensure_files_up_to_date on all assemblies"
  task :run_ensure_files_up_to_date => :environment do
    Assembly.all.each do |assembly|
      assembly.ensure_files_up_to_date
    end
  end
end
