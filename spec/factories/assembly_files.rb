# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :assembly_files_name do |n|
    "test assembly_file #{n}"
  end

  factory :assembly_file do |af|
    af.name :assembly_files_name
    af.genome_reference_id 1
    af.location "/proj/famgen/studies/"
    af.software "cgatools"
    af.software_version "1.1.1.10"
    af.file_date "2011-12-20"
    assembly
    var_annotation
  end
end
