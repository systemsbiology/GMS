require 'spec_helper'

describe "assembly_files/show" do
  before(:each) do
    @assembly_file = assign(:assembly_file, stub_model(AssemblyFile))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
