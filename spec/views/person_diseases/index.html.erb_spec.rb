require 'spec_helper'

describe "diagnoses/index.html.erb" do
  before(:each) do
    assign(:diagnoses, [
      stub_model(Diagnosis,
        :id => 1,
        :person_id => 1,
        :disease_id => 1,
        :disease_information => "Disease Information",
        :output_order => 1
      ),
      stub_model(Diagnosis,
        :id => 1,
        :person_id => 1,
        :disease_id => 1,
        :disease_information => "Disease Information",
        :output_order => 1
      )
    ])
  end

  it "renders a list of diagnoses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Disease Information".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
