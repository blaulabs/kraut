module Kraut

  class SessionsController < ActionController::Base

    layout Kraut::Rails::Engine.config.layout

    def new
      @session = Kraut::Session.new
    end

    def create
      @session = Kraut::Session.new params[:kraut_session]

      authenticate_application
      if @session.valid?
        switch_user(@session)
        redirect_to stored_location! || Kraut::Rails::Engine.config.entry_url
      else
        render :new
      end
    end

    def destroy
      reset_session
      redirect_to Kraut::Rails::Engine.config.entry_url
    end

  end

end
