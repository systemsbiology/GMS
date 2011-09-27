require 'spec_helper'

describe "reports/new.html.erb" do
  before(:each) do
    assign(:report, stub_model(Report,
      :name => "MyString",
      :description => "MyString",
      :type => "MyString"
    ).as_new_record)
  end

  it "renders new report form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => reports_path, :method => "post" do
      assert_select "input#report_name", :name => "report[name]"
      assert_select "input#report_description", :name => "report[description]"
      assert_select "input#report_type", :name => "report[type]"
    end
  end
end
