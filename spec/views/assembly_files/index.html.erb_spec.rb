require 'spec_helper'

describe "assembly_files/index" do
  before(:each) do
    assign(:assembly_files, [
      stub_model(AssemblyFile),
      stub_model(AssemblyFile)
    ])
  end

  it "renders a list of assembly_files" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
