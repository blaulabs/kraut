require "spec_helper"

describe Kraut::SessionsController do

  describe "routing" do
    it "should route to new" do
      { :get => "/sessions/new" }.
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
    before do
      @user = Kraut::Session.new
      Kraut::Session.expects(:new).returns(@user)
      controller.expects(:authenticate_application)
      Kraut::Rails::Engine.config.entry_url = "/blu"
    end

    context "with valid credentials" do
      context "and :stored_location is not set" do
        before do
          @user.expects(:valid?).returns(true)
          post :create
        end

        it "should store the new session" do
          controller.user.should == @user
        end

        it "should redirect to configured entry_url" do
          response.should redirect_to("/blu")
        end
      end

      context "and :stored_location is set" do
        before do
          @user.expects(:valid?).returns(true)
          session[:stored_location] = "/url/we/want"
          post :create
        end

        it "should store the new session" do
          controller.user.should == @user
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
        @user.expects(:valid?).returns(false)
        session[:stored_location] = "/url/we/want"
        post :create
      end

      it "should not store the new session" do
        controller.user.should be_nil
      end

      it "should render the :new action" do
        response.should render_template(:new)
      end

      it "should not delete the :stored_location parameter" do
        session[:stored_location].should_not be_nil
      end
    end
  end

  describe "DELETE :destroy" do
    it "should logout, reset the session and redirect to configured entry_url" do
      controller.switch_user(Kraut::Session.new)
      Kraut::Rails::Engine.config.entry_url = "/bla"
      delete :destroy
      controller.logged_in?.should == false
      session.should == {}
      response.should redirect_to("/bla")
    end
  end

end
