require "spec_helper"

describe PersonAliasesController do
  describe "routing" do

    it "routes to #index" do
      get("/person_aliases").should route_to("person_aliases#index")
    end

    it "routes to #new" do
      get("/person_aliases/new").should route_to("person_aliases#new")
    end

    it "routes to #show" do
      get("/person_aliases/1").should route_to("person_aliases#show", :id => "1")
    end

    it "routes to #edit" do
      get("/person_aliases/1/edit").should route_to("person_aliases#edit", :id => "1")
    end

    it "routes to #create" do
      post("/person_aliases").should route_to("person_aliases#create")
    end

    it "routes to #update" do
      put("/person_aliases/1").should route_to("person_aliases#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/person_aliases/1").should route_to("person_aliases#destroy", :id => "1")
    end

  end
end
