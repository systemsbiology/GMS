require 'spec_helper'

describe "relationships/show.html.erb" do
  before(:each) do
    pedigree = stub_model(Pedigree)
    person = stub_model(Person, :pedigree => pedigree)
    @relationship = assign(:relationship, stub_model(Relationship, :person => person, :relation => person))
  end

  it "renders attributes in <p>" do
    render
  end
end
