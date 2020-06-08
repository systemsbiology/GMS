class GenomeReference < ActiveRecord::Base
  has_many :assemblies
  has_many :assembly_files

  auto_strip_attributes :name, :location, :description, :code
  validates_presence_of :name
end
