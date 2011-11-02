require 'spec_helper'

describe "assemblies/new.html.erb" do
  before(:each) do
    assign(:assembly, stub_model(Assembly).as_new_record)
  end

  it "renders new assembly form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assemblies_path, :method => "post" do
    end
  end
end
