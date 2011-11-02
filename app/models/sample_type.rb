class SampleType < ActiveRecord::Base
  has_many :samples

  validates_presence_of :name
  validates_uniqueness_of :name
end
