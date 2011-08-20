class Sample < ActiveRecord::Base
  has_many :sample_assays
  has_many :assays, :through => :sample_assays
  belongs_to :sample_type
  has_many :acquisitions
  has_many :people, :through => :acquisitions
end
