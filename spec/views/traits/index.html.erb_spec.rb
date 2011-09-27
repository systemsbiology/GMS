require 'spec_helper'

describe "traits/index.html.erb" do
  before(:each) do
    assign(:traits, [
      stub_model(Trait),
      stub_model(Trait)
    ])
  end

  it "renders a list of traits" do
    render
  end
end
