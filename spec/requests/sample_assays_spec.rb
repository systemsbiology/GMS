require 'spec_helper'

describe "SampleAssays" do
  describe "GET /sample_assays" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get sample_assays_path
      response.status.should be(200)
    end
  end
end
