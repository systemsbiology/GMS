# Load the rails application
require File.expand_path('../application', __FILE__)

# Configuration directives for application locations
PEDIGREES_DIR = Rails.root.join('public/pedigrees')
MADELINE_DIR = Rails.root.join('public/pedigrees/madeline')
PEDIGREE_ROOT = "/proj/famgen/studies"
PEDFILES_DIR = Rails.root.join('public/pedigrees/pedFiles')
CSVDIR = Rails.root.join('tmp/csv')

# filename of the pedigree data store
PEDIGREE_DATA_STORE = "isb-pedigrees.dat"

# CGI header keys 
CGI_ASSEMBLY_ID = "ASSEMBLY_ID"
CGI_COSMIC_VERSION = "COSMIC" # not used
CGI_DBSNP_BUILD = "DBSNP_BUILD" # not used
CGI_GENOME_REFERENCE = "GENOME_REFERENCE"
CGI_SAMPLE = "SAMPLE"
CGI_SOFTWARE_PROGRAM = "GENERATED_BY" # there are two values for this in some of the files, the more general one is overwritten by the more specific one because it comes later than the general one
CGI_GENERATED_DATE = "GENERATED_AT"
CGI_SOFTWARE_VERSION = "SOFTWARE_VERSION"
CGI_FORMAT_VERSION = "FORMAT_VERSION"
CGI_FILE_TYPE = "TYPE"


# CGI file types to add to the assembly_files table
CGI_FILES = {
		'var-' => 'VAR-ANNOTATION',
		'gene-' => 'GENE-ANNOTATION',
		'geneVarSummary-' => 'GENE-VAR-SUMMARY-REPORT',
		'ncRNA-' => 'NCRNA-ANNOTATION',
		'cnvSegments' => 'CNV-SEGMENTS',
		'highConfidenceJunctions' => 'JUNCTIONS',
		'summary-' => 'SUMMARY'
            }


Dir[File.dirname(__FILE__) + "/../vendor/*"].each do |path|
  gem_name = File.basename(path.gsub(/-\d+.\d+.\d+$/, ''))
  gem_path = path + "/lib/" + gem_name + ".rb"
  require gem_path if File.exists? gem_path
end

# Initialize the rails application
Gms::Application.initialize!
