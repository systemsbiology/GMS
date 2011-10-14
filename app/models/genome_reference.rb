class GenomeReference < ActiveRecord::Base
  has_many :assay_files

  validates_presence_of :name
end
