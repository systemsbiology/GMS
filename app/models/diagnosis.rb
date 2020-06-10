class Diagnosis < ActiveRecord::Base
  belongs_to :person
  belongs_to :condition

  validates_presence_of :person_id, :condition_id
  validates_uniqueness_of :person_id, :scope => :condition_id, :message => "This person already has a diagnosis for this condition.  This error can generally be ignored.  If you want to alter the diagnosis information then you should edit the diagnosis and if you want to delete this diagnosis then you should look at the specific person page.  If you need to add multiple pieces of information about this condition then you should probably be adding phenotypes and traits."

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      if pedigree.kind_of?(Array) then
        pedigree_id = pedigree[0]
      elsif pedigree.kind_of?(ActionController::Parameters) or pedigree.kind_of?(Hash) then
        pedigree_id = pedigree[:id]
      else
        pedigree_id = pedigree.to_i
      end
      unless pedigree_id.blank?
        joins(:person => :pedigree)
        .where(pedigrees: {id: pedigree_id})
      end
    end
  }

end
