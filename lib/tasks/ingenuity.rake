require 'fileutils'
require 'ingenuity'

namespace :ingenuity do
  
  desc "Take a file of Ingenuity samples and determine samples in GMS that haven't been uploaded"
  task :find_missing_ingenuity, [:file] => :environment do |t, args|
    puts "file is #{args[:file]}"
    raise "No file provided" unless args[:file]
    raise "File #{args[:file]} doesn't exist" unless File.exist?(args[:file])
    outfilename = check_ingenuity(args[:file])
    puts "outfile with results is #{outfilename}"
  end

end
