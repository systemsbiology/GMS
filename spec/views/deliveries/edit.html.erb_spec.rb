require 'spec_helper'

describe "deliveries/edit" do
  before(:each) do
    @delivery = assign(:delivery, stub_model(Delivery,
      :sales_order => "MyString",
      :spreadsheet_name => "MyString",
      :date_uploaded => "MyString"
    ))
  end

  it "renders the edit delivery form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", delivery_path(@delivery), "post" do
      assert_select "input#delivery_sales_order[name=?]", "delivery[sales_order]"
      assert_select "input#delivery_spreadsheet_name[name=?]", "delivery[spreadsheet_name]"
      assert_select "input#delivery_date_uploaded[name=?]", "delivery[date_uploaded]"
    end
  end
end
