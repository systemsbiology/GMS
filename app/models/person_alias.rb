class PersonAlias < ActiveRecord::Base
  belongs_to :person

  auto_strip_attributes :value
  validates_presence_of :person_id, :name, :value, :alias_type
end
