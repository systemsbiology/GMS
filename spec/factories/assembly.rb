FactoryGirl.define do
  sequence :assembly_name do |n|
    "test assembly #{n}"
  end

  factory :assembly do |a|
    a.name :assembly_name
    a.genome_reference_id "1"
    a.location "/proj/famgen/studies/"
    a.software "cgatools"
    a.software_version "1.1.1.10"
    a.file_date "2012-12-21"
    assay
  end
end
