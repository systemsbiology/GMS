class Assay < ActiveRecord::Base
  has_many :assemblies
  has_one :sample_assay
  has_one :sample, :through => :sample_assay

  validates_presence_of :name, :assay_type, :technology
  validates_uniqueness_of :name

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
      joins(:assemblies).
      where('assemblies.genome_reference_id = ?', reference).
      where('assemblies.file_type = ?', file_type)
    end
  }

  scope :include_pedigree, lambda {
    joins( :sample => { :person => :pedigree })
  }

  def identifier 
    "#{name} - #{vendor} - #{assay_type}"
  end
end
