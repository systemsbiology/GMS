require 'pedigree_info'
require 'madeline_utils'

class Pedigree < ActiveRecord::Base
  after_save :check_pedigree_tag, :check_isb_pedigree_id
  after_update :check_pedigree_tag, :check_isb_pedigree_id
  before_destroy :destroy_people

  has_many :people, :through => :memberships, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  belongs_to :study

  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag, :study_id
  validates_uniqueness_of :name, :tag

  attr_accessible :name, :tag, :study_id, :directory, :description, :version, :genotype_vector_date, :quartet_date, :autozygosity_date, :relation_pairing_date

  def phenotypes
    self.people.map(&:phenotypes).flatten.uniq
  end

  def conditions
    self.people.map(&:conditions).flatten.uniq
  end

  def write_pedigrees
    data_store = pedigree_info
    json_data_store = ActiveSupport::JSON.encode(data_store)
    File.open("isb-pedigrees.dat", 'w') do |f|
      f.puts json_data_store
    end
  end

  # count the child and spouse relationships
  def relationship_count
    count = 0
    self.people.each do |person|
      count += person.offspring.size
      count += person.spouses.size
    end
    return count
  end

  def find_childless_marriages
    ordered_people = ordered_pedigree(self.id)
    cm = Array.new
    cmhash = Hash.new
    ordered_people.each do |person|
      next if person.nil?
      #logger.debug("find_childless_marriages person #{person.inspect}")
      #logger.debug("preson spouses #{person.spouses}")
      #logger.debug("prson offspring #{person.offspring}")
      if (person.spouses.size > 0 and person.offspring.empty?) then
        #logger.debug("person is a candidate! #{person.spouses.size} #{person.offspring.empty?}")
        unless (cm.include?(person.id)) then
          #logger.debug("adding person to cm!")
          cm.push(person.id)
          cm.push(person.spouses.first.relation.id)
          cmhash[person.id] = person.spouses.first.relation.id
        end
      end
    end
    #logger.debug("find_childless_marriages #{cmhash.inspect}")
    return cmhash
  end

  def check_pedigree_tag
    if self.tag and self.tag.match(/ /) then
      tag = self.tag.gsub!(/ /, "_")
      self.tag = tag
      self.save
    end
  end

  def check_isb_pedigree_id
    if self.isb_pedigree_id.nil? then
      isb_ped = 'isb_ped_'+self.id.to_s
      self.isb_pedigree_id = isb_ped
      self.save
    end
  end

  # take a pedigree id in and give back an array of hashes of all of the quartets in the pedigree
  def quartets
    quartets = Array.new
    peopleByFamily = Hash.new
    self.people.each do |person|
      (father_rel, mother_rel) = person.parents
       next if father_rel.nil? and mother_rel.nil?
       father = father_rel.relation # person is the child
       mother = mother_rel.relation
       peopleByFamily[father] = Hash.new if peopleByFamily[father].nil?
       peopleByFamily[father][mother] = Array.new if peopleByFamily[father][mother].nil?
       peopleByFamily[father][mother].push(person)
    end
    family_size = 2
    peopleByFamily.each do |father, inner|
      inner.each do |mother, children|
        childrenCombos = children.combination(family_size).to_a
	quartets.push([father, mother, childrenCombos])
      end
    end
    
    return quartets
  end

  def genomic_count
    complete_count = 0
    self.people.each do |person|
        if person.complete then
            complete_count = complete_count+1
        end
    end
    return complete_count
  end

  # return 1 if there are no 'planning_on_sequencing' members that don't have assembly files
  def complete
    plan_count = 0
    complete_count = 0
    self.people.each do |person|
      if person.planning_on_sequencing then
        # check to see if they have a sample. return true if one sample is complete
	    plan_count = plan_count+1
        if person.complete then 
	        complete_count = complete_count+1
	    end
      end
    end
    return true if ((plan_count > 0) and (plan_count == complete_count))
    return false
  end

  def destroy_people
    people = self.people
    #logger.debug("found #{people.inspect} in destroy_people")
    people.each do |person|
      person.destroy
    end

  end

end
