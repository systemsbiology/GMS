require 'spec_helper'

describe "assay_files/show.html.erb" do
  before(:each) do
    @assay_file = assign(:assay_file, stub_model(AssayFile))
  end

  it "renders attributes in <p>" do
    render
  end
end
