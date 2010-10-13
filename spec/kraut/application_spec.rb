require "spec_helper"
require "kraut/application"

describe Kraut::Application do
  let(:application) { Kraut::Application }

  before(:all) do
    savon_mock :authenticate_application, :success
    Kraut::Application.authenticate "app", "password"
  end
 
  describe ".authenticate" do
    it "should return the application credentials" do
      credentials = application.authenticate "app", "password"
      credentials.should == ["app", "password", "J8n5KCem7Djk30zel0rUdA00"]
    end

    it "should set the application name" do
      application.name.should == "app"
    end

    it "should set the application password" do
      application.password.should == "password"
    end

    it "should set the authentication token" do
      application.token.should == "J8n5KCem7Djk30zel0rUdA00"
    end

    context "in case of an invalid application name" do
      before { savon_mock :authenticate_application, :invalid_app }

      it "should raise an InvalidAuthentication error" do
        lambda { Kraut::Application.authenticate "invalid", "invalid" }.
          should raise_error(Kraut::InvalidAuthentication, /with identifier \[invalid\]/)
      end
    end

    context "in case of an invalid password" do
      before { savon_mock :authenticate_application, :invalid_password }

      it "should raise an InvalidAuthentication error" do
        lambda { Kraut::Application.authenticate "app", "invalid" }.
          should raise_error(Kraut::InvalidAuthentication, /Application with invalid password/)
      end
    end
  end

  describe ".name" do
    it "should contain the application name" do
      application.name.should == "app"
    end
  end

  describe ".password" do
    it "should contain the application password" do
      application.password.should == "password"
    end
  end

  describe ".token" do
    it "should contain the authentication token" do
      application.token.should == "J8n5KCem7Djk30zel0rUdA00"
    end
  end

end
