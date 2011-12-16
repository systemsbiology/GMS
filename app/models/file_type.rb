class FileType < ActiveRecord::Base
  has_many :assembly_files
  auto_strip_attributes :type_name
  validates_presence_of :type_name
  validates_uniqueness_of :type_name

end
