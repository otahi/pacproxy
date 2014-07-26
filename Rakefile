require 'bundler/gem_tasks'
require 'rubocop/rake_task'

task default: [:rubocop]

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = %w(lib/**/*.rb spec/**/*.rb)
end
