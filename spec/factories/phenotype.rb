FactoryGirl.define do
  factory(:phenotype) do |p|
    sequence(:name) { |n| "#{n}" }
    sequence(:tag) { |n| "Phenotype tag #{n}" }
    p.description "A bad phenotype.. :("
  end
end
