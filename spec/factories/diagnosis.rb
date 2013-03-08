FactoryGirl.define do
  factory :diagnosis do |d|
    sequence(:person_id) {|n| "#{n}" }
    sequence(:disease_id) {|n| "#{n}" }
  end
end
