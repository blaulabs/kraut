module SavonHelper

  autoload :Fixture, "spec/support/fixture"

  def savon_mock(*args)
    # setup check of correct parameters
    expected = args.pop if Hash === args.last
    Savon::SOAP::XML.any_instance.expects(:body=).with(expected) if expected
    
    # setup response
    response = HTTPI::Response.new 200, {}, Fixture[*args]
    HTTPI.stubs(:post).returns(response)
  end

end
