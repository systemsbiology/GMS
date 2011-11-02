require 'spec_helper'

describe "file_types/new.html.erb" do
  before(:each) do
    assign(:file_type, stub_model(FileType,
      :id => 1,
      :type_name => "MyString"
    ).as_new_record)
  end

  it "renders new file_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => file_types_path, :method => "post" do
      assert_select "input#file_type_id", :name => "file_type[id]"
      assert_select "input#file_type_type_name", :name => "file_type[type_name]"
    end
  end
end
