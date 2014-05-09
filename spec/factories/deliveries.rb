# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delivery do
    sales_order "MyString"
    spreadsheet_name "MyString"
    date_uploaded "MyString"
  end
end
