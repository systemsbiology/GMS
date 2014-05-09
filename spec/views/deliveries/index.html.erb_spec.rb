require 'spec_helper'

describe "deliveries/index" do
  before(:each) do
    assign(:deliveries, [
      stub_model(Delivery,
        :sales_order => "Sales Order",
        :spreadsheet_name => "Spreadsheet Name",
        :date_uploaded => "Date Uploaded"
      ),
      stub_model(Delivery,
        :sales_order => "Sales Order",
        :spreadsheet_name => "Spreadsheet Name",
        :date_uploaded => "Date Uploaded"
      )
    ])
  end

  it "renders a list of deliveries" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Sales Order".to_s, :count => 2
    assert_select "tr>td", :text => "Spreadsheet Name".to_s, :count => 2
    assert_select "tr>td", :text => "Date Uploaded".to_s, :count => 2
  end
end
