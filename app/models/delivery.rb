class Delivery < ActiveRecord::Base
  attr_accessible :date_uploaded, :sales_order, :spreadsheet_name
  # we don't want it to mass assign :spreadsheet 
end
