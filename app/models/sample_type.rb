class SampleType < ActiveRecord::Base
  has_many :samples

  validates_presence_of :name
end
