class Study < ActiveRecord::Base
  has_many :pedigrees
  validates_presence_of :name, :tag, :collaborator, :collaborating_institution
end
