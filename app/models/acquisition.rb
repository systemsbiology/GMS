class Acquisition < ActiveRecord::Base
  belongs_to :person
  belongs_to :sample

  validates_presence_of :person_id, :sample_id
  validates_uniqueness_of :person_id, :scope => :sample_id, :message => "This sample is already associated with this person.  This error can generally be ignored.  If you wish to associate the sample with a different person, then edit the sample."

  attr_accessible :person_id, :sample_id, :method
end
