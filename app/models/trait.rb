class Trait < ActiveRecord::Base
  belongs_to :person
  belongs_to :phenotype

  auto_strip_attributes :trait_information, :output_order
  validates_presence_of :person_id, :phenotype_id

  attr_accessible :person_id, :phenotype_id, :trait_information, :output_order

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
        joins(:person => :pedigree).
        where('pedigrees.id = ?', pedigree_id)
      end
    end
  }

  scope :has_person, lambda { |person_id|
    unless person_id.blank?
      where(:person_id, person_id)
    end
  }

  def get_people_by_phenotype_and_trait_value(phenotype, trait_value)
        people = Array.new
        return people
  end


end
