require 'spec_helper'

describe "sample_types/new.html.erb" do
  before(:each) do
    assign(:sample_type, stub_model(SampleType).as_new_record)
  end

  it "renders new sample_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sample_types_path, :method => "post" do
    end
  end
end
