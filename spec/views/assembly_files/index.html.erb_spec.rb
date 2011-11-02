require 'spec_helper'

describe "assembly_files/index.html.erb" do
  before(:each) do
    assign(:assembly_files, [
      stub_model(AssemblyFile),
      stub_model(AssemblyFile)
    ])
  end

  it "renders a list of assembly_files" do
    render
  end
end
