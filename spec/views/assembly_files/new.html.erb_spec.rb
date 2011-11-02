require 'spec_helper'

describe "assembly_files/new.html.erb" do
  before(:each) do
    assign(:assembly_file, stub_model(AssemblyFile).as_new_record)
  end

  it "renders new assembly_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assembly_files_path, :method => "post" do
    end
  end
end
