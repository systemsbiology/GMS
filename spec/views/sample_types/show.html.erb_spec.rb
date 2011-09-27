require 'spec_helper'

describe "sample_types/show.html.erb" do
  before(:each) do
    @sample_type = assign(:sample_type, stub_model(SampleType))
  end

  it "renders attributes in <p>" do
    render
  end
end
