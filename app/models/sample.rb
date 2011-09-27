class Sample < ActiveRecord::Base
  has_many :sample_assays
  has_many :assays, :through => :sample_assays
  belongs_to :sample_type
  has_many :acquisitions
  has_one :person, :through => :acquisitions

    scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        { :include => { :person => :pedigree  },
          :conditions => [ 'pedigrees.id = ?', pedigree_id]
        }
      end
    end
  }

end
