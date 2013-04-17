namespace :extract do

  desc "Dump tables from the database"
  task :extract_fixtures => :environment do
    sql  = "SELECT * FROM %s"
    skip_tables = ["schema_info"]
    ActiveRecord::Base.establish_connection
    if (not ENV['TABLES'])
      tables = ActiveRecord::Base.connection.tables - skip_tables
    else
      tables = ENV['TABLES'].split(/, */)
    end
    if (not ENV['OUTPUT_DIR'])
      output_dir="#{Rails.root}/tmp/extract"
    else
      output_dir = ENV['OUTPUT_DIR'].sub(/\/$/, '')
    end
    (tables).each do |table_name|
      i = "000"
      File.open("#{output_dir}/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
        puts "wrote #{table_name} to #{output_dir}/"
      end
    end
  end

   desc "Dump all seeds"
   task :export_all_seeds => :environment do
     Rake::Task["extract:export_sample_type_seed"].invoke
     Rake::Task["extract:export_file_type_seed"].invoke
   end

  desc "Dump SampleTypes in seed format"
  task :export_sample_type_seed => :environment do
    SampleType.order(:id).all.each do |sample_type|
      puts "SampleType.create(#{sample_type.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end

  desc "Dump FileTypes in seed format"
  task :export_file_type_seed => :environment do
    FileType.order(:id).all.each do |file_type|
      puts "FileType.create(#{file_type.serializable_hash.delete_if {|key, value| ['created_at','updated_at','created_by','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end

end
