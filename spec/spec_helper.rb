require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

Savon.log = false

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include SavonHelper
end

Kraut.endpoint = "http://example.com"
