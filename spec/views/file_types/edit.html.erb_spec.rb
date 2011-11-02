require 'spec_helper'

describe "file_types/edit.html.erb" do
  before(:each) do
    @file_type = assign(:file_type, stub_model(FileType,
      :id => 1,
      :type_name => "MyString"
    ))
  end

  it "renders the edit file_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => file_types_path(@file_type), :method => "post" do
      assert_select "input#file_type_id", :name => "file_type[id]"
      assert_select "input#file_type_type_name", :name => "file_type[type_name]"
    end
  end
end
