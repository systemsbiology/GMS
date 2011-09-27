require 'spec_helper'

describe "pedigrees/edit.html.erb" do
  before(:each) do
    @pedigree = assign(:pedigree, stub_model(Pedigree))
  end

  it "renders the edit pedigree form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => pedigrees_path(@pedigree), :method => "post" do
    end
  end
end
