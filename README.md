# Maestro::Plugin::Rake::Tasks

This gem is used to help with the packaging of Maestro Ruby plugins. It provides tasks that can be instantiated and
used as part of a Rakefile.

## Installation

Add this line to your application's Gemfile:

    gem 'maestro-plugin-rake-tasks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maestro-plugin-rake-tasks

## Usage

### Bundle Task

This task is used to update the gem dependencies in the vendor/cache directory. It omits the development and test
dependency groups before calling the *bundle update* command. Groups to be omitted can be specified with the
without_groups parameter.

Default example:

```
Maestro::Plugin::RakeTasks::BundleTask.new
```

Invoke like so

    $ rake bundle

Example overriding the dependency groups to be omitted:

```
Maestro::Plugin::RakeTasks::BundleTask.new do |t|
  t.without_groups= [ 'development' ]
end
```

The following attributes can be configured:

* without_groups: an array of dependency groups to omit from the bundle.

### Package Task

This task is used to package the plugin in a zip file. The basic usage assumes that you have a Maven POM file (pom.xml)
containing the plugin name (artifactId) and version. If you do not have a pom.xml, you can specify the values in the
Rakefile when configuring the PackageTask. You also must have a manifest template which contains a placeholder for the
version which will be replaced by the package task.

Example using all defaults and a pom.xml:

```
Maestro::Plugin::RakeTasks::PackageTask.new
```

Invoke like so:

    $ rake package

Example overriding some values:

```
Maestro::Plugin::RakeTasks::PackageTask.new do |t|
  t.verbose=false
  t.version='1.2.3'
  t.plugin_name='my-fancy-maestro-plugin'
end
```

The following attributes can be configured:

* verbose: enable/disable verbose output. Default: true
* directories: an array of directories to package. Defaults: src, vendor, images.
* files: an array of files to package. Defaults: manifest.json, README.md, LICENSE
* use_pom: read plugin name and version from the pom. Default: true
* pom_path: path to the pom file. Default: ./pom.xml
* manifest_template_path: path to the manifest template. Default: ./manifest.template.json
* version: the plugin version. Defaults to the value defined in the pom.xml. Required if you are not using a pom.xml.
* plugin_name: the plugin name. Defaults to the value defined in the pom.xml. Required if you are not using a pom.xml.
* dest_dir: the destination directory of the zip file. Default: .

## Example Rakefile

The following is an example Rakefile that can be used to build and test most Maestro Ruby plugins.

```
require 'rake/clean'
require 'maestro/plugin/rake_tasks'
require 'rspec/core/rake_task'

$:.push File.expand_path("../src", __FILE__)

CLEAN.include("manifest.json", "*-plugin-*.zip", "vendor", "package", "tmp", ".bundle")

task :default => :all
task :all => [:clean, :bundle, :spec, :package]

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = "--format p --color"
end

Maestro::Plugin::RakeTasks::BundleTask.new

Maestro::Plugin::RakeTasks::PackageTask.new
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
