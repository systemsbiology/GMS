FactoryGirl.define do
  factory :sample_assay do |sa|
    sequence(:sample_id) { |n| "#{n}" }
    sequence(:assay_id) { |n| "#{n}" }
  end
end
