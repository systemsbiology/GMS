require "spec_helper"

describe PhenotypesController do
  describe "routing" do

    it "routes to #index" do
      get("/phenotypes").should route_to("phenotypes#index")
    end

    it "routes to #new" do
      get("/phenotypes/new").should route_to("phenotypes#new")
    end

    it "routes to #show" do
      get("/phenotypes/1").should route_to("phenotypes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/phenotypes/1/edit").should route_to("phenotypes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/phenotypes").should route_to("phenotypes#create")
    end

    it "routes to #update" do
      put("/phenotypes/1").should route_to("phenotypes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/phenotypes/1").should route_to("phenotypes#destroy", :id => "1")
    end

  end
end
