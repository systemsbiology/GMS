require 'spec_helper'

describe "acquisitions/show.html.erb" do
  before(:each) do
    @acquisition = assign(:acquisition, stub_model(Acquisition))
  end

  it "renders attributes in <p>" do
    render
  end
end
