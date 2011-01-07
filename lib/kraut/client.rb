require "savon"
require "kraut/kraut"

module Kraut

  autoload :Application, "kraut/application"

  # = Kraut::Client
  #
  # Wraps a <tt>Savon::Client</tt> and executes SOAP requests.
  module Client
    class << self

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
      # Adds application authentication credentials and delegates to the +request+ method.
      def auth_request(method, body = {})
        body[:in0] = { "aut:name" => Application.name, "aut:token" => Application.token }
        body[:order!] = body.keys.sort_by { |key| key.to_s }
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

      def handle_soap_fault(soap_fault)
        error = case soap_fault.to_hash[:fault][:detail].keys.first.to_s
          when /^invalid_authentication/    then InvalidAuthentication
          when /^invalid_authorization/     then InvalidAuthorization
          when /^application_access_denied/ then ApplicationAccessDenied
          else                                   UnknownError
        end
        
        raise error, soap_fault.to_s
      end

    end
  end
end
