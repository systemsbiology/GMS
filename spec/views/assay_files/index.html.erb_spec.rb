require 'spec_helper'

describe "assay_files/index.html.erb" do
  before(:each) do
    assign(:assay_files, [
      stub_model(AssayFile),
      stub_model(AssayFile)
    ])
  end

  it "renders a list of assay_files" do
    render
  end
end
