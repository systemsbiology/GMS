require 'spec_helper'

describe "relationships/show.html.erb" do
  before(:each) do
    @relationship = assign(:relationship, stub_model(Relationship))
  end

  it "renders attributes in <p>" do
    render
  end
end
