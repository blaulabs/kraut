module Kraut

  class Error < RuntimeError; end
  class InvalidAuthorization < Error; end
  class InvalidAuthentication < Error; end

  class << self

    attr_accessor :endpoint

    # TODO: remove after testing.
    def endpoint
      @endpoint ||= "http://magnesium:8095/crowd/services/SecurityServer"
    end

    def namespace
      @namespace ||= "http://authentication.integration.crowd.atlassian.com"
    end

    attr_writer :namespace

  end
end
