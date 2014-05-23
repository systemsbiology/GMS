require 'spec_helper'

describe "conditions/show.html.erb" do
  before(:each) do
    @condition = assign(:condition, stub_model(Condition))
  end

  it "renders attributes in <p>" do
    render
  end
end
