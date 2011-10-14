require 'spec_helper'

describe "diagnoses/show.html.erb" do
  before(:each) do
    @diagnosis = assign(:diagnosis, stub_model(Diagnosis,
      :id => 1,
      :person_id => 1,
      :disease_id => 1,
      :disease_information => "Disease Information",
      :output_order => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Disease Information/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
