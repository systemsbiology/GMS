class Pedigree < ActiveRecord::Base
  has_many :people, :through => :memberships
  has_many :memberships
  belongs_to :studies
end
