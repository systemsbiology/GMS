class Sample < ActiveRecord::Base
  has_many :sample_assays
  has_many :assays, :through => :sample_assays
  belongs_to :sample_type
  has_one :acquisition
  has_one :person, :through => :acquisition

  validates_presence_of :sample_type_id, :status, :vendor_id, :volume, :concentration, :quantity
  validates_uniqueness_of :vendor_id

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
