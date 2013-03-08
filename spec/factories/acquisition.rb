FactoryGirl.define do
  factory :acquisition do |a|
    sequence(:person_id) { |n| "#{n}" }
    sequence(:sample_id) { |n| "#{n}" }
  end
end
