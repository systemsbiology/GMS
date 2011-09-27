require 'spec_helper'

describe "memberships/show.html.erb" do
  before(:each) do
    @membership = assign(:membership, stub_model(Membership))
  end

  it "renders attributes in <p>" do
    render
  end
end
