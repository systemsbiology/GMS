require 'spec_helper'

describe "studies/show.html.erb" do
  before(:each) do
    @study = assign(:study, stub_model(Study))
  end

  it "renders attributes in <p>" do
    render
  end
end
