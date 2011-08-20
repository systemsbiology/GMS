class SampleAssay < ActiveRecord::Base
  belongs_to :sample
  belongs_to :assay
end
