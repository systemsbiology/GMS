namespace :json do

  desc "Test a test.json file"
  task :file => :environment do
    json_index_file = "/u5/www/dev_sites/dmauldin/FGG_Genomes/vendor/plugins/gms/lib/tasks/test.json"
    obj = parse_json(json_index_file)
    puts obj.inspect
    obj.each do |o|
      puts "variants is "+o["variants"].to_s
      vars = o["variants"]
      puts "vars is "+vars["A"].to_s
      vars.each do |k, v|
        puts "v is "+v.to_s
      end
    end
  end

  def parse_json(filename)
    index_contents = File.read(filename)
    ActiveSupport::JSON.decode(index_contents)
  end

end

