class Sample < ActiveRecord::Base
  # assays has to come before sample_assays in order for the dependent destroy to work
  has_many :assays, :through => :sample_assays, :dependent => :destroy
  has_many :sample_assays, :dependent => :destroy
  belongs_to :sample_type
  has_one :acquisition, :dependent => :destroy
  has_one :person, :through => :acquisition

  auto_strip_attributes :sample_vendor_id, :volume, :concentration, :quantity, :protocol, :comments
  validates_presence_of :sample_type_id, :status, :sample_vendor_id #, :volume, :concentration, :quantity
  validates_uniqueness_of :sample_vendor_id

  after_create :check_isb_sample_id
  after_update :check_isb_sample_id

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

  scope :has_person, lambda { |person|
    unless person.blank? or person[:id].nil?
      person_id = person[:id]
      unless person_id.blank?
        { :include => :person,
	:conditions => ['people.id = ?', person_id] }
      end
    end
  }

  scope :order_by_pedigree 
    {
      :include => { :person => :pedigree},
      :order => 'pedigrees.name'
    }

  def check_isb_sample_id
    if self.isb_sample_id.nil? or !self.isb_sample_id.match(/isb_sample/) then
      isb_sample_id = "isb_sample_"+self.id.to_s
      self.update_attributes(:isb_sample_id => isb_sample_id)
    end
  end

  def identifier 
    if self.person.nil? then
      return "#{isb_sample_id} - #{sample_vendor_id} - NA"
    else 
      return "#{isb_sample_id} - #{sample_vendor_id} - #{self.person.identifier}"
    end
  end

  # return true if it has a VAR-ANNOTATION or a VCF-SNP-ANNOTATION
  def complete
    self.assays.each do |assay|
      assay.assemblies.each do |assembly|
        if assembly.complete then
	  return true
	end
      end
    end
    return false
  end

end
