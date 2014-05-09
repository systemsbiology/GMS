require 'spec_helper'

describe "deliveries/new" do
  before(:each) do
    assign(:delivery, stub_model(Delivery,
      :sales_order => "MyString",
      :spreadsheet_name => "MyString",
      :date_uploaded => "MyString"
    ).as_new_record)
  end

  it "renders new delivery form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", deliveries_path, "post" do
      assert_select "input#delivery_sales_order[name=?]", "delivery[sales_order]"
      assert_select "input#delivery_spreadsheet_name[name=?]", "delivery[spreadsheet_name]"
      assert_select "input#delivery_date_uploaded[name=?]", "delivery[date_uploaded]"
    end
  end
end
