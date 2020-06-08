class TempObject < ActiveRecord::Base
  # this class is for storing objects temporarily to output a confirmation page
  # so that a bunch of objects don't get put into the database without being confirmed
  # that they are correct
  validates_presence_of :trans_id
end
