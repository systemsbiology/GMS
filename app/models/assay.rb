class Assay < ActiveRecord::Base
  has_many :assay_files
  has_many :sample_assays
  has_many :samples, :through => :sample_assay
end
