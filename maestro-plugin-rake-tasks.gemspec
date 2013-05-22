# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'maestro/plugin/rake_tasks/version'

Gem::Specification.new do |spec|
  spec.name          = 'maestro-plugin-rake-tasks'
  spec.version       = Maestro::Plugin::RakeTasks::VERSION
  spec.authors       = ['Etienne Pelletier']
  spec.email         = ['epelletier@maestrodev.com']
  spec.description   = %q{A collection of Rake tasks used to package Maetro Ruby plugins}
  spec.summary       = %q{A collection of Rake tasks used to package Maetro Ruby plugins}
  spec.homepage      = 'https://github.com/maestrodev/maestro-plugin-rake-tasks'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rake', '~>0.9.2'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'git'
  spec.add_dependency 'zippy'

end
