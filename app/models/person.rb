class Person < ActiveRecord::Base
#  has_many :memberships
  has_one :membership
  has_one :pedigree, :through => :membership
  has_many :offspring, :class_name => "Relationship", :foreign_key => "person_id", :conditions => { :relationship_type => 'parent' }
  # either check the relationship_type parent for the relation_id, OR check for relationship_type child for person_id
#  has_many :parents, :class_name => "Relationship", :foreign_key => "relation_id", :conditions => { :relationship_type => 'parent' }
  has_many :parents, :class_name => "Relationship", :foreign_key => "person_id", :conditions => { :relationship_type => 'child'}
#  has_many :parents, :class_name => "Relationship", :foreign_key => "relation_id", :conditions => { :relationship_type => 'parent'}, :include => :person, :order => "people.gender desc"
  has_many :spouses, :class_name => "Relationship", :foreign_key => "person_id", :conditions => { :relationship_type => "undirected" }
  has_many :twins, :class_name => "Relationship", :foreign_key => "person_id", :conditions => ["name like ?","%twin%"]
  has_many :person_aliases, :class_name => "PersonAlias"
  has_many :traits
  has_many :phenotypes, :through => :traits
  has_many :acquisitions
  has_many :samples, :through => :acquisitions
  has_many :diagnoses
  has_many :diseases, :through => :diagnoses


  auto_strip_attributes :collaborator_id
  validates_presence_of :collaborator_id, :gender
  validates_uniqueness_of :collaborator_id, :isb_person_id

  def ordered_parents
    parent_relationships = self.parents
    male = Array.new
    female = Array.new
    parent_relationships.each do |rel|
      parent = rel.relation
      male.push(rel) if parent.gender == "male"
      female.push(rel) if parent.gender == "female"
    end

    parents = male | female
    return parents
  end

  def father
    parent_relationships = self.parents
    father = Array.new
    parent_relationships.each do |rel|
      father.push(rel.relation) if rel.relation.gender == 'male'
    end
    return father
  end

  def mother
    parent_relationships = self.parents
    mother = Array.new
    parent_relationships.each do |rel|
      mother.push(rel.relation) if rel.relation.gender == 'female'
    end
    return mother
  end

  def relationships
    spouses = self.spouses
    offspring = self.offspring
    parents = self.parents
    results = Array.new
    results.concat(spouses)
    results.concat(offspring)
    results.concat(parents)
    return results
  end

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
        joins(:pedigree).
        where('pedigrees.id = ?', pedigree_id)
      end
    end
  }

  scope :include_samples, lambda {
    joins("LEFT OUTER JOIN acquisitions aq on aq.person_id = people.id left outer join samples s on aq.sample_id = s.id")
  }

  def sequenced
    return "#{planning_on_sequencing}"
  end

  def full_collaborator
    if self.person_aliases.size > 0 then
      return "#{collaborator_id}; #{self.person_aliases.map(&:value).join("; ")}"
    else
      return "#{collaborator_id}"
    end
  end

  def full_identifier
    if self.pedigree and self.person_aliases.size > 0 then
      return "#{self.pedigree.name} - #{isb_person_id} - #{collaborator_id}; #{self.person_aliases.map(&:value).join("; ")}"
    elsif self.pedigree then
      return "#{self.pedigree.name} - #{isb_person_id} - #{collaborator_id}"
    else
      return "Missing Pedigree - #{isb_person_id} - #{collaborator_id}"
    end
  end

  def ped_identifier
    if self.pedigree then
      return "#{self.pedigree.name} - #{isb_person_id} - #{collaborator_id}"
    else
      return "Missing Pedigree - #{isb_person_id} - #{collaborator_id}"
    end
  end

  def identifier
    if self.person_aliases.size > 0 then
      return "#{isb_person_id} - #{collaborator_id}; #{self.person_aliases.map(&:value).join("; ")}"
    else
      return "#{isb_person_id} - #{collaborator_id}"
    end
  end
end
