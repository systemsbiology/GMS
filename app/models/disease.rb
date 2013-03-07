class Disease < ActiveRecord::Base
  has_many :phenotypes
  has_many :diagnoses
  has_many :people, :through => :diagnoses

  auto_strip_attributes :name, :omim_id, :description
  validates_presence_of :name
  validates_uniqueness_of :name
  attr_accessible :name, :omim_id, :description
end
