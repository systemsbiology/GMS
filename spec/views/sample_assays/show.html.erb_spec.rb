require 'spec_helper'

describe "sample_assays/show.html.erb" do
  before(:each) do
    @sample_assay = assign(:sample_assay, stub_model(SampleAssay))
  end

  it "renders attributes in <p>" do
    render
  end
end
