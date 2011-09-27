require 'spec_helper'

describe "diseases/edit.html.erb" do
  before(:each) do
    @disease = assign(:disease, stub_model(Disease))
  end

  it "renders the edit disease form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => diseases_path(@disease), :method => "post" do
    end
  end
end
