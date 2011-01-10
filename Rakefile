require "rake"

require "rspec/core/rake_task"
require "ci/reporter/rake/rspec"

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fd -c)
end

task :default => %w(ci:setup:rspec spec)
