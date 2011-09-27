require 'spec_helper'

describe "relationships/index.html.erb" do
  before(:each) do
    assign(:relationships, [
      stub_model(Relationship),
      stub_model(Relationship)
    ])
  end

  it "renders a list of relationships" do
    render
  end
end
