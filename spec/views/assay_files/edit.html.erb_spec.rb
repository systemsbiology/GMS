require 'spec_helper'

describe "assay_files/edit.html.erb" do
  before(:each) do
    @assay_file = assign(:assay_file, stub_model(AssayFile))
  end

  it "renders the edit assay_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assay_files_path(@assay_file), :method => "post" do
    end
  end
end
