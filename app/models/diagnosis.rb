class Diagnosis < ActiveRecord::Base
  belongs_to :person
  belongs_to :disease

  validates_presence_of :person_id, :disease_id

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        joins(:person => :pedigree).
        where('pedigrees.id = ?', pedigree_id)
      end
    end
  }

end
