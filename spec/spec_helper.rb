require "bundler"
Bundler.require :default, :development

require "kraut/rails/engine"
Kraut.endpoint = "http://example.com"
Kraut::Rails::Engine.config.layout = false
Kraut::Rails::Engine.config.entry_url = "/"
Kraut::Rails::Engine.config.authorizations = {}

# stupid stuff to let the engine act as if it's included in an app
require "action_controller"
module Kraut
  module Rails
    class Application < ::Rails::Application; end
  end
end
Kraut::Rails::Application.configure do
  config.active_support.deprecation = :log
end
Kraut::Rails::Application.initialize!
ActionController::Base.send :include, Rails.application.routes.url_helpers
class ApplicationController < ActionController::Base; end
# end stupid stuff

require "rspec/rails"

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Savon::Spec::Macros
end

Savon.log = false
Savon::Spec::Fixture.path = File.expand_path("../fixtures", __FILE__)
