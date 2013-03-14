FactoryGirl.define do
  factory :assay do |a|
    sequence(:name) { |n| "test assay #{n}" }
    a.assay_type "1"
    a.technology "CGI Standard"
    a.vendor "Complete Genomics"
  end
end
