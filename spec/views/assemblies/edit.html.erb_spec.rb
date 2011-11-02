require 'spec_helper'

describe "assemblies/edit.html.erb" do
  before(:each) do
    @assembly = assign(:assembly, stub_model(Assembly))
  end

  it "renders the edit assembly form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assemblies_path(@assembly), :method => "post" do
    end
  end
end
