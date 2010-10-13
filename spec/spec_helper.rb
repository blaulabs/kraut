require "rspec"
require "mocha"
require "webmock"

# Requires supporting files.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }

Rspec.configure do |config|
  config.mock_with :mocha
  config.include SavonHelper
end
