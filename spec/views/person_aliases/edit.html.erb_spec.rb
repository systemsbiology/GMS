require 'spec_helper'

describe "person_aliases/edit.html.erb" do
  before(:each) do
    @person_alias = assign(:person_alias, stub_model(PersonAlias,
      :id => 1,
      :name => "MyString",
      :value => "MyString",
      :person_id => 1
    ))
  end

  it "renders the edit person_alias form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => person_aliases_path(@person_alias), :method => "post" do
      #assert_select "input#person_alias_value", :name => "person_alias[value]"
      #assert_select "input#person_alias_person_id", :name => "person_alias[person_id]"
    end
  end
end
