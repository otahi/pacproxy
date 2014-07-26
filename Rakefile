require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'

task default: [:spec, 'coveralls:push', :rubocop]

Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = %w(lib/**/*.rb spec/**/*.rb)
end
