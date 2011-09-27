require 'spec_helper'

describe "sample_assays/edit.html.erb" do
  before(:each) do
    @sample_assay = assign(:sample_assay, stub_model(SampleAssay))
  end

  it "renders the edit sample_assay form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sample_assays_path(@sample_assay), :method => "post" do
    end
  end
end
