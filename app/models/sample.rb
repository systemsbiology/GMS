class Sample < ActiveRecord::Base
  before_destroy :trigger_person_sample_check
  # assays has to come before sample_assays in order for the dependent destroy to work
  has_many :assays, :through => :sample_assays, :dependent => :destroy
  has_many :sample_assays, :dependent => :destroy
  belongs_to :sample_type
  has_one :acquisition, :dependent => :destroy
  has_one :person, :through => :acquisition

  auto_strip_attributes :sample_vendor_id, :volume, :concentration, :quantity, :protocol, :comments
  validates_presence_of :sample_type_id, :status, :sample_vendor_id #, :volume, :concentration, :quantity
  validates_uniqueness_of :sample_vendor_id

  after_save :check_isb_sample_id, :trigger_person_sample_check
  after_commit :trigger_person_sample_check

  attr_accessible :customer_sample_id, :sample_type_id, :status, :date_submitted, :protocol, :volume, :concentration, :quantity, :date_received, :description, :comments, :pedigree_id, :sample_vendor_id

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      if pedigree.kind_of?(Array) then
        pedigree_id = pedigree[0]
      elsif pedigree.kind_of?(Hash) then
      pedigree_id = pedigree[:id]
      else
      pedigree_id = pedigree.to_i
      end
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
      self.isb_sample_id = isb_sample_id
      self.save
    end
  end

  def trigger_person_sample_check
    person = self.person
    return if person.nil?
    person.check_sequencing_status
  end

  def varfile
    self.assays.each do |assay|
      assay.assemblies.each do |assembly|
        if assembly.assembly_files.where(:file_type_id => 1).count > 0 then
	  return true
	end
      end
    end
    return false

  end

  def identifier 
    if self.person.nil? then
      return "#{isb_sample_id} - #{sample_vendor_id} - NA"
    else 
      return "#{isb_sample_id} - #{sample_vendor_id} - #{self.person.identifier}"
    end
  end

  def pedigree
    begin
      return self.person.pedigree
    rescue
      logger.error("Error with pedigree_id call for sample #{self.inspect}")
      return nil
    end
  end


end
