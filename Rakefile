require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task default: [:spec, :rubocop]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = %w(lib/**/*.rb spec/**/*.rb)
end

