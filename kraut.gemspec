lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include? lib

require "kraut/version"

Gem::Specification.new do |s|
  s.name = "kraut"
  s.version = Kraut::VERSION
  s.authors = ["Daniel Harrington", "Thilko Richter"]
  s.email = "blaulabs@blau.de"
  s.homepage = "http://github.com/blaulabs/#{s.name}"
  s.summary = "Crowd Interface"
  s.description = "Interface for the Atlassian Crowd SOAP API"

  s.rubyforge_project = s.name

  s.add_dependency "savon", ">= 0.8.2"
  s.add_dependency "nori", "~> 0.2.4"

  s.add_development_dependency "ci_reporter", "~> 1.6.5"
  s.add_development_dependency "rspec", "~> 2.5.0"
  s.add_development_dependency "autotest", "~> 4.4.2"
  s.add_development_dependency "mocha", "~> 0.9.9"
  s.add_development_dependency "webmock", "~> 1.3.5"
  s.add_development_dependency "savon_spec", "~> 0.1.6"
  s.add_development_dependency "rake", "0.8.7"
  s.add_development_dependency "rails", "3.0.7"
  s.add_development_dependency "rspec-rails", "~> 2.5.0"
  s.add_development_dependency "haml", "~> 3.0"

  # ZenTest 4.6 requires RubyGems version ~> 1.8 [dh, 2011-08-19]
  s.add_development_dependency "ZenTest", "4.5.0"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
