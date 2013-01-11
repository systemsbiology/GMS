class Phenotype < ActiveRecord::Base
  has_many :people, :through => :traits
  has_many :traits, :dependent => :destroy
  belongs_to :disease
  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag
  validates_uniqueness_of :name, :tag

end
