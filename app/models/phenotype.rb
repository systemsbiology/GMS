class Phenotype < ActiveRecord::Base
  has_many :people, :through => :traits
  has_many :traits
  belongs_to :disease

  auto_strip_attributes :name, :description
  validates_presence_of :name
  validates_uniqueness_of :name
end
