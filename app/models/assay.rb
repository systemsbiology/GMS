class Assay < ActiveRecord::Base
  has_many :assemblies, :dependent => :destroy
  has_one :sample_assay
  has_one :sample, :through => :sample_assay

  validates_presence_of :name, :assay_type, :technology
  validates_uniqueness_of :name
  auto_strip_attributes :name, :assay_type, :technology, :description

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

  scope :has_name, lambda { |name|
    unless name.blank?
      where('name = ?',name)
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
