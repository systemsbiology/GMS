class GenomeReference < ActiveRecord::Base
  has_many :assay_files
end
