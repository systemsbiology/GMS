FactoryGirl.define do
  sequence :assay_name do |n|
    "test assay #{n}"
  end

  factory :assay do |a|
    a.name :assay_name
    a.assay_type "1"
    a.technology "CGI Standard"
    a.vendor "Complete Genomics"
  end
end
