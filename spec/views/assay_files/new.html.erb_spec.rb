require 'spec_helper'

describe "assay_files/new.html.erb" do
  before(:each) do
    assign(:assay_file, stub_model(AssayFile).as_new_record)
  end

  it "renders new assay_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assay_files_path, :method => "post" do
    end
  end
end
