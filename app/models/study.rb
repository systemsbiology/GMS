class Study < ActiveRecord::Base
  has_many :pedigrees, :dependent => :destroy
  auto_strip_attributes :name, :tag, :collaborator, :collaborating_institution, :lead, :description, :contact
  validates_presence_of :name, :tag, :collaborator, :collaborating_institution
  validates_uniqueness_of :name, :tag

  after_save :check_study_tag

  def check_study_tag
    if !self.tag.nil? and self.tag.match(/ /) then
      tag = self.tag.gsub!(/ /,"_")
      self.update_attributes(:tag => tag)
    end
  end
end
