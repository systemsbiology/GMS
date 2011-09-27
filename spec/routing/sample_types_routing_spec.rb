require "spec_helper"

describe SampleTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/sample_types").should route_to("sample_types#index")
    end

    it "routes to #new" do
      get("/sample_types/new").should route_to("sample_types#new")
    end

    it "routes to #show" do
      get("/sample_types/1").should route_to("sample_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sample_types/1/edit").should route_to("sample_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sample_types").should route_to("sample_types#create")
    end

    it "routes to #update" do
      put("/sample_types/1").should route_to("sample_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sample_types/1").should route_to("sample_types#destroy", :id => "1")
    end

  end
end
