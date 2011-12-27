def maddir_exists
  if !File.exists?(MADELINE_DIR) then
    Dir.mkdir(MADELINE_DIR)
  end
end

def madeline_file(pedigree)
 "madeline_#{pedigree.tag}_#{pedigree.id}.xml"
end

def madeline_header(pedigree)
  diseases = pedigree.diseases

  header = "FamilyID\tIndividualID\tGender\tFather\tMother\tMZTwin\tDZTwin\tAffected\tSampled\tDeceased\tDOB\tRelationshipEnded"
  header << "\t" + diseases.map(&:name).join("\t")

  phenotypes = pedigree.phenotypes
  header << "\t" + phenotypes.map(&:name).join("\t")

  return header
end

# takes an ordered list of people and writes out their relationships
def to_madeline(pedigree, people)

  results = Array.new
  familyID = pedigree.tag

  diseases = pedigree.diseases
  phenotypes = pedigree.phenotypes

  twin_letter = 'A'
  people.each do |person|
    cp, twin_letter = create_row(person, familyID, diseases, phenotypes, twin_letter)
    results.push(cp)
  end # end people.each

  childless_marriages = pedigree.find_childless_marriages # hash of person_id = person_id
  childless_marriages.each do |father_id, mother_id|
    father_ident = Person.find(father_id).madeline_identifier
    mother_ident = Person.find(mother_id).madeline_identifier
    fake_child = Person.new
    fake_child.collaborator_id = "^"+(0...8).map{65.+(rand(25)).chr}.join
    cp = create_fake(fake_child, familyID, diseases, phenotypes, father_ident, mother_ident) 

    results.push(cp)
  end

  return results

end

def create_row(person, familyID, diseases, phenotypes, twin_letter)
    current_person = Array.new
    current_person.push(familyID)
    current_person.push(person.madeline_identifier) # isb_person_id - collaborator_ids
    current_person.push(person.gender)
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
      # this increments once per person rather than once per set of twins... need to add checks and lookups 
      #twin_letter = twin_letter.next

    else
      current_person.push('.')
    end

    dztwin = person.twins.where(:name => "dizygotic twin")
    if (dztwin.size > 0) then
      current_person.push(twin_letter)
      #twin_letter = twin_letter.next
    else
      current_person.push('.')
    end

    # Affected
    if (person.diseases.size > 0)
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
      if (!person.dod.nil? and person.dod < Time.now) then # if person died before today
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
      logger.debug("#{person.divorced?} is true? for person #{person.inspect}")
      current_person.push('D')
    else
      current_person.push('.')
    end

    diseases.each do |disease|
      diagnoses = disease.diagnoses.where(:person_id => person.id)
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

  return current_person, twin_letter
end


def create_fake(person, familyID, diseases, phenotypes, father_id, mother_id)
    current_person = Array.new
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

    diseases.each do |disease|
      current_person.push('.')
    end

    phenotypes.each do |pheno|
      current_person.push('.')
    end

  return current_person
end
