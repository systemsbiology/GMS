class Acquisition < ActiveRecord::Base
  belongs_to :person
  belongs_to :sample

  validates_presence_of :person_id, :sample_id
  validates_uniqueness_of :person_id, :scope => :sample_id, :message => "This sample is already associated with this person.  This error can generally be ignored.  If you wish to associate the sample with a different person, then edit the sample."

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

end
