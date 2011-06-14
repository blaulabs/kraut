require "spec_helper"
require "kraut/mapper"

describe Kraut::Mapper do

  subject do
    Class.new do
      include Kraut::Mapper
      attr_accessor :name, :email
    end
  end

  describe "#initialize" do

    it "should call mass_assign! when with the given opts" do
      subject.any_instance.expects(:mass_assign!).with(opts = {})
      principal = subject.new(opts)
    end

    it "should call mass_assign! when with nil when given nothing" do
      subject.any_instance.expects(:mass_assign!).with(nil)
      principal = subject.new
    end

  end

  describe "#mass_assign!" do

    let(:principal) { subject.new }

    it "should assign the given attributes" do
      principal.mass_assign! :name => "Chuck Norris", :email => "chuck.norris@gmail.com"

      principal.name.should == "Chuck Norris"
      principal.email.should == "chuck.norris@gmail.com"
    end

    it "should not fail when given nil" do
      principal.mass_assign! nil
    end

    it "should fail when given a non-existant attribute" do
      lambda { principal.mass_assign! :failing => 'non-existant' }.should raise_error(NoMethodError)
    end

  end

end
