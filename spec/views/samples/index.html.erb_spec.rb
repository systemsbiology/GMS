require 'spec_helper'

describe "samples/index.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree, :name => "test1")
    person = stub_model(Person, :pedigree => pedigree, :isb_person_id => "isb_ind_1", :collaborator_id => "474-A01")
    assign(:samples, [
      stub_model(Sample, :person => person),
      stub_model(Sample, :person => person)
    ])
  end

  it "renders a list of samples" do
    render
  end
end
