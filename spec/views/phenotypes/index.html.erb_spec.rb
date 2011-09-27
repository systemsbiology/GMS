require 'spec_helper'

describe "phenotypes/index.html.erb" do
  before(:each) do
    assign(:phenotypes, [
      stub_model(Phenotype),
      stub_model(Phenotype)
    ])
  end

  it "renders a list of phenotypes" do
    render
  end
end
