require 'spec_helper'

describe "phenotypes/new.html.erb" do
  before(:each) do
    assign(:phenotype, stub_model(Phenotype).as_new_record)
  end

  it "renders new phenotype form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => phenotypes_path, :method => "post" do
    end
  end
end
