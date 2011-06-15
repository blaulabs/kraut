module Kraut

  module Rails

    module Authentication

      def self.included(base)
        base.helper_method :user, :logged_in?, :allowed_to?
        base.rescue_from SecurityError do |e|
          reset_session
          redirect_to new_kraut_sessions_path, :alert => I18n.t("errors.kraut.session_expired")
        end
      end

      # The timeout for a Crowd session in minutes.
      CROWD_SESSION_TIMEOUT_MINUTES = 25

      def switch_user(user)
        session[:user] = user
      end

      def user
        session[:user]
      end

      def logged_in?
        !user.nil?
      end

      def allowed_to?(action)
        authenticate_application
        !!user && user.allowed_to?(action)
      end

      def check_for_crowd_token
        if params[:crowd_token]
          begin
            authenticate_application
            switch_user(Session.find_by_token(params[:crowd_token]))
          rescue Kraut::InvalidPrincipalToken
            reset_session
            redirect_to new_kraut_sessions_path, :alert => I18n.t("errors.kraut.token_not_found")
          end
        end
      end

      def verify_login
        unless user
          store_current_location
          redirect_to new_kraut_sessions_path
        end
      end

      def verify_access
        authenticate_application
        unless user.allowed_to?("#{params[:controller]}_#{params[:action]}")
          store_current_location
          redirect_to new_kraut_sessions_path, :alert => I18n.t("errors.kraut.access_denied")
        end
      end

    protected

      def authenticate_application
        if Kraut::Application.authentication_required? CROWD_SESSION_TIMEOUT_MINUTES
          Kraut::Application.authenticate Kraut::Rails::Engine.config.webservice[:user], Kraut::Rails::Engine.config.webservice[:password]
        end
      end

      def store_current_location
        session[:stored_location] = request.fullpath if request.get?
      end

      def stored_location
        session.delete(:stored_location)
      end

    end

  end

end
