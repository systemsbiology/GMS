require 'spec_helper'

describe "conditions/edit.html.erb" do
  before(:each) do
    @condition = assign(:condition, stub_model(Condition))
  end

  it "renders the edit condition form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => conditions_path(@condition), :method => "post" do
    end
  end
end
