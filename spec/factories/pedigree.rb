FactoryGirl.define do
  factory(:pedigree) do
    sequence(:name) { |n| "Pedigree #{n}" }
    sequence(:tag) { |n| "Pedigree Tag #{n}"}
    description "A great pedigree!"
    study
  end
end
