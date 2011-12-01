require 'spec_helper'

describe "assembly_files/index.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree)
    person = stub_model(Person, :pedigree => pedigree)
    sample = stub_model(Sample, :person => person)
    assay = stub_model(Assay, :sample => sample)
    assembly = stub_model(Assembly, :assay => assay)
    genome_ref = stub_model(GenomeReference)
    assign(:assembly_files, [
      stub_model(AssemblyFile, :assembly => assembly, :genome_reference => genome_ref),
      stub_model(AssemblyFile, :assembly => assembly, :genome_reference => genome_ref)
    ])
  end

  it "renders a list of assembly_files" do
    render
  end
end
