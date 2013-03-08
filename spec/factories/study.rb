FactoryGirl.define do
  factory(:study) do |s|
    sequence(:name) { |n| "Study #{n}"}
    sequence(:tag) { |n| "Study Tag #{n}" }
    s.collaborator "John Doe"
    s.collaborating_institution "UW"
    s.lead "Jane Murphey"
    s.description "A great study!"
    s.contact "jane_murphey@systemsbiology.org"
  end
end
