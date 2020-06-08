class Assay < ActiveRecord::Base
  has_many :assemblies, :dependent => :destroy
  has_one :sample_assay
  has_one :sample, :through => :sample_assay

  validates_presence_of :name, :assay_type, :technology
  validates_uniqueness_of :name
  auto_strip_attributes :name, :assay_type, :technology, :description

  after_create :check_isb_assay_id
  after_update :check_isb_assay_id

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

  def check_isb_assay_id
    if self.isb_assay_id.nil? or !self.isb_assay_id.match(/isb_asy/) then
      isb_assay_id = "isb_asy_"+self.id.to_s
      self.isb_assay_id = isb_assay_id
      self.save
    end
  end

  def varfile
      self.assemblies.each do |assembly|
        if assembly.assembly_files.where(:file_type_id => 1).count > 0 then
          return true
        end
      end
    return false
  end

  def pedigree
    begin
      return self.sample.person.pedigree
    rescue
      logger.error("Error with pedigree_id call for assay #{self.inspect}")
      return nil
    end
  end

  def identifier
    "#{name} - #{vendor} - #{assay_type}"
  end

end
