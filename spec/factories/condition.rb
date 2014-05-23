FactoryGirl.define do
  factory :condition do |d|
    sequence(:name) { |n| "Condition #{n}" }
  end
end
