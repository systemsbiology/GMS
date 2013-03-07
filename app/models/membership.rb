class Membership < ActiveRecord::Base
  belongs_to :pedigree
  belongs_to :person

  validates_presence_of :pedigree_id, :person_id
  validates_uniqueness_of :pedigree_id, :scope => :person_id, :message => "This person is already a member of this pedigree.  This error can generally be ignored.  If you want to change the pedigree that this person is a part of, then find the person and edit the pedigree information there."
  attr_accessible :pedigree_id, :person_id, :draw_duplicate
end
