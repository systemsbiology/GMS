require 'spec_helper'

describe "person_aliases/index.html.erb" do
  before(:each) do
    assign(:person_aliases, [
      stub_model(PersonAlias,
        :id => 1,
        :name => "Name",
        :value => "Value",
        :person_id => 1
      ),
      stub_model(PersonAlias,
        :id => 1,
        :name => "Name",
        :value => "Value",
        :person_id => 1
      )
    ])
  end

  it "renders a list of person_aliases" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Value".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 4
  end
end
