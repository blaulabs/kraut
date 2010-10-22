require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

Savon.log = false

# Requires supporting files.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include SavonHelper
end
