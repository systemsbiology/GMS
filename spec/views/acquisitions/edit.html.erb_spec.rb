require 'spec_helper'

describe "acquisitions/edit.html.erb" do
  before(:each) do
    @acquisition = assign(:acquisition, stub_model(Acquisition))
  end

  it "renders the edit acquisition form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => acquisitions_path(@acquisition), :method => "post" do
    end
  end
end
