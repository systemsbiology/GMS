require 'spec_helper'

describe "memberships/index.html.erb" do
  before(:each) do
    assign(:memberships, [
      stub_model(Membership),
      stub_model(Membership)
    ])
  end

  it "renders a list of memberships" do
    render
  end
end
