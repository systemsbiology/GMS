require 'spec_helper'

describe "diseases/show.html.erb" do
  before(:each) do
    @disease = assign(:disease, stub_model(Disease))
  end

  it "renders attributes in <p>" do
    render
  end
end
