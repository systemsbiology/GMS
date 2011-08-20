class Person < ActiveRecord::Base
  has_many :memberships
  has_many :pedigrees, :through => :memberships
  has_many :relationships
  has_many :aliases
  has_many :phenotypes, :through => :traits
  has_many :traits
  has_many :acquisitions
  has_many :samples, :through => :acquisitions
end
