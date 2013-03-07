require 'spec_helper'

describe "assembly_files/edit" do
  before(:each) do
    @assembly_file = assign(:assembly_file, stub_model(AssemblyFile))
  end

  it "renders the edit assembly_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assembly_files_path(@assembly_file), :method => "post" do
    end
  end
end
