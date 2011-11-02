# Load the rails application
require File.expand_path('../application', __FILE__)

PEDIGREES_DIR = Rails.root.join('public/pedigrees')
MADELINE_DIR = Rails.root.join('public/pedigrees/madeline')
PEDIGREE_ROOT = "/proj/famgen/studies"
PEDFILES_DIR = Rails.root.join('public/pedigrees/pedFiles')
PEDIGREE_DATA_STORE = "isb-pedigrees.dat"

Dir[File.dirname(__FILE__) + "/../vendor/*"].each do |path|
  gem_name = File.basename(path.gsub(/-\d+.\d+.\d+$/, ''))
  gem_path = path + "/lib/" + gem_name + ".rb"
  require gem_path if File.exists? gem_path
end

# Initialize the rails application
Gms::Application.initialize!
