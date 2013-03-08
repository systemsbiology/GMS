FactoryGirl.define do 
  factory(:trait) do |t|
    sequence(:person_id) { |n| "#{n}"}
    sequence(:phenotype_id) { |n| "#{n}"}
  end
end
