FactoryGirl.define do
  factory :genome_reference do |gr|
    sequence(:name) { |n| "Reference #{n}"}
  end
end
