FactoryGirl.define do
  factory :disease do |d|
    sequence(:name) { |n| "Disease #{n}" }
  end
end
