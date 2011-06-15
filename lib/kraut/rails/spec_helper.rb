require "kraut/rails/spec/login_helper"
require "kraut/rails/spec/protected_action"
require "kraut/rails/spec/user_helper"

Kraut::Application.stubs(:authenticate).returns(["name", "password", "token"])

Rspec.configure do |config|
  config.include Kraut::Rails::Spec::LoginHelper, :example_group => {
    :file_path => /spec\/(controllers|views|helpers)/
  }
  config.extend Kraut::Rails::Spec::ProtectedAction, :example_group => {
    :file_path => /spec\/controllers/
  }
  config.include Kraut::Rails::Spec::UserHelper
end
