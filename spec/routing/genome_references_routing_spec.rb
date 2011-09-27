require "spec_helper"

describe GenomeReferencesController do
  describe "routing" do

    it "routes to #index" do
      get("/genome_references").should route_to("genome_references#index")
    end

    it "routes to #new" do
      get("/genome_references/new").should route_to("genome_references#new")
    end

    it "routes to #show" do
      get("/genome_references/1").should route_to("genome_references#show", :id => "1")
    end

    it "routes to #edit" do
      get("/genome_references/1/edit").should route_to("genome_references#edit", :id => "1")
    end

    it "routes to #create" do
      post("/genome_references").should route_to("genome_references#create")
    end

    it "routes to #update" do
      put("/genome_references/1").should route_to("genome_references#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/genome_references/1").should route_to("genome_references#destroy", :id => "1")
    end

  end
end
