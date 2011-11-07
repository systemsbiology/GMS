class Relationship < ActiveRecord::Base
  belongs_to :person, :class_name => "Person"
  belongs_to :relation, :class_name => "Person"
  validates_presence_of :person_id, :relation_id, :relationship_type, :name

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
        joins(:person => {:membership => :pedigree} ).
        where('pedigrees.id = ?', pedigree_id)
      end
    end
  }

  scope :order_by_pedigree, lambda {
    joins(:person => { :membership => :pedigree}).
    order('pedigrees.id', 'people.id')
  }

  def is_person?(person_id)
    if self.person_id == person_id
      return true
    else
      return false
    end
  end

  def is_relation?(relation_id)
    if self.relation_id == relation_id
      return true
    else
      return false
    end
  end


  def is_undirected?
    relationship_types = Settings.relationship_types

    if relationship_types[self.name].nil? then
      logger.error("Error: Relationship #{self.name} not recognized in Relationship.  is_undirected? returned false.")
      return false
    elsif relationship_types[self.name] == 'undirected'
      return true
    else
      return false
    end
  end

  def is_directed?
    relationship_types = Settings.relationship_types

    if relationship_types[self.name].nil? then
      logger.error("Error: Relationship #{self.name} not recognized in Relationship.  is_directed? returned false.")
      return false
    elsif relationship_types[self.name] == 'child' || relationship_types[self.name] == 'parent' then
      return true
    else
      return false
    end
  end

  def is_child?
    if self.relationship_type == 'child' then
      return true
    else
      return false
    end
  end

  def is_parent?
    if self.relationship_type == 'parent' then
      return true
    else
      return false
    end
  end

  # return the reverse name of a relationship father -> son, wife -> husband, defined in app/config/application.yml
  def reverse_name
    reverse_lookup = Settings.relationship_reverse

    reverse_name =  reverse_lookup[self.name]
    if reverse_name.kind_of?(Hash) then
      return reverse_name[self.relation.gender]
    else
      return reverse_name
    end
  end

  # returns the type for a relationship father -> directed, husband -> undirected, defined in app/config/application.yml
  def lookup_relationship_type
    relationship_types = Settings.relationship_types
    return relationship_types[self.name]
  end

  def correct_gender?
    relationship_gender = Settings.relationship_gender

    if relationship_gender[self.name].nil? then
      logger.debug("Error: relationship_gender does not contain #{self.name}.  Please add to config/application.yml before adding this relationship.")
      return false
    end

    if self.relationship_type.nil? then
      logger.debug("Error: relationship provided to relationship_gender does not contain a relationship_type.")
      return false
    end

    if self.name == 'monozygotic twin' then
      # monozygotic twins are always the same sex (unless they have a disease, which may mean this check should be removed if we get any cases of this)
      if self.person.gender == self.relation.gender then
        return true
      else
        return false
      end
    end

    if self.name == 'dizygotic twin' then
      # dizygotic twins can be any sex combination
      return true
    end

    if self.person.gender == relationship_gender[self.name] and self.relation.gender == relationship_gender[self.reverse_name] then
      return true
    else
      return false
    end
  end

#    if self.relationship_type == 'undirected' then
#      if self.name == 'husband' or self.name == 'wife' then
#        if self.person.gender == relationship_gender[self.name] and self.relation.gender == relationship_gender[self.reverse_name] then
#          return true
#        else
#          return false
#        end
#      elsif self.name == 'monozygotic twin' or self.name == 'dizygotic twin' then
#        # twins don't have a relationship gender constraint
#	logger.debug("correct_gender in monozygotic twins #{self.inspect}")
#        return true
#      end
#    end
#
##    if self.relationship_type == 'parent' then
##      logger.debug("in relatinship_type parent for #{self.inspect}")
##      if self.person.gender == relationship_gender[self.name] then
##        return true
##      else
##        return false
##      end
##    end
##
##    if self.relationship_type == 'child' then
#      logger.debug("in relatinship_type child for #{self.inspect} self.person.gender #{self.person.gender} raltionship_gender[self.name] #{relationship_gender[self.name]} self.relation.gender #{self.relation.gender} relationship_gender[self.reverse_name] #{relationship_gender[self.reverse_name]}" )
#      if self.person.gender == relationship_gender[self.name] and self.relation.gender == relationship_gender[self.reverse_name] then
#        return true
#      else
#        return false
#      end
##    end
#
#  end



end
