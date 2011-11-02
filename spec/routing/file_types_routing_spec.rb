require "spec_helper"

describe FileTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/file_types").should route_to("file_types#index")
    end

    it "routes to #new" do
      get("/file_types/new").should route_to("file_types#new")
    end

    it "routes to #show" do
      get("/file_types/1").should route_to("file_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/file_types/1/edit").should route_to("file_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/file_types").should route_to("file_types#create")
    end

    it "routes to #update" do
      put("/file_types/1").should route_to("file_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/file_types/1").should route_to("file_types#destroy", :id => "1")
    end

  end
end
