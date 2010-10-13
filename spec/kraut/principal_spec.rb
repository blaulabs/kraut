require "spec_helper"
require "kraut/principal"

describe Kraut::Principal do
  let(:principal) { Kraut::Principal }

  before(:all) do
    savon_mock :authenticate_application, :success
    Kraut::Application.authenticate "app", "password"
  end

  describe "attributes" do
    let(:principal) { Kraut::Principal.authenticate "test", "password" }

    before do
      savon_mock :authenticate_principal, :success
      #savon_mock :find_principal_with_attributes_by_name, :success
    end

    it "should have a name" do
      principal.name.should == 'test'
    end

    it "should have a password" do
      principal.password.should == 'password'
    end

    it "should have a token" do
      principal.token.should == 'COvlhb092poBHXi4rh4PQg00'
    end
  end

  describe ".authenticate" do
    before do 
      savon_mock :authenticate_principal, :success
      #savon_mock :find_principal_with_attributes_by_name, :success
    end 

    it "should return a principal" do
      principal = Kraut::Principal.authenticate "test", "Blau123"
      principal.should be_a(Kraut::Principal)
    end

    context "in context of an invalid password" do
      it "should raise an InvalidAuthentication " do
        savon_mock :authenticate_principal, :invalid_password
        
        lambda { Kraut::Principal.authenticate "test", "invalid_password"}.
          should raise_error(Kraut::InvalidAuthentication, /password was invalid/)
      end
    end

    context "in context of an invalid username" do
      it "should raise an InvalidAuthentication " do
        savon_mock :authenticate_principal, :invalid_user
        
        lambda { Kraut::Principal.authenticate "invalid_user", "password"}.
          should raise_error(Kraut::InvalidAuthentication, /Failed to find entity of type/)
      end
    end
  end

  describe ".new" do
    it "should accept a Hash of attributes"
    it "should find the principal's attributes"
  end

end
