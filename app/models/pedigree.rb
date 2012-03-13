require 'pedigree_info'
require 'madeline_utils'

class Pedigree < ActiveRecord::Base
  has_many :people, :through => :memberships
  has_many :memberships
  belongs_to :study

  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag, :study_id
  validates_uniqueness_of :name, :tag

  after_save :check_pedigree_tag, :check_isb_pedigree_id
  after_update :check_pedigree_tag, :check_isb_pedigree_id

  def phenotypes
    self.people.map(&:phenotypes).flatten.uniq
  end

  def diseases
    self.people.map(&:diseases).flatten.uniq
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
      if (person.spouses.size > 0 and person.offspring.empty?) then
        unless (cm.include?(person.id)) then
          cm.push(person.id)
          cm.push(person.spouses.first.relation.id)
          cmhash[person.id] = person.spouses.first.relation.id
        end
      end
    end
    return cmhash
  end

  def check_pedigree_tag
    if self.tag.match(/ /) then
      tag = self.tag.gsub!(/ /, "_")
      self.update_attributes(:tag => tag)
    end
  end

  def check_isb_pedigree_id
    if self.isb_pedigree_id.nil? then
      isb_ped = 'isb_ped_'+self.id.to_s
      self.update_attributes(:isb_pedigree_id => isb_ped)
    end
  end

end
