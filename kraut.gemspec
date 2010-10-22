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
  s.description = "Interface for Atlassian Crowd"

  s.rubyforge_project = s.name

#  s.add_dependency "savon", "~> 0.7.9"
  s.add_development_dependency "ci_reporter", "~> 1.6.3"
  s.add_development_dependency "rspec", "~> 2.0.0"
  s.add_development_dependency "mocha", "~> 0.9.8"
  s.add_development_dependency "webmock", "~> 1.3.5"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
