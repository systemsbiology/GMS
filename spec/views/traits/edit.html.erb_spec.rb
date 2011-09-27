require 'spec_helper'

describe "traits/edit.html.erb" do
  before(:each) do
    @trait = assign(:trait, stub_model(Trait))
  end

  it "renders the edit trait form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => traits_path(@trait), :method => "post" do
    end
  end
end
