require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rake/clean'

CLEAN.include('pkg', 'manifest.json', '*.zip')
CLOBBER.include('.bundle', '.config', 'coverage', 'InstalledFiles', 'spec/reports', 'rdoc', 'test', 'tmp')

task :default => [:clean, :spec, :cucumber, :build]

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new
