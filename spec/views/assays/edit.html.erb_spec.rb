require 'spec_helper'

describe "assays/edit.html.erb" do
  before(:each) do
    @assay = assign(:assay, stub_model(Assay))
  end

  it "renders the edit assay form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => assays_path(@assay), :method => "post" do
    end
  end
end
