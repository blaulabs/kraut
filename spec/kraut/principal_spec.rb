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
      savon_mock :find_principal_with_attributes_by_name, :success
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

    it "should have a display_name" do
      principal.display_name.should == "Test User"
    end

    it "should have a requires_password_change?" do
      principal.requires_password_change?.should be_false
    end

    it "should have an email" do
      principal.email.should == "test@blau.de"
    end
  end

  describe "member_of?" do
   
    before do
      savon_mock :authenticate_principal, :success
      savon_mock :find_principal_with_attributes_by_name, :success 
    end

    let(:principal) { Kraut::Principal.authenticate "test", "password" }

    it "should return true if member of group" do
      savon_mock :is_group_member, :success
      principal.member_of?("test_group").should be_true
    end

    it "should return false if not member of group" do
      savon_mock :is_group_member, :not_in_group
      principal.member_of?("test_group").should be_false
    end

    it "should do not call crowd if group membership is saved" do
      principal.groups << "test_group"
      principal.member_of?("test_group").should be_true
    end

  end

  describe ".authenticate" do
    before do 
      savon_mock :authenticate_principal, :success
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

end
