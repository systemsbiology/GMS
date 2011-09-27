require 'spec_helper'

describe "phenotypes/show.html.erb" do
  before(:each) do
    @phenotype = assign(:phenotype, stub_model(Phenotype))
  end

  it "renders attributes in <p>" do
    render
  end
end
