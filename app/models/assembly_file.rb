class AssemblyFile < ActiveRecord::Base
  has_ancestry
  belongs_to :assembly
  belongs_to :genome_reference
  belongs_to :file_type

  auto_strip_attributes :name, :description, :location, :metadata, :software, :software_version, :comments
  validates_presence_of :name, :genome_reference_id, :assembly, :location, :software, :software_version, :file_date
  validates_uniqueness_of :name, :location
  after_save :update_completeness

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
        joins(:assembly => {:assay => { :sample => { :person => :pedigree } } } ).
	where('pedigrees.id = ?', pedigree_id)
      end
    end
  }

  scope :has_file_type_id, lambda { |file_type_id|
    unless file_type_id.blank?
      where('file_type_id = ?',file_type_id)
    end
  }

  scope :is_current, lambda {
    { :conditions => [ 'current = ?', '1'] }
  }

  def identifier
    "#{name} - #{vendor} - #{self.file_type.type_name}"
  end

  def update_completeness
    if self.file_type_id == 1 or self.file_type_id == 8 then
      person = self.assembly.assay.sample.person
      logger.debug("setting person #{person.inspect} to complete")
      person.update_attributes(:complete => true)
      person.save
    end
  end

end
