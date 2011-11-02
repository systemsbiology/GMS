class Disease < ActiveRecord::Base
  has_many :phenotypes
  has_many :diagnoses
  has_many :people, :through => :diagnoses

  validates_presence_of :name
  validates_uniqueness_of :name
end
