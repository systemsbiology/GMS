require 'spec_helper'

describe "assemblies/show.html.erb" do
  before(:each) do
    @assembly = assign(:assembly, stub_model(Assembly))
  end

  it "renders attributes in <p>" do
    render
  end
end
