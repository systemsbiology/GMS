require 'spec_helper'

describe "conditions/index.html.erb" do
  before(:each) do
    assign(:conditions, [
      stub_model(Condition),
      stub_model(Condition)
    ])
  end

  it "renders a list of conditions" do
    render
  end
end
