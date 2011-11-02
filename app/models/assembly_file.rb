class AssemblyFile < ActiveRecord::Base
  has_ancestry
  belongs_to :assembly
  belongs_to :genome_reference

  validates_presence_of :name, :genome_reference_id, :assembly, :location, :file_type, :software, :software_version, :file_date

  scope :has_file_type, lambda { |file_type| 
    unless file_type.blank?
      where(:file_types_id => file_type)
    end
  }
  
  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      if pedigree[:id] then
        pedigree_id = pedigree[:id]
      else
        pedigree_id = pedigree
      end
      unless pedigree_id.blank?
        joins(:assembly => {:assay => { :sample => { :person => :pedigree } } } ).
	where('pedigrees.id = ?', pedigree_id)
      end
    end
  }

  scope :is_current, lambda {
    { :conditions => [ 'current = ?', '1'] }
  }

end
