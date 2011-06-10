require "spec_helper"

describe Kraut::SessionsController do
  before { Kraut::Application.stubs(:authentication_required?).returns(false) }

  describe "routing" do
    it "should route to new" do
      { :get => "/", :get => "/sessions/new" }.
        should route_to(:controller => "kraut/sessions", :action => "new")
    end

    it "should route to create" do
      { :post => "/sessions" }.
        should route_to(:controller => "kraut/sessions", :action => "create")
    end

    it "should route to destroy" do
      { :delete => "/sessions" }.
        should route_to(:controller => "kraut/sessions", :action => "destroy")
    end
  end

  describe "GET :new" do
    it "should assign a session" do
      get :new
      assigns[:session].should be_a(Kraut::Session)
    end
  end

  describe "POST :create" do
    context "with valid credentials" do
      context "and :stored_location is not set" do
        before do
          Kraut::Session.any_instance.expects(:valid?).returns(true)
          post :create
        end

        it "should store the new session" do
          session[:user].should be_a(Kraut::Session)
        end

        it "should redirect to home page" do
          response.should redirect_to("/")
        end
      end

      context "and :stored_location is set " do
        before do
          Kraut::Session.any_instance.expects(:valid?).returns(true)
          session[:stored_location] = "/url/we/want"
          post :create
        end

        it "should store the new session" do
          session[:user].should be_a(Kraut::Session)
        end

        it "should redirect to :stored_location" do
          response.should redirect_to("/url/we/want")
        end

        it "should delete the :stored_location parameter" do
          session[:stored_location].should be_nil 
        end
      end
    end

    context "with invalid credentials" do
      before do
        Kraut::Session.any_instance.expects(:valid?).returns(false)
        post :create
      end

      it "should render the :new action" do
        response.should render_template(:new)
      end
    end
  end

  describe "DELETE :destroy" do
    it "should redirect to root" do
      delete :destroy
      response.should redirect_to("/")
    end
  end

end
