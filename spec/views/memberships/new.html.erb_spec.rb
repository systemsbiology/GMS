require 'spec_helper'

describe "memberships/new.html.erb" do
  before(:each) do
    assign(:membership, stub_model(Membership).as_new_record)
  end

  it "renders new membership form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => memberships_path, :method => "post" do
    end
  end
end
