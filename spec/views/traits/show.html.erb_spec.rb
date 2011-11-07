require 'spec_helper'

describe "traits/show.html.erb" do
  before(:each) do
    @trait = assign(:trait, stub_model(Trait))
    @person = assign(:person, stub_model(Person))
    @phenotype = assign(:phenotype, stub_model(Phenotype))
    @pedigree = assign(:pedigree, stub_model(Pedigree))
    @person.pedigree = @pedigree
    @trait.person = @person
    @trait.phenotype = @phenotype
  end

  it "renders attributes in <p>" do
    render
  end
end
