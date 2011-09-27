require 'spec_helper'

describe "genome_references/new.html.erb" do
  before(:each) do
    assign(:genome_reference, stub_model(GenomeReference).as_new_record)
  end

  it "renders new genome_reference form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => genome_references_path, :method => "post" do
    end
  end
end
