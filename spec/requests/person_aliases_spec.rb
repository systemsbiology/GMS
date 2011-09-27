require 'spec_helper'

describe "PersonAliases" do
  describe "GET /person_aliases" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get person_aliases_path
      response.status.should be(200)
    end
  end
end
