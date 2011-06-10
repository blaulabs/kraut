require "spec_helper"

describe Kraut::Session do

  describe "validations" do
    # TODO should_validate_presence_of :username, :password
  end

  describe "attributes" do
    let(:session) { Kraut::Session.new(:username => "user", :password => "secret", :principal => Kraut::Principal.new(:name => "name", :token => "token")) }

    describe "#name" do
      it "should return the principal's name" do
        session.name.should == "name"
      end
    end

    describe "#token" do
      it "should return the principal's token" do
        session.token.should == "token"
      end
    end

    describe "#allowed_to?" do
      context "when the principal is allowed for the given action" do
        it "should return true" do
          session.expects(:in_group?).returns(true)
          session.should be_allowed_to(:verify)
        end
      end

      context "when the principal is not allowed for the given action" do
        it "should return true" do
          session.expects(:in_group?).returns(false)
          session.should_not be_allowed_to(:invoice)
        end
      end
    end

    describe "#in_group?" do
      it "should return whether the principal belongs to any of the given groups" do
        Kraut::Principal.any_instance.expects(:member_of?).returns(true).then.returns(false)
        session.in_group?(["staff", "supervisor"]).should be_true
      end

      it "should return whether the principal belongs to single group" do
        Kraut::Principal.any_instance.expects(:member_of?).returns(false)
        session.in_group?("staff").should be_false
      end
    end
  end

  describe "#valid?" do
    it "should check the validations" do
      Kraut::Session.new.should_not be_valid
    end

    context "for a valid Crowd user" do
      before do
        principal = Kraut::Principal.new
        principal.expects(:requires_password_change?).returns(false)
        Kraut::Principal.expects(:authenticate).with("user", "secret").returns(principal)
      end

      it "should return true" do
        new_session.should be_valid
      end
    end

    context "for an invalid Crowd user" do
      before do
        Kraut::Principal.expects(:authenticate).with("user", "secret").raises(Kraut::InvalidAuthentication)
      end

      it "should return false" do
        new_session.should_not be_valid
      end

      it "should record an error" do
        session = new_session
        session.valid?
        session.errors[:base].first.should == I18n.t("errors.kraut.invalid_credentials")
      end
    end

    context "for a Crowd user with no access to the application" do
      before do
        Kraut::Principal.expects(:authenticate).with("user", "secret").raises(Kraut::ApplicationAccessDenied)
      end

      it "should return false" do
        new_session.should_not be_valid
      end

      it "should record an error" do
        session = new_session
        session.valid?
        session.errors[:base].first.should == I18n.t("errors.kraut.application_access_denied")
      end
    end

    context "for a Crowd user with an expired password" do
      before do
        principal = Kraut::Principal.new
        principal.expects(:requires_password_change?).returns(true)
        Kraut::Principal.expects(:authenticate).with("user", "secret").returns(principal)
      end

      it "should return false" do
        new_session.should_not be_valid
      end

      it "should record an error" do
        session = new_session
        session.valid?
        session.errors[:base].first.should == I18n.t("errors.kraut.password_expired")
      end
    end
    
    it "doesn't log in the user if he already is logged in" do
      session = new_session
      session.principal = Kraut::Principal.new
      session.valid?.should == true
    end
    
    def new_session
      Kraut::Session.new :username => "user", :password => "secret"
    end
  end
  
  context ".find_by_token" do
    it "returns a new session with the principal assigned to it on success" do
      principal = Kraut::Principal.new

      Kraut::Principal.expects(:find_by_token).with('abcd').returns(principal)
      session = Kraut::Session.find_by_token('abcd')
      session.should be_a(Kraut::Session)
      session.principal.should == principal
    end
    
    it "passes through Kraut::InvalidPrincipalToken error thrown by the crowd server" do
      Kraut::Principal.stubs(:find_by_token).raises(Kraut::InvalidPrincipalToken)
      lambda { Kraut::Session.find_by_token('abcd') }.should raise_error(Kraut::InvalidPrincipalToken)
    end

  end

end
