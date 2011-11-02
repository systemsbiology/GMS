require 'spec_helper'

describe "assembly_files/show.html.erb" do
  before(:each) do
    @assembly_file = assign(:assembly_file, stub_model(AssemblyFile))
  end

  it "renders attributes in <p>" do
    render
  end
end
