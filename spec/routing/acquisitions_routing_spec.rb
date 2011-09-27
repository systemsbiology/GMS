require "spec_helper"

describe AcquisitionsController do
  describe "routing" do

    it "routes to #index" do
      get("/acquisitions").should route_to("acquisitions#index")
    end

    it "routes to #new" do
      get("/acquisitions/new").should route_to("acquisitions#new")
    end

    it "routes to #show" do
      get("/acquisitions/1").should route_to("acquisitions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/acquisitions/1/edit").should route_to("acquisitions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/acquisitions").should route_to("acquisitions#create")
    end

    it "routes to #update" do
      put("/acquisitions/1").should route_to("acquisitions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/acquisitions/1").should route_to("acquisitions#destroy", :id => "1")
    end

  end
end
