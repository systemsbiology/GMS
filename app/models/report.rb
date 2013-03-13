class Report < ActiveRecord::Base
  attr_accessible :name, :description, :report_type_id
end
