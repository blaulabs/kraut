require "spec_helper"

describe Kraut::Rails::Engine do

  describe "#resolve_authorization_aliases" do

    it "returns a hash for authorizations use (replaces group aliases)" do
      Kraut::Rails::Engine.resolve_authorization_aliases(
        {
          "action1" => ["group1", "group2"],
          "action2" => ["group2"]
        }, {
          "group1" => "external_group1",
          "group2" => "external_group2"
        }
      ).should == {
        "action1" => ["external_group1", "external_group2"],
        "action2" => ["external_group2"]
      }
    end

  end

end
