require 'spec_helper'

describe "studies/index.html.erb" do
  before(:each) do
    assign(:studies, [
      stub_model(Study),
      stub_model(Study)
    ])
  end

  it "renders a list of studies" do
    render
  end
end
