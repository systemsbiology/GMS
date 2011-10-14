class AssayFile < ActiveRecord::Base
  has_ancestry
  belongs_to :assay
  belongs_to :genome_reference

  validates_presence_of :name, :genome_reference_id, :assay, :location, :file_type, :software, :software_version, :file_date, :current

  scope :has_file_type, lambda { |file_type| 
    unless file_type.blank?
      { :conditions => { :file_type => file_type} }
    end
  }
  
  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        { :include => { :assay => { :sample => { :person => :pedigree } } },
          :conditions => [ 'pedigrees.id = ?', pedigree_id]
        }
      end
    end
  }

  scope :is_current, lambda {
    { :conditions => [ 'current = ?', '1'] }
  }

end
