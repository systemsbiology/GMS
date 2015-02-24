class Phenotype < ActiveRecord::Base
  has_many :people, :through => :traits
  has_many :traits, :dependent => :destroy
  belongs_to :condition
  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag
  validates_uniqueness_of :name, :tag
  attr_accessible :condition_id, :name, :tag, :phenotype_type, :madeline_display, :description
end
