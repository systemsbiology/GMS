require 'spec_helper'

describe "file_types/index.html.erb" do
  before(:each) do
    assign(:file_types, [
      stub_model(FileType,
        :id => 1,
        :type_name => "Type Name"
      ),
      stub_model(FileType,
        :id => 1,
        :type_name => "Type Name"
      )
    ])
  end

  it "renders a list of file_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type Name".to_s, :count => 2
  end
end
