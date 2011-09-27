require 'spec_helper'

describe "sample_types/edit.html.erb" do
  before(:each) do
    @sample_type = assign(:sample_type, stub_model(SampleType))
  end

  it "renders the edit sample_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sample_types_path(@sample_type), :method => "post" do
    end
  end
end
