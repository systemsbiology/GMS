class SampleAssay < ActiveRecord::Base
  belongs_to :sample
  belongs_to :assay

  validates_presence_of :sample_id, :assay_id
  validates_uniqueness_of :sample_id, :scope => :assay_id, :message => "This sample and assay are already associated.  This error can generally be ignored.  If you're trying to alter the sample and assay association then you should edit the sample."
end
