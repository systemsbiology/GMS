require 'spec_helper'

describe "sample_assays/index.html.erb" do
  before(:each) do
    assign(:sample_assays, [
      stub_model(SampleAssay),
      stub_model(SampleAssay)
    ])
  end

  it "renders a list of sample_assays" do
    render
  end
end
