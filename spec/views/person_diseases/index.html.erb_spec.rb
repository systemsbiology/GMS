require 'spec_helper'

describe "diagnoses/index.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree, :name => "Test1")
    person = stub_model(Person, :pedigree => pedigree, :isb_person_id => "isb_ind_1", :collaborator_id => "474-A01")
    condition = stub_model(Condition, :name => "Pains")
    assign(:diagnoses, [
      stub_model(Diagnosis,
        :id => 1,
        :condition_id => 1,
        :condition_information => "Condition Information",
        :output_order => 1,
	:person => person,
	:condition => condition
      ),
      stub_model(Diagnosis,
        :id => 1,
        :condition_id => 1,
        :condition_information => "Condition Information",
        :output_order => 1,
	:person => person,
	:condition => condition
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
    assert_select "tr>td", :text => "Condition Information".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
