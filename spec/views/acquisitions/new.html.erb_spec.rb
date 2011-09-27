require 'spec_helper'

describe "acquisitions/new.html.erb" do
  before(:each) do
    assign(:acquisition, stub_model(Acquisition).as_new_record)
  end

  it "renders new acquisition form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => acquisitions_path, :method => "post" do
    end
  end
end
