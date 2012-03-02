require 'pedigree_info'
require 'madeline_utils'

class Pedigree < ActiveRecord::Base
  has_many :people, :through => :memberships
  has_many :memberships
  belongs_to :study

  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag, :study_id
  validates_uniqueness_of :name, :tag

  after_save :check_pedigree_tag
  after_update :check_pedigree_tag

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

end
