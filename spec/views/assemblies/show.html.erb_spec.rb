require 'spec_helper'

describe "assemblies/show.html.erb" do
  before(:each) do
    @assembly = assign(:assembly, stub_model(Assembly))
    @assembly.genome_reference = assign(:genome_reference, stub_model(GenomeReference))
    @assembly.assay = assign(:assay, stub_model(Assay))
  end

  it "renders attributes in <p>" do
    render
  end
end
