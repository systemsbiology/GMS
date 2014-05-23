require 'spec_helper'

describe "diagnoses/edit.html.erb" do
  before(:each) do
    @diagnosis = assign(:diagnosis, stub_model(Diagnosis,
      :id => 1,
      :person_id => 1,
      :condition_id => 1,
      :condition_information => "MyString",
      :output_order => 1
    ))
  end

  it "renders the edit diagnosis form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => diagnoses_path(@diagnosis), :method => "post" do
      assert_select "input#diagnosis_id", :name => "diagnosis[id]"
      assert_select "input#diagnosis_person_id", :name => "diagnosis[person_id]"
      assert_select "input#diagnosis_condition_id", :name => "diagnosis[condition_id]"
      assert_select "input#diagnosis_condition_information", :name => "diagnosis[condition_information]"
      assert_select "input#diagnosis_output_order", :name => "diagnosis[output_order]"
    end
  end
end
