require "spec_helper"

describe SampleAssaysController do
  describe "routing" do

    it "routes to #index" do
      get("/sample_assays").should route_to("sample_assays#index")
    end

    it "routes to #new" do
      get("/sample_assays/new").should route_to("sample_assays#new")
    end

    it "routes to #show" do
      get("/sample_assays/1").should route_to("sample_assays#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sample_assays/1/edit").should route_to("sample_assays#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sample_assays").should route_to("sample_assays#create")
    end

    it "routes to #update" do
      put("/sample_assays/1").should route_to("sample_assays#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sample_assays/1").should route_to("sample_assays#destroy", :id => "1")
    end

  end
end
