require 'spec_helper'

describe "assemblies/index.html.erb" do
  before(:each) do
    assign(:assemblies, [
      stub_model(Assembly),
      stub_model(Assembly)
    ])
  end

  it "renders a list of assemblies" do
    render
  end
end
