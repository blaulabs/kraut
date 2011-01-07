require "kraut/client"

module Kraut

  # = Kraut::Application
  #
  # Represents an application registered with Crowd.
  class Application

    class << self

      # Authenticates an application with a given +name+ and +password+.
      def authenticate(name, password)
        response = Client.request :authenticate_application,
          :in0 => { "aut:credential" => { "aut:credential" => password }, "aut:name" => name }
        
        self.authenticated_at = Time.now
        self.name, self.password, self.token = name, password, response[:out][:token]
      end

      attr_accessor :name, :password, :token, :authenticated_at

      def authentication_required?(timeout = 10)
        !authenticated_at || authenticated_at < Time.now - (60 * timeout)
      end

    end

  end
end
