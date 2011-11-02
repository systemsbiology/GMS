require 'spec_helper'

describe "file_types/show.html.erb" do
  before(:each) do
    @file_type = assign(:file_type, stub_model(FileType,
      :id => 1,
      :type_name => "Type Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type Name/)
  end
end
