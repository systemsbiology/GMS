FactoryGirl.define do
  factory :membership do |m|
    sequence(:pedigree_id) { |n| "#{n}" }
    sequence(:person_id) { |n| "#{n}" }
  end
end
