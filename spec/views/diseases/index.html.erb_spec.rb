require 'spec_helper'

describe "diseases/index.html.erb" do
  before(:each) do
    assign(:diseases, [
      stub_model(Disease),
      stub_model(Disease)
    ])
  end

  it "renders a list of diseases" do
    render
  end
end
