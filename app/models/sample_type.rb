class SampleType < ActiveRecord::Base
  has_many :samples

  auto_strip_attributes :name, :description, :tissue
  validates_presence_of :name
  validates_uniqueness_of :name
  attr_accessible :name, :description, :tissue
end
