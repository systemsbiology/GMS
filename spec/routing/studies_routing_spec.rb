require "spec_helper"

describe StudiesController do
  describe "routing" do

    it "routes to #index" do
      gets("/studies").should route_to("studies#index")
    end

    it "routes to #new" do
      gets("/studies/new").should route_to("studies#new")
    end

    it "routes to #show" do
      gets("/studies/1").should route_to("studies#show", :id => "1")
    end

    it "routes to #edit" do
      gets("/studies/1/edit").should route_to("studies#edit", :id => "1")
    end

    it "routes to #create" do
      posts("/studies").should route_to("studies#create")
    end

    it "routes to #update" do
      puts("/studies/1").should route_to("studies#update", :id => "1")
    end

    it "routes to #destroy" do
      deletes("/studies/1").should route_to("studies#destroy", :id => "1")
    end

  end
end
