require 'spec_helper'

describe "assays/new.html.erb" do
  before(:each) do
    assign(:assay, stub_model(Assay).as_new_record)
  end

  it "renders new assay form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assays_path, :method => "post" do
    end
  end
end
