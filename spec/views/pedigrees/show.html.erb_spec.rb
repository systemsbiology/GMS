require 'spec_helper'

describe "pedigrees/show.html.erb" do
  before(:each) do
    @pedigree = assign(:pedigree, stub_model(Pedigree))
  end

  it "renders attributes in <p>" do
    render
  end
end
