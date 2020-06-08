# require 'spec_helper'

# describe User do

#   before(:each) do
#     @attr = {
#       :login => "juser",
#       :email => "Joe@example.com",
#       :first_name => "Joe",
#       :last_name => "User"
#     }
#   end

#   it "should create a new instance given a valid attribute" do
#     User.create!(@attr)
#   end

#   it "should require a login" do
#     no_login_user = User.new(@attr.merge(:login => ""))
#     no_login_user.should_not be_valid
#   end

#   it "should require a first_name" do
#     no_login_user = User.new(@attr.merge(:first_name => ""))
#     no_login_user.should_not be_valid
#   end

#   it "should require a last_name" do
#     no_login_user = User.new(@attr.merge(:last_name => ""))
#     no_login_user.should_not be_valid
#   end

#   it "should require an email" do
#     no_login_user = User.new(@attr.merge(:email => ""))
#     no_login_user.should_not be_valid
#   end

#   it "should reject duplicate logins" do
#     User.create!(@attr)
#     user_with_duplicate_login = User.new(@attr)
#     user_with_duplicate_login.should_not be_valid
#   end

#   it "should reject logins identical up to case" do
#     upcased_login = @attr[:login].upcase
#     User.create!(@attr.merge(:login => upcased_login))
#     user_with_duplicate_login = User.new(@attr)
#     user_with_duplicate_login.should_not be_valid
#   end


#   it "should accept valid emails" do
#     addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
#     addresses.each do |address|
#       valid_email_user = User.new(@attr.merge(:email => address))
#       valid_email_user.should be_valid
#     end
#   end

#   it "should reject invalid email addresses" do
#     addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
#     addresses.each do |address|
#       invalid_email_user = User.new(@attr.merge(:email => address))
#       invalid_email_user.should_not be_valid
#     end
#   end

#   it "should reject emails identical up to case" do
#     upcased_email = @attr[:email].upcase
#     User.create!(@attr.merge(:email => upcased_email))
#     user_with_duplicate_email = User.new(@attr)
#     user_with_duplicate_email.should_not be_valid
#   end

# end
