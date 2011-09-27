require 'spec_helper'

describe "traits/new.html.erb" do
  before(:each) do
    assign(:trait, stub_model(Trait).as_new_record)
  end

  it "renders new trait form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => traits_path, :method => "post" do
    end
  end
end
