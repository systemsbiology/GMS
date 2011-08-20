class AssayFile < ActiveRecord::Base
  has_one :assay
  belongs_to :genome_reference
end
