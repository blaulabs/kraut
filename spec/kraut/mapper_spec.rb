require "spec_helper"
require "kraut/mapper"

describe Kraut::Mapper do
  let :mapper do
    Class.new do
      include Kraut::Mapper
      attr_accessor :name, :email
    end
  end

  describe "#initialize" do
    it "should assign the given attributes" do
      principal = mapper.new :name => "Chuck Norris", :email => "chuck.norris@gmail.com"
      
      principal.name.should == "Chuck Norris"
      principal.email.should == "chuck.norris@gmail.com"
    end
  end

  describe "#mass_assign!" do
    it "should assign the given attributes" do
      principal = mapper.new
      principal.mass_assign! :name => "Chuck Norris", :email => "chuck.norris@gmail.com"
      
      principal.name.should == "Chuck Norris"
      principal.email.should == "chuck.norris@gmail.com"
    end
  end

end
