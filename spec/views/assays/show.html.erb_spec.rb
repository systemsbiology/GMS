require 'spec_helper'

describe "assays/show.html.erb" do
  before(:each) do
    @assay = assign(:assay, stub_model(Assay))
  end

  it "renders attributes in <p>" do
    render
  end
end
