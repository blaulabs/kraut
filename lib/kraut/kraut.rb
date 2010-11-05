module Kraut

  class Error < RuntimeError; end
  class InvalidAuthorization < Error; end
  class InvalidAuthentication < Error; end
  class UnknownError < Error; end

  class << self

    attr_accessor :endpoint

    def namespace
      @namespace ||= "http://authentication.integration.crowd.atlassian.com"
    end

    attr_writer :namespace

  end
end
