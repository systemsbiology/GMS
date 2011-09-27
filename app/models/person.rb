class Person < ActiveRecord::Base
  acts_as_nested_set
  has_many :memberships
  has_one :pedigree, :through => :memberships
  has_many :offspring, :class_name => "Relationship", :foreign_key => "parent", :conditions => { :relationship_type => 'directed' }
#  has_many :parents, :class_name => "Relationship", :foreign_key => "child"
  has_many :husbands, :class_name => "Relationship", :foreign_key => "child", :conditions => { :relationship_type => 'undirected' }
  has_many :wives, :class_name => "Relationship", :foreign_key => "parent", :conditions => { :relationship_type => 'undirected' }
  has_many :aliases
  has_many :phenotypes, :through => :traits
  has_many :traits
  has_many :acquisitions
  has_many :samples, :through => :acquisitions


  def spouses
    wives = self.wives
    husbands = self.husbands
    results = wives + husbands
    return results
  end

  def relationships
    wives = self.wives
    husbands = self.husbands
    offspring = self.offspring
    results = wives+husbands+offspring
    return results
  end

  scope :has_pedigree, lambda { |pedigree|
    unless pedigree.blank?
      pedigree_id = pedigree[:id]
      unless pedigree_id.blank?
        { :include => :pedigree,
          :conditions => [ 'pedigrees.id = ?', pedigree_id]
        }
      end
    end
  }

  def full_identifier
    "#{self.pedigree.name} - #{isb_person_id} - #{collaborator_id}"
  end
end
