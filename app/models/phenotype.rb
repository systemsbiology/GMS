class Phenotype < ActiveRecord::Base
  has_many :traits, :dependent => :destroy
  has_many :people, :through => :traits
  belongs_to :condition
  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag
  validates_uniqueness_of :name, :tag

  def filter_by_trait_value(trait_value)
		self.traits.where(:trait_information => trait_value)
  end

  def people_by_trait_value(trait_value)
		people = Array.new
		self.traits.where(:trait_information => trait_value).each do |trait|
			people.push(trait.person)
		end
		return people
  end

  def unique_trait_values
		unique_values = Hash.new
		self.traits.each do |trait|
			unique_values[trait.trait_information] = 1
		end
		return unique_values.keys
  end

end
