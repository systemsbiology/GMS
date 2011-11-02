class GenomeReference < ActiveRecord::Base
  has_many :assemblies
  has_many :assembly_files

  validates_presence_of :name
end
