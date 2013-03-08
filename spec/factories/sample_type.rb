FactoryGirl.define do
  factory(:sample_type) do |st|
    sequence(:name) { |n| "#{n}" }
    st.description "A Blood sample"
    st.tissue "blood"
  end
end
