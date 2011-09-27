require 'spec_helper'

describe "studies/new.html.erb" do
  before(:each) do
    assign(:study, stub_model(Study).as_new_record)
  end

  it "renders new study form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => studies_path, :method => "post" do
    end
  end
end
