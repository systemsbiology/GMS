require 'spec_helper'

describe "memberships/index.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree, :name => "test1")
    person = stub_model(Person, :pedigree => pedigree, :isb_person_id => "isb_ind_1", :collaborator_id => "474-A01")

    assign(:memberships, [
      stub_model(Membership, :person => person),
      stub_model(Membership, :person => person)
    ])

  end

  it "renders a list of memberships" do
    render
  end
end
