require 'spec_helper'

describe "person_aliases/show.html.erb" do
  before(:each) do
    @person_alias = assign(:person_alias, stub_model(PersonAlias,
      :id => 1,
      :name => "Name",
      :value => "Value",
      :person_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Value/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
