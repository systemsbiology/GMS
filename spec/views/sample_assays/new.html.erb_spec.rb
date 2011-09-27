require 'spec_helper'

describe "sample_assays/new.html.erb" do
  before(:each) do
    assign(:sample_assay, stub_model(SampleAssay).as_new_record)
  end

  it "renders new sample_assay form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sample_assays_path, :method => "post" do
    end
  end
end
