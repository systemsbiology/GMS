class FileType < ActiveRecord::Base
  validates_presence_of :type_name
  validates_uniqueness_of :type_name
end
