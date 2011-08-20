class Phenotype < ActiveRecord::Base
  has_many :people, :through => :traits
  has_many :traits
  belongs_to :disease
end
