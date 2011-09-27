require 'spec_helper'

describe "acquisitions/index.html.erb" do
  before(:each) do
    assign(:acquisitions, [
      stub_model(Acquisition),
      stub_model(Acquisition)
    ])
  end

  it "renders a list of acquisitions" do
    render
  end
end
