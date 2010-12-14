require "savon"
require "kraut/kraut"

module Kraut

  autoload :Application, "kraut/application"

  # = Kraut::Client
  #
  # Contains class and instance methods for executing SOAP requests.
  module Client

    module ClassMethods

      # Executes a SOAP request to a given +method+ with an optional +body+ Hash.
      # Ensures to always raise SOAP faults if they happen and returns a response Hash.
      def request(method, body = {})
        response = client.request :wsdl, method do
          soap.namespaces["xmlns:aut"] = Kraut.namespace
          soap.body = body
        end
        
        if response.soap_fault?
          handle_soap_fault response.soap_fault
        else
          response.to_hash["#{method}_response".to_sym]
        end
      rescue Savon::SOAP::Fault => soap_fault
        handle_soap_fault soap_fault
      end

      # Executes a SOAP request to a given +method+ with an optional +body+ Hash.
      # Adds application authentication credentials.
      def auth_request(method, body = {})
        body[:in0] = { "aut:name" => Application.name, "aut:token" => Application.token }
        body[:order!] = sort_elements body
        request method, body
      end

      # Returns a memoized <tt>Savon::Client</tt> for executing SOAP requests.
      def client
        @client ||= Savon::Client.new do
          wsdl.endpoint = Kraut.endpoint
          wsdl.namespace = "urn:SecurityServer"
        end
      end

    private

      def sort_elements(body)
        body.map { |key, value| key.to_s }.sort.map { |item| item.to_sym }
      end

      def handle_soap_fault(soap_fault)
        error = case soap_fault.to_hash[:fault][:detail].keys.first.to_s
          when /^invalid_authentication/              then InvalidAuthentication
          when /^invalid_authorization/               then InvalidAuthorization
          when /^application_access_denied_exception/ then ApplicationAccessDenied
          else                                             UnknownError
        end
        
        raise error, soap_fault.to_s
      end

    end

    def self.included(base)
      base.extend ClassMethods
    end

    # Delegates to <tt>self.class.request</tt>.
    def request(method, body = {})
      self.class.request method, body
    end

    # Delegates to <tt>self.class.auth_request</tt>.
    def auth_request(method, body = {})
      self.class.auth_request method, body
    end

    # Delegates to <tt>self.class.client</tt>.
    def client
      self.class.client
    end

  end
end
