require "kraut/client"

module Kraut

  # = Kraut::Application
  #
  # Represents an application registered with Crowd.
  class Application
    include Client

    class << self

      # Authenticates an application with a given +name+ and +password+.
      def authenticate(name, password)
        response = request :authenticate_application,
          :in0 => { "aut:credential" => { "aut:credential" => password }, "aut:name" => name }
        
        self.name, self.password, self.token = name, password, response[:out][:token]
      end

      attr_accessor :name, :password, :token

    end

  end
end
