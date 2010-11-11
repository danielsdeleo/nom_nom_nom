require 'bundler/setup'

require 'rspec/core/rake_task'

task :default => :spec

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w|-cbfs|
  t.pattern = 'spec/**/*_spec.rb'
end
