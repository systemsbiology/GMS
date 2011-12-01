require 'spec_helper'

describe "assemblies/index.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree, :name => "test1")
    person = stub_model(Person, :pedigree => pedigree, :isb_person_id => "isb_ind_1", :collaborator_id => "474-A01")
    sample = stub_model(Sample, :person => person)
    assay = stub_model(Assay, :sample => sample)
    genome_ref = stub_model(GenomeReference)
    assign(:assemblies, [
      stub_model(Assembly, :assay => assay, :genome_reference => genome_ref),
      stub_model(Assembly, :assay => assay, :genome_reference => genome_ref)
    ])
  end

  it "renders a list of assemblies" do
    render
  end
end
