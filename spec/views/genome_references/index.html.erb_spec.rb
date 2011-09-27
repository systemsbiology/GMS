require 'spec_helper'

describe "genome_references/index.html.erb" do
  before(:each) do
    assign(:genome_references, [
      stub_model(GenomeReference),
      stub_model(GenomeReference)
    ])
  end

  it "renders a list of genome_references" do
    render
  end
end
