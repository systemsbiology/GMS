require "spec_helper"

describe AssemblyFilesController do
  describe "routing" do

    it "routes to #index" do
      get("/assembly_files").should route_to("assembly_files#index")
    end

    it "routes to #new" do
      get("/assembly_files/new").should route_to("assembly_files#new")
    end

    it "routes to #show" do
      get("/assembly_files/1").should route_to("assembly_files#show", :id => "1")
    end

    it "routes to #edit" do
      get("/assembly_files/1/edit").should route_to("assembly_files#edit", :id => "1")
    end

    it "routes to #create" do
      post("/assembly_files").should route_to("assembly_files#create")
    end

    it "routes to #update" do
      put("/assembly_files/1").should route_to("assembly_files#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/assembly_files/1").should route_to("assembly_files#destroy", :id => "1")
    end

  end
end
