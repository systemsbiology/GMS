require "spec_helper"

describe TraitsController do
  describe "routing" do

    it "routes to #index" do
      get("/traits").should route_to("traits#index")
    end

    it "routes to #new" do
      get("/traits/new").should route_to("traits#new")
    end

    it "routes to #show" do
      get("/traits/1").should route_to("traits#show", :id => "1")
    end

    it "routes to #edit" do
      get("/traits/1/edit").should route_to("traits#edit", :id => "1")
    end

    it "routes to #create" do
      post("/traits").should route_to("traits#create")
    end

    it "routes to #update" do
      put("/traits/1").should route_to("traits#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/traits/1").should route_to("traits#destroy", :id => "1")
    end

  end
end
