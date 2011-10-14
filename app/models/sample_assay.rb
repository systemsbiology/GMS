class SampleAssay < ActiveRecord::Base
  belongs_to :sample
  belongs_to :assay

  validates_presence_of :sample_id, :assay_id
end
