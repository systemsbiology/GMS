require 'spec_helper'

describe "genome_references/edit.html.erb" do
  before(:each) do
    @genome_reference = assign(:genome_reference, stub_model(GenomeReference))
  end

  it "renders the edit genome_reference form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => genome_references_path(@genome_reference), :method => "post" do
    end
  end
end
