class Study < ActiveRecord::Base
  has_many :pedigrees
  validates_presence_of :name, :tag, :collaborator, :collaborating_institution
  validates_uniqueness_of :name, :tag
end
