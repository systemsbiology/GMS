class Delivery < ActiveRecord::Base
  validates_presence_of :date_uploaded, :sales_order, :spreadsheet_name
end
