class Assay < ActiveRecord::Base
  has_many :assay_files
  has_many :sample_assay
  has_one :sample, :through => :sample_assay

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        { :include => { :sample => { :person => :pedigree } },
          :conditions => [ 'pedigrees.id = ?', pedigree_id]
        }
      end
    end
  }

  scope :has_reference, lambda { |reference, file_type|
    unless reference.blank?
      joins(:assay_files ).
      where('assay_files.genome_reference_id = ?', reference).
      where('assay_files.file_type = ?', file_type)
    end
  }

  scope :include_pedigree, lambda {
    joins( :sample => { :person => :pedigree })
  }

    
end
