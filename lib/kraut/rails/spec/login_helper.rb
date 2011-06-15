module Kraut

  module Rails

    module Spec

      module LoginHelper

        def login!
          Kraut::Application.stubs(:authentication_required?).returns(false)
          session[:user] = create_user
        end

        def logout!
          session[:user] = nil
        end

        def user
          session[:user]
        end

      end

    end

  end

end
