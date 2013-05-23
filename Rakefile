require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'rake/clean'

CLEAN.include('pkg', 'manifest.json', '*.zip')
CLOBBER.include('.bundle', '.config', 'coverage', 'InstalledFiles', 'spec/reports', 'rdoc', 'test', 'tmp')

task :default => [:clean, :bundle, :spec, :build]

RSpec::Core::RakeTask.new


