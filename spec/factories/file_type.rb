FactoryGirl.define do
  factory :file_type do |ft|
    sequence(:type_name) { |n| "filetype #{n}" }
  end

  factory :var_annotation do |va|
    va.type_name "VAR-ANNOTATION"
  end
end
