FactoryGirl.define do
  factory :file_type do |ft|
    sequence(:type_name) { |n| "filetype #{n}" }
  end
end
