class Report < ActiveRecord::Base
  validates_presence_of :name, :description, :type
end
