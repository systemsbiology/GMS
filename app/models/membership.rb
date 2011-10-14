class Membership < ActiveRecord::Base
  belongs_to :pedigree
  belongs_to :person

  validates_presence_of :pedigree_id, :person_id
end
