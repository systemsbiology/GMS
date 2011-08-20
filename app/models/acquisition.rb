class Acquisition < ActiveRecord::Base
  belongs_to :person
  belongs_to :sample
end
