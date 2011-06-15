require "spec_helper"

describe ApplicationController do

  context "when a SecurityError was raised" do
    controller do
      def index
        raise SecurityError
      end
    end

    it "swallows error, sets an alert and redirects to the login page" do
      lambda { get :index }.should_not raise_error(Kraut::InvalidPrincipalToken)
      flash[:alert].should == I18n.t("errors.kraut.session_expired")
      response.should redirect_to("/sessions/new")
    end
  end

  describe "#switch_user" do
    it "stores the user in the session" do
      session[:user].should be_nil
      controller.switch_user(user = Kraut::Session.new)
      session[:user].should == user
    end
  end

  describe "#user" do
    it "retrieves the user from the session" do
      controller.user.should be_nil
      session[:user] = user = Kraut::Session.new
      controller.user.should == user
    end
  end

  describe "#logged_in?" do
    it "returns false when not logged in" do
      controller.logged_in?.should == false
    end
    it "returns true when logged in" do
      controller.switch_user(Kraut::Session.new)
      controller.logged_in?.should == true
    end
  end

  context "#allowed_to?" do
    before { controller.expects(:authenticate_application) }

    it "should return false when not logged in" do
      controller.allowed_to?(:act).should == false
    end

    it "should return false when logged in user is not allowed to perform action" do
      controller.switch_user(user = Kraut::Session.new)
      user.expects(:allowed_to?).with(:act).returns(false)
      controller.allowed_to?(:act).should == false
    end

    it "should return true when logged in user is allowed to perform action" do
      controller.switch_user(user = Kraut::Session.new)
      user.expects(:allowed_to?).with(:act).returns(true)
      controller.allowed_to?(:act).should == true
    end
  end

  context "before_filters" do

    describe ":check_for_crowd_token" do
      controller do
        before_filter :check_for_crowd_token
        def index
          render :text => 'no fail'
        end
      end

      it "raises no error, resets the session, sets an alert and redirects to the login page if no principal is found" do
        controller.expects(:authenticate_application)
        Kraut::Session.expects(:find_by_token).with('abcd').raises(Kraut::InvalidPrincipalToken)
        lambda { get :index, :crowd_token => 'abcd' }.should_not raise_error(Kraut::InvalidPrincipalToken)
        session.should be_empty
        flash[:alert].should == I18n.t("errors.kraut.token_not_found")
        response.should redirect_to("/sessions/new")
      end

      it "sets the user session to the principal" do
        controller.expects(:authenticate_application)
        Kraut::Session.expects(:find_by_token).with('abcd').returns(user = Kraut::Session.new)
        user.stubs(:allowed_to?).returns(true)
        get :index, :crowd_token => 'abcd'
        response.should be_success
        response.body.should == 'no fail'
      end

      it "only takes action if the crowd_token param is set" do
        Kraut::Session.expects(:find_by_token).never
        get :index
        response.should be_success
        response.body.should == 'no fail'
      end
    end

    describe ":verify_login" do
      controller do
        before_filter :verify_login
        def index
          render :text => 'no fail'
        end
      end

      it "does nothing when logged in" do
        controller.switch_user(Kraut::Session.new)
        get :index
        controller.stored_location!.should be_nil
        response.should be_success
        response.body.should == 'no fail'
      end

      it "stores the current location and redirects the the login page when not logged in" do
        get :index
        controller.stored_location!.should_not be_nil
        response.should redirect_to("/sessions/new")
      end
    end

    describe ":verify_access" do
      before { controller.expects(:authenticate_application) }

      controller do
        before_filter :set_params, :verify_access
        def index
          render :text => 'no fail'
        end
        def set_params
          params[:controller] = 'cont'
          params[:action] = 'act'
        end
      end

      it "does nothing when logged in and authorized" do
        controller.switch_user(user = Kraut::Session.new)
        user.expects(:allowed_to?).with('cont_act').returns(true)
        get :index
        controller.stored_location!.should be_nil
        response.should be_success
        response.body.should == 'no fail'
      end

      it "stores the current location, sets and alert and redirects the the login page when logged in but unauthorized" do
        controller.switch_user(user = Kraut::Session.new)
        user.expects(:allowed_to?).with('cont_act').returns(false)
        controller.expects(:store_current_location)
        get :index
        flash[:alert].should == I18n.t("errors.kraut.access_denied")
        response.should redirect_to("/sessions/new")
      end

      it "stores the current location, sets and alert and redirects the the login page when not logged in" do
        controller.expects(:store_current_location)
        get :index
        flash[:alert].should == I18n.t("errors.kraut.access_denied")
        response.should redirect_to("/sessions/new")
      end
    end

  end

  context "internal methods" do

    describe "#authenticate_application" do
      it "authenticates the application when required" do
        Kraut::Rails::Engine.config.webservice = { :user => "u", :password => "p" }
        Kraut::Application.expects(:authentication_required?).with(25).returns(true)
        Kraut::Application.expects(:authenticate).with("u", "p")
        controller.authenticate_application
      end

      it "doesn't authenticate the application when not required" do
        Kraut::Application.stubs(:authentication_required?).returns(false)
        Kraut::Application.expects(:authenticate).never
        controller.authenticate_application
      end
    end

    describe "#store_current_location" do
      controller do
        def index
          store_current_location
          render :text => 'no fail'
        end
      end

      it "stores request's full path on a GET" do
        get :index
        response.should be_success
        response.body.should == 'no fail'
        controller.stored_location!.should == "/stub_resources"
      end

      %w(delete head post put).each do |method|
        it "doesn't store request's full path on a #{method.upcase}" do
          send method, :index
          response.should be_success
          response.body.should == 'no fail'
          controller.stored_location!.should be_nil
        end
      end
    end

    describe "#stored_location!" do
      it "retrieves the location stored in the session, then delete it" do
        controller.stored_location!.should be_nil
        session[:stored_location] = "loc"
        controller.stored_location!.should == "loc"
        controller.stored_location!.should be_nil
      end
    end

  end

end
