FactoryGirl.define do
  factory(:person_alias) do |pa|
    sequence(:person_id) { |n| "Person #{n}" }
    pa.value "Alias1"
    pa.alias_type "collaborator_id"
  end
end
