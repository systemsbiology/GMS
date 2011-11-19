require 'spec_helper'

describe "samples/show.html.erb" do
  before(:each) do
    @sample = assign(:sample, stub_model(Sample))
    @sample.person = assign(:person, stub_model(Person))
    @sample.person.pedigree = assign(:pedigree, stub_model(Pedigree))
  end

  it "renders attributes in <p>" do
    render
  end
end
