require 'pedigree_info'

class Pedigree < ActiveRecord::Base
  has_many :people, :through => :memberships
  has_many :memberships
  belongs_to :study

  auto_strip_attributes :name, :tag, :description
  validates_presence_of :name, :tag, :study_id
  validates_uniqueness_of :name, :tag

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

end
