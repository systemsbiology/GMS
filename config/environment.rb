# Load the Rails application.
require_relative 'application'

# Configuration directives for application locations
PEDIGREES_DIR = Rails.root.join('public/pedigrees')
MADELINE_DIR = Rails.root.join('public/pedigrees/madeline')
EXPORT_DIR = Rails.root.join('public/pedigrees/export') if Rails.env.development?
EXPORT_DIR = "/proj/famgen/gms" if Rails.env.production?
PEDIGREE_ROOT = "/proj/famgen/studies"
PEDFILES_DIR = Rails.root.join('public/pedigrees/pedFiles')
KWANZAA_DIR = Rails.root.join('public/pedigrees/kwanzaa')
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
CGI_VCF_GENOME_REFERENCE = "source_GENOME_REFERENCE"

# VCF header keys
VCF_SOURCE = "source" # only in snp files
VCF_FILEFORMAT = "fileformat"
VCF_GENOME_REFERENCE = "reference"

# where to find the header file for the Excel spreadsheet uploads
EXCEL_CGI_HEADER_INDEX_FILE = "config/cgi_manifest_indexes.yml"
EXCEL_FGG_HEADER_INDEX_FILE = "config/fgg_manifest_indexes.yml"
EXCEL_DELIVERY_INDEX_FILE = "config/delivery_indexes.yml"


# file types to add to the assembly_files table
# don't forget to add these to the file_types table if you add a new one!
FILE_TYPES = {
		# CGI FILES
		'var-' 			  =>  { 'type' => 'VAR-ANNOTATION', 'vendor' => 'CGI' },
		'gene-' 		  => { 'type' => 'GENE-ANNOTATION', 'vendor' => 'CGI' },
		'geneVarSummary-' 	  => { 'type' => 'GENE-VAR-SUMMARY-REPORT', 'vendor' => 'CGI'},
		'ncRNA-' 		  => {'type' => 'NCRNA-ANNOTATION', 'vendor' => 'CGI' },
		'cnvSegments' 		  => { 'type' => 'CNV-SEGMENTS', 'vendor' => 'CGI' },
		'highConfidenceJunctions' => { 'type' => 'JUNCTIONS', 'vendor' => 'CGI' },
		'summary-' 		  => { 'type' => 'SUMMARY', 'vendor' => 'CGI'},
		'highConfidenceSvEvents'  => {'type' => 'SVEVENTS', 'vendor' => 'CGI' },
        'masterVarBeta-'  => { 'type' => 'VAR-OLPL', 'vendor' => 'CGI'},
		# VCF FILES
		'.snp.filtered.vcf' 	  => { 'type' => 'VCF-SNP-ANNOTATION', 'vendor' => 'VCF' },
		'.indel.vcf' 		  => { 'type' => 'VCF-INDEL-ANNOTATION', 'vendor' => 'VCF' },
        'vcfBeta-'          => { 'type' => 'VCF-ANNOTATION', 'vendor' => 'CGI' },
		# Analysis directories
		'ReMastered_MasterVar_'   => { 'type' => 'ReMastered-MasterVar', 'vendor' => 'ISB'},
		'ReMastered_Var_' 	  => { 'type' => 'ReMastered-Var', 'vendor' => 'ISB'},
            }
FILE_SKIPS = {
         '.tbi' => { 'type' => 'tabix', 'category' => 'suffix' },
         'converted' => { 'type' => 'tabix', 'category' => 'middle'},
         'original' => { 'type' => 'patch', 'category' => 'middle'},
         'debug' => { 'type' => 'patch', 'category' => 'middle'},
         'masterVarBeta[-\d+\w+]+.tsv.gz' => {'type' => 'tabix', 'category' => 'frontback' },
}

# Dir[File.dirname(__FILE__) + "/../vendor/*"].each do |path|
#   gem_name = File.basename(path.gsub(/-\d+.\d+.\d+$/, ''))
#   gem_path = path + "/lib/" + gem_name + ".rb"
#   require gem_path if File.exists? gem_path
# end

# don't include the root, override as_json if you do need the root
ActiveRecord::Base.include_root_in_json = false

# Initialize the Rails application.
Rails.application.initialize!