FactoryGirl.define do
  factory(:temp_object) do |to|
    sequence(:trans_id) { |n| "#{n}" }
  end
end
