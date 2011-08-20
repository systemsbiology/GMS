class Membership < ActiveRecord::Base
  belongs_to :pedigree
  belongs_to :person
end
