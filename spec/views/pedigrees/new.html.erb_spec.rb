require 'spec_helper'

describe "pedigrees/new.html.erb" do
  before(:each) do
    assign(:pedigree, stub_model(Pedigree).as_new_record)
  end

  it "renders new pedigree form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => pedigrees_path, :method => "post" do
    end
  end
end
