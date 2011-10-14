class Acquisition < ActiveRecord::Base
  belongs_to :person
  belongs_to :sample

  validates_presence_of :person_id, :sample_id
end
