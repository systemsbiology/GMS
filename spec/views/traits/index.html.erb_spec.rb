require 'spec_helper'

describe "traits/index.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree, :name => "test1")
    person = stub_model(Person, :pedigree => pedigree, :isb_person_id => "isb_ind_1", :collaborator_id => "474-A01")

    @traits = assign(:traits, [
      stub_model(Trait, :person => person),
      stub_model(Trait, :person => person)
    ])
  end

  it "renders a list of traits" do
    render
  end
end
