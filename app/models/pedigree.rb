class Pedigree < ActiveRecord::Base
  has_many :people, :through => :memberships
  has_many :memberships
  belongs_to :study

  validates_presence_of :name, :tag, :study_id

  def phenotypes 
    self.people.map(&:phenotypes).flatten.uniq
  end

  def diseases
    self.people.map(&:diseases).flatten.uniq
  end

end
