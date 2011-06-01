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

  s.add_development_dependency "ci_reporter", "~> 1.6.4"
  s.add_development_dependency "rspec", "~> 2.3.0"  # ci_reporter does not like rspec 2.4 [dh, 2010-01-10]
  s.add_development_dependency "autotest", "~> 4.4.2"
  s.add_development_dependency "mocha", "~> 0.9.9"
  s.add_development_dependency "webmock", "~> 1.3.5"
  s.add_development_dependency "savon_spec", "~> 0.1.6"
  s.add_development_dependency "rake", "0.8.7"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
