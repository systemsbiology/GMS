require 'spec_helper'

describe "sample_types/index.html.erb" do
  before(:each) do
    assign(:sample_types, [
      stub_model(SampleType),
      stub_model(SampleType)
    ])
  end

  it "renders a list of sample_types" do
    render
  end
end
