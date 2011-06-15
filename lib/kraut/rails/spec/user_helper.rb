module Kraut

  module Rails

    module Spec

      module UserHelper

        def create_user
          Kraut::Session.new(
            :username => "user",
            :password => "secret",
            :principal => Kraut::Principal.new(
              :name => "user",
              :password => "secret",
              :token => "token"
            )
          )
        end

      end

    end

  end

end
