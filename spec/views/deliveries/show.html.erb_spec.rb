require 'spec_helper'

describe "deliveries/show" do
  before(:each) do
    @delivery = assign(:delivery, stub_model(Delivery,
      :sales_order => "Sales Order",
      :spreadsheet_name => "Spreadsheet Name",
      :date_uploaded => "Date Uploaded"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Sales Order/)
    rendered.should match(/Spreadsheet Name/)
    rendered.should match(/Date Uploaded/)
  end
end
