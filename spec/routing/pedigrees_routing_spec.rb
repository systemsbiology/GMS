require "spec_helper"

describe PedigreesController do
  describe "routing" do

    it "routes to #index" do
      get("/pedigrees").should route_to("pedigrees#index")
    end

    it "routes to #new" do
      get("/pedigrees/new").should route_to("pedigrees#new")
    end

    it "routes to #show" do
      get("/pedigrees/1").should route_to("pedigrees#show", :id => "1")
    end

    it "routes to #edit" do
      get("/pedigrees/1/edit").should route_to("pedigrees#edit", :id => "1")
    end

    it "routes to #create" do
      post("/pedigrees").should route_to("pedigrees#create")
    end

    it "routes to #update" do
      put("/pedigrees/1").should route_to("pedigrees#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/pedigrees/1").should route_to("pedigrees#destroy", :id => "1")
    end

  end
end
