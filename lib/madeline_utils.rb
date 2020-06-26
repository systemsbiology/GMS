def maddir_exists
  if !File.exists?(MADELINE_DIR) then
    Dir.mkdir(MADELINE_DIR)
  end
end

def madeline_file(pedigree)
 "madeline_#{pedigree.tag}_#{pedigree.id}.xml"
end

def madeline_header(pedigree)
  conditions = pedigree.conditions

  header = "FamilyID\tIndividualID\tGender\tFather\tMother\tMZTwin\tDZTwin\tAffected\tSampled\tDeceased\tDOB\tRelationshipEnded\tSortOrder"
  unless conditions.empty?
    header << "\t" + conditions.map(&:name).join("\t")
  end

  phenotypes = pedigree.people.map { |p| p.phenotypes.where(:madeline_display => 1) }.flatten.uniq
  unless phenotypes.empty?
    header << "\t" + phenotypes.map(&:name).join("\t")
  end
  logger.debug("header #{header}")
  return header
end

# takes an ordered list of people and writes out their relationships
def to_madeline(pedigree, people)
  results = Array.new
  familyID = pedigree.tag

  conditions = pedigree.conditions
  phenotypes = pedigree.people.map { |p| p.phenotypes.where(:madeline_display => 1) }.flatten.uniq

  twin_letter = 'A'
  twin_count = 0
  people.each do |person|
		# this doesn't work for triplets?!?
      #blah = twin_count % 2
      #if (((twin_count % 2) == 0) and twin_count > 0) then
          # in order for the letter to not be the same, we need to create a new object.
      #    tl = twin_letter.dup
      #    tl.next!
      #    twin_letter = tl
      #    twin_count = 0
      #end
      cp, twin_count = create_row(person, familyID, conditions, phenotypes, twin_letter, twin_count)
      results.push(cp)
  end # end people.each

  logger.debug("results before childless marriages #{results.inspect}")
  childless_marriages = pedigree.find_childless_marriages # hash of person_id = person_id
  childless_marriages.each do |father_id, mother_id|
    father_ident = Person.find(father_id).madeline_identifier
    mother_ident = Person.find(mother_id).madeline_identifier
    fake_child = Person.new
    fake_child.collaborator_id = "^"+(0...8).map{65.+(rand(25)).chr}.join
    cp = create_fake(fake_child, familyID, conditions, phenotypes, father_ident, mother_ident)

    results.push(cp)
  end

  logger.debug("to_madeline results #{results.inspect}")
  return results

end

def create_row(person, familyID, conditions, phenotypes, twin_letter, twin_count)
    return [],twin_count if person.nil?
    current_person = Array.new
    #"FamilyID\tIndividualID\tGender\tFather\tMother\tMZTwin\tDZTwin\tAffected\tSampled\tDeceased\tDOB\tRelationshipEnded\tSortOrder"
    current_person.push(familyID)
    current_person.push(person.madeline_identifier) # isb_person_id - collaborator_ids
    current_person.push(person.gender)
    logger.debug("create_row for person #{person.inspect} father #{person.father.inspect} mother #{person.mother.inspect}")
    if person.father.nil? or person.father.empty? then
      current_person.push('.')
    else
      current_person.push(person.father.first.madeline_identifier)
    end
    if person.mother.nil? or person.mother.empty? then
      current_person.push('.')
    else
      current_person.push(person.mother.first.madeline_identifier)
    end
    mztwin = person.twins.where(:name => "monozygotic twin")
    if (mztwin.size > 0) then
      current_person.push(twin_letter)
      twin_count = twin_count + 1
    else
      current_person.push('.')
    end

    dztwin = person.twins.where(:name => "dizygotic twin")
    if (dztwin.size > 0) then
      current_person.push(twin_letter)
      twin_count += 1
    else
      current_person.push('.')
    end

    # Affected
    if (person.conditions.size > 0)
      current_person.push('Y')
    else
      current_person.push('.')
    end

    #Sampled
    if (person.sequenced? == true and person.samples.size > 0) then
      current_person.push('Y')
    else
      current_person.push('.')
    end

    # Deceased
    if (person.deceased) then
      current_person.push('Y')
    else
      if (!person.dod.nil? and person.dod < Time.now.to_date) then # if person died before today
        current_person.push('Y')
      else
        current_person.push('.')
      end
    end

    # Date of Birth
    if (!person.dob.nil?) then
      current_person.push(person.dob)
    else
      current_person.push('.')
    end

    #RelationshipEnded
    # if we run into one person that is divorced multiple times then we'll need
    # to recode ordered_pedigree and this to go by relationships instead of by people
    if (person.divorced?) then
      #logger.debug("#{person.divorced?} is true? for person #{person.inspect}")
      current_person.push('D')
    else
      current_person.push('.')
    end

    #SortOrder
    if person.father.nil? or person.father.empty? then
      if person.mother.nil? or person.mother.empty? then
        current_person.push(".")
      else
        #order children by mother
	rel = Relationship.where(:person_id => person.mother.first.id, :relation_id => person.id)
        current_person.push(rel.first.relation_order)
      end
    else
      #order children by father
      rel = Relationship.where(:person_id => person.father.first.id, :relation_id => person.id)
      if rel.first && rel.first.relation_order then
        current_person.push(rel.first.relation_order)
      else
        current_person.push('.')
      end
    end

    conditions.each do |condition|
      diagnoses = condition.diagnoses.where(:person_id => person.id)
      if diagnoses.nil? or diagnoses.empty? then
        current_person.push('.')
      else
        current_person.push('Y')
      end
    end

    phenotypes.each do |pheno|
      person_traits = pheno.traits.where(:person_id => person.id)
      flag = 0
      value = '.'
      unless person_traits.empty? then
        person_traits.each do |person_trait|
          unless person_trait.nil?
            flag = 1
	    if person_trait.trait_information then
	      value = person_trait.trait_information
	    else
	      value = 'Y'
	    end
          end
        end
      end

      current_person.push(value)
    end


  return current_person, twin_count
end


def create_fake(person, familyID, conditions, phenotypes, father_id, mother_id)
    current_person = Array.new
    #"FamilyID\tIndividualID\tGender\tFather\tMother\tMZTwin\tDZTwin\tAffected\tSampled\tDeceased\tDOB\tRelationshipEnded\tSortOrder"
    current_person.push(familyID)
    current_person.push(person.madeline_identifier) # isb_person_id - collaborator_ids
    current_person.push('male') #gender
    current_person.push(father_id)
    current_person.push(mother_id)
    current_person.push('.') # MZTwin
    current_person.push('.') # DZTwin
    current_person.push('.') # Affected
    current_person.push('.') #Sampled
    current_person.push('.') # Deceased
    current_person.push('.') # DOB
    current_person.push('.') # RelationshipEnded
    current_person.push('1') # Sort Order

    conditions.each do |condition|
      current_person.push('.')
    end

    phenotypes.each do |pheno|
      current_person.push('.')
    end

  return current_person
end
