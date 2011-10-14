class PersonAlias < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id, :value, :alias_type
end
