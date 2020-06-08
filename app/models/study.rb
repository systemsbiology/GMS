class Study < ActiveRecord::Base
  has_many :pedigrees, :dependent => :destroy
  auto_strip_attributes :name, :tag, :collaborator, :collaborating_institution, :lead, :description, :contact
  validates_presence_of :name, :tag, :collaborator, :collaborating_institution
  validates_uniqueness_of :name, :tag

  after_save :check_study_tag
  after_update :check_study_tag
  after_create :check_study_tag


  def check_study_tag
    if !self.tag.nil? and self.tag.match(/ /) then
      tag = self.tag.gsub!(/ /,"_")
      self.tag = tag
      self.save
    end
  end

  def genomic_count
    total_count = 0
    self.pedigrees.each do |ped|
        ped_count = ped.genomic_count
        total_count = total_count + ped_count
    end
    return total_count
  end

  def count_trios
    Rails.cache.fetch("numTrios/#{id}", :expires_in => 7.days) do
      numTrios = 0
      self.pedigrees.each do |ped|
        numTrios += ped.trios[0][2].count unless ped.trios.empty?
      end
      numTrios
    end
    end

  def count_individuals
	Rails.cache.fetch("numPeople/#{id}",:expires_in => 7.days) do
		numPeople = 0
		self.pedigrees.each do |ped|
			numPeople += ped.people.count
		end
		numPeople
	end
  end

  def count_sequenced
	Rails.cache.fetch("numSequenced/#{id}",:expires_in => 7.days) do
		numPeople =0
		self.pedigrees.each do |ped|
			numPeople += ped.count_sequenced
		end
		numPeople
	end
  end

end
