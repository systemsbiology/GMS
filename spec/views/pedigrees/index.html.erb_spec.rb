require 'spec_helper'

describe "pedigrees/index.html.erb" do
  before(:each) do
    assign(:pedigrees, [
      stub_model(Pedigree),
      stub_model(Pedigree)
    ])
  end

  it "renders a list of pedigrees" do
    render
  end
end
