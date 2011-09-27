require 'spec_helper'

describe "assays/index.html.erb" do
  before(:each) do
    assign(:assays, [
      stub_model(Assay),
      stub_model(Assay)
    ])
  end

  it "renders a list of assays" do
    render
  end
end
