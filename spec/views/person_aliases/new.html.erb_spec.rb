require 'spec_helper'

describe "person_aliases/new.html.erb" do
  before(:each) do
    assign(:person_alias, stub_model(PersonAlias,
      :id => 1,
      :name => "MyString",
      :value => "MyString",
      :person_id => 1
    ).as_new_record)
  end

  it "renders new person_alias form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => person_aliases_path, :method => "post" do
      assert_select "input#person_alias_name", :name => "person_alias[name]"
      assert_select "input#person_alias_value", :name => "person_alias[value]"
      assert_select "input#person_alias_person_id", :name => "person_alias[person_id]"
    end
  end
end
