require 'spec_helper'

describe "genome_references/show.html.erb" do
  before(:each) do
    @genome_reference = assign(:genome_reference, stub_model(GenomeReference))
  end

  it "renders attributes in <p>" do
    render
  end
end
