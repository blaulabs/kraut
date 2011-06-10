require "spec_helper"

describe ApplicationController do

  before do
    controller.stubs(:authenticate_application).returns(true)
  end

  context "when a SecurityError was raised" do
    controller do
      def index
        raise SecurityError
      end
    end

    it "swallows error, sets an alert and redirects to the home page" do
      lambda { get :index }.should_not raise_error(Kraut::InvalidPrincipalToken)
      flash[:alert].should == I18n.t("errors.kraut.session_expired")
      response.should redirect_to("/sessions/new")
    end
  end

  context "#allowed_to?" do

    it "should return false when not logged in" do
      controller.allowed_to?(:act).should == false
    end

    it "should return false when logged in user is not allowed to perform action" do
      session[:user] = Kraut::Session.new
      session[:user].expects(:allowed_to?).with(:act).returns(false)
      controller.allowed_to?(:act).should == false
    end

    it "should return true when logged in user is allowed to perform action" do
      session[:user] = Kraut::Session.new
      session[:user].expects(:allowed_to?).with(:act).returns(true)
      controller.allowed_to?(:act).should == true
    end

  end

  context "authenticating via crowd_token" do
    controller do
      before_filter :check_for_crowd_token
      def index
        render :text => 'no fail'
      end
    end

    it "raises no error, sets an alert and redirects to the login page if no principal is found" do
      Kraut::Session.expects(:find_by_token).with('abcd').raises(Kraut::InvalidPrincipalToken)
      lambda { get :index, :crowd_token => 'abcd' }.should_not raise_error(Kraut::InvalidPrincipalToken)
      flash[:alert].should == I18n.t("errors.kraut.token_not_found")
      response.should redirect_to("/sessions/new")
    end

    it "sets the user session to the principal" do
      Kraut::Session.expects(:find_by_token).with('abcd').returns(user = Kraut::Session.new)
      user.stubs(:allowed_to?).returns(true)
      get :index, :crowd_token => 'abcd'
      response.should be_success
    end

    it "only takes action if the crowd_token param is set" do
      Kraut::Session.expects(:find_by_token).never
      # begin
        get :index
      # rescue => e
      #   puts e.backtrace
      # end
    end
  end

end
