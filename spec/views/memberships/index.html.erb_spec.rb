require 'spec_helper'

describe "memberships/index.html.erb" do
  before(:each) do
    assign(:memberships, [
      stub_model(Membership),
      stub_model(Membership)
    ])

    memberships.each do |membership|
      membership.pedigree = assign(:pedigree, stub_model(Pedigree))
      membership.person = assign(:person, stub_model(Person))
    end
  end

  it "renders a list of memberships" do
    render
  end
end
