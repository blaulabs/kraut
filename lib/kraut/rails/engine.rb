require 'rails'

require 'kraut'
require 'kraut/rails/authentication'

module Kraut

  module Rails

    class Engine < ::Rails::Engine

      config.after_initialize do
        ActionController::Base.class_eval do
          include Kraut::Rails::Authentication
        end
      end

    end

  end

end
