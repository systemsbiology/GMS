FactoryGirl.define do
  factory(:sample) do |s|
    sequence(:customer_sample_id) {|n| "sample #{n}" }
    sequence(:sample_vendor_id) {|n| "VENDOR ID #{n}" }
    s.status "Submitted"
    sample_type
  end
end
