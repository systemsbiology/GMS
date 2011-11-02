class Assembly < ActiveRecord::Base
  belongs_to :assay
  belongs_to :genome_reference
  has_many :assembly_files

  validates_presence_of :name, :genome_reference_id, :assay, :location, :software, :software_version, :file_date
  validates_uniqueness_of :name, :location

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        { :include => { :assay => { :sample => { :person => :pedigree } } },
          :conditions => [ 'pedigrees.id = ?', pedigree_id]
        }
      end
    end
  }

  scope :is_current, lambda {
    { :conditions => [ 'current = ?', '1'] }
  }

end
