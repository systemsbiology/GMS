FactoryGirl.define do
  factory(:person) do |p|
    sequence(:collaborator_id) { |n| "Collaborator #{n}"}
    p.gender "female"
  end
end
