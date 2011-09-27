require 'spec_helper'

describe "phenotypes/edit.html.erb" do
  before(:each) do
    @phenotype = assign(:phenotype, stub_model(Phenotype))
  end

  it "renders the edit phenotype form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => phenotypes_path(@phenotype), :method => "post" do
    end
  end
end
