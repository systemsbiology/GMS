require "spec_helper"

describe AssemblyController do
  describe "routing" do

    it "routes to #index" do
      get("/assembly").should route_to("assembly#index")
    end

    it "routes to #new" do
      get("/assembly/new").should route_to("assembly#new")
    end

    it "routes to #show" do
      get("/assembly/1").should route_to("assembly#show", :id => "1")
    end

    it "routes to #edit" do
      get("/assembly/1/edit").should route_to("assembly#edit", :id => "1")
    end

    it "routes to #create" do
      post("/assembly").should route_to("assembly#create")
    end

    it "routes to #update" do
      put("/assembly/1").should route_to("assembly#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/assembly/1").should route_to("assembly#destroy", :id => "1")
    end

  end
end
