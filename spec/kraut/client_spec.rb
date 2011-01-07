require "spec_helper"
require "kraut/client"

describe Kraut::Client do

  shared_examples_for "a Kraut::Client" do
    context "when receiving an ApplicationAccessDenied error" do
      it "should raise a Kraut::ApplicationAccessDenied error" do
        savon.expects(:authenticate_principal).returns(:application_access_denied)
        expect { subject.request :authenticate_principal, :some => :request }.to raise_error(Kraut::ApplicationAccessDenied)
      end
    end

    context "when receiving an InvalidAuthentication error" do
      it "should raise a Kraut::InvalidAuthentication error" do
        savon.expects(:authenticate_principal).returns(:invalid_user)
        expect { subject.request :authenticate_principal, :some => :request }.to raise_error(Kraut::InvalidAuthentication)
      end
    end
  end

  describe ".request" do
    context "when successful" do
      before do
        savon.expects(:authenticate_application).with(
          :in0 => { "aut:credential" => { "aut:credential" => "password" }, "aut:name" => "name" }
        ).returns(:success)
      end

      it "should return the response as a Hash" do
        result = subject.request :authenticate_application, :in0 => {
          "aut:credential" => { "aut:credential" => "password" }, "aut:name" => "name"
        }
        
        result.should include(:out => { :token => "J8n5KCem7Djk30zel0rUdA00", :name => "app" })
      end
    end

    context "when Savon raises errors" do
      it_should_behave_like "a Kraut::Client"
    end

    context "when Savon does not raise errors" do
      it_should_behave_like "a Kraut::Client"
    end
  end

  describe ".auth_request" do
    context "when successful" do
      before do
        Kraut::Application.expects(:name).returns("app")
        Kraut::Application.expects(:token).returns("J8n5KCem7Djk30zel0rUdA00")
        
        savon.expects(:authenticate_principal).with(
          :in0 => { "aut:name" => "app", "aut:token" => "J8n5KCem7Djk30zel0rUdA00" },
          :in1 => {
            "aut:application" => "app",
            "aut:credential" => { "aut:credential" => "password" }, "aut:name" => "name"
          },
          :order! => [:in0, :in1]
        ).returns(:success)
      end

      it "should return the response as a Hash" do
        result = subject.auth_request :authenticate_principal, :in1 => {
          "aut:application" => "app",
          "aut:credential" => { "aut:credential" => "password" }, "aut:name" => "name"
        }
        
        result.should include(:out => "COvlhb092poBHXi4rh4PQg00")
      end
    end

    context "when Savon raises errors" do
      it_should_behave_like "a Kraut::Client"
    end

    context "when Savon does not raise errors" do
      it_should_behave_like "a Kraut::Client"
    end
  end

  describe ".client" do
    it "should return a Savon::Client instance" do
      Kraut::Client.client.should be_a(Savon::Client)
    end

    it "should memoize the Savon::Client instance" do
      Kraut::Client.client.should equal(Kraut::Client.client)
    end

    it "should set the SOAP endpoint" do
      Kraut::Client.client.wsdl.endpoint.should == Kraut.endpoint
    end

    it "should set the target namespace" do
      Kraut::Client.client.wsdl.namespace.should == "urn:SecurityServer"
    end
  end

end
