require "spec_helper"
require "kraut/principal"

describe Kraut::Principal do

  let(:principal) { Kraut::Principal }

  before(:all) do
    savon.expects(:authenticate_application).returns(:success)
    Kraut::Application.authenticate "app", "password"
  end

  describe "attributes" do
    let(:principal) { Kraut::Principal.authenticate "test", "password" }

    before do
      savon.expects(:authenticate_principal).returns(:success)
      savon.stubs(:find_principal_with_attributes_by_name).returns(:success)
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
    let(:principal) { Kraut::Principal.authenticate "test", "password" }

    before do
      savon.expects(:authenticate_principal).returns(:success)
      savon.stubs(:find_principal_with_attributes_by_name).returns(:success)
    end

    it "should return true if member of group" do
      savon.expects(:is_group_member).returns(:success)
      principal.member_of?("test_group").should be_true
    end

    it "should return false if not member of group" do
      savon.expects(:is_group_member).returns(:not_in_group)
      principal.member_of?("test_group").should be_false
    end

    it "should not ask crowd if positive group membership is already saved" do
      principal.groups["test_group"] = true
      principal.member_of?("test_group").should be_true
    end

    it "should not ask crowd if negative group membership is already saved" do
      principal.groups["test_group2"] = false
      principal.member_of?("test_group2").should be_false
    end
  end

  describe ".authenticate" do
    context "when successful" do
      before { savon.expects(:authenticate_principal).returns(:success) } 

      it "should return a principal" do
        principal = Kraut::Principal.authenticate "test", "password"
        principal.should be_a(Kraut::Principal)
      end
    end

    context "with an invalid password" do
      before { savon.expects(:authenticate_principal).returns(:invalid_password) }

      it "should raise an InvalidAuthentication" do
        lambda { Kraut::Principal.authenticate "test", "invalid_password" }.
          should raise_error(Kraut::InvalidAuthentication, /password was invalid/)
      end
    end

    context "with an invalid username" do
      before { savon.expects(:authenticate_principal).returns(:invalid_user) }

      it "should raise an InvalidAuthentication" do
        lambda { Kraut::Principal.authenticate "invalid_user", "password" }.
          should raise_error(Kraut::InvalidAuthentication, /Failed to find entity of type/)
      end
    end

    context "when the user is not allowed to access the application" do
      before { savon.expects(:authenticate_principal).returns(:application_access_denied) }

      it "should raise an InvalidAuthentication" do
        lambda { Kraut::Principal.authenticate "test", "password" }.
          should raise_error(Kraut::ApplicationAccessDenied, /User does not have access to application/)
      end
    end
  end

end
