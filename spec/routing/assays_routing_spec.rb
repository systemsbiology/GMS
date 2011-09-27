require "spec_helper"

describe AssaysController do
  describe "routing" do

    it "routes to #index" do
      get("/assays").should route_to("assays#index")
    end

    it "routes to #new" do
      get("/assays/new").should route_to("assays#new")
    end

    it "routes to #show" do
      get("/assays/1").should route_to("assays#show", :id => "1")
    end

    it "routes to #edit" do
      get("/assays/1/edit").should route_to("assays#edit", :id => "1")
    end

    it "routes to #create" do
      post("/assays").should route_to("assays#create")
    end

    it "routes to #update" do
      put("/assays/1").should route_to("assays#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/assays/1").should route_to("assays#destroy", :id => "1")
    end

  end
end
