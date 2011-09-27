require "spec_helper"

describe AssayFilesController do
  describe "routing" do

    it "routes to #index" do
      get("/assay_files").should route_to("assay_files#index")
    end

    it "routes to #new" do
      get("/assay_files/new").should route_to("assay_files#new")
    end

    it "routes to #show" do
      get("/assay_files/1").should route_to("assay_files#show", :id => "1")
    end

    it "routes to #edit" do
      get("/assay_files/1/edit").should route_to("assay_files#edit", :id => "1")
    end

    it "routes to #create" do
      post("/assay_files").should route_to("assay_files#create")
    end

    it "routes to #update" do
      put("/assay_files/1").should route_to("assay_files#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/assay_files/1").should route_to("assay_files#destroy", :id => "1")
    end

  end
end
