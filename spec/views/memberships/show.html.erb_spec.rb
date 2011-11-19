require 'spec_helper'

describe "memberships/show.html.erb" do
  before(:each) do
    @membership = assign(:membership, stub_model(Membership))
    @membership.pedigree = assign(:pedigree, stub_model(Pedigree))
    @membership.person = assign(:person, stub_model(Person))
  end

  it "renders attributes in <p>" do
    render
  end
end
