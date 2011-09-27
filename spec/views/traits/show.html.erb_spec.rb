require 'spec_helper'

describe "traits/show.html.erb" do
  before(:each) do
    @trait = assign(:trait, stub_model(Trait))
  end

  it "renders attributes in <p>" do
    render
  end
end
