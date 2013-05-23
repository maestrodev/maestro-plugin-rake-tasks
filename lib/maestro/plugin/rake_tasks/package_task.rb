require 'maestro/plugin/rake_tasks/version'
require 'rake'
require 'rake/tasklib'
require 'zippy'
require 'git'
require 'nokogiri'
require 'json'


module Maestro
  module Plugin
    module RakeTasks
      class PackageTask < ::Rake::TaskLib
        include ::Rake::DSL if defined?(::Rake::DSL)

        # Use verbose output. If this is set to true, the task will print the
        # progress output to stdout.
        #
        # default:
        #   true
        attr_accessor :verbose

        # List the directories to package
        # default:
        #   [ 'src', 'vendor', 'images' ]
        attr_accessor :directories

        # List the files to package
        # default:
        #   [ 'manifest.json', 'README.md', 'LICENSE' ]
        attr_accessor :files

        # Tells the task to read version and plugin name from a pom.xml file
        # default:
        #   true
        attr_accessor :use_pom

        # The path to the pom.xml
        # default:
        #   './pom.xml'
        attr_accessor :pom_path

        # The path to the manifest template
        # default:
        #   './manifest.template.json'
        attr_accessor  :manifest_template_path

        # The plugin version
        # default read from pom.xml (version)
        attr_accessor :version

        # The plugin name
        # default read from pom.xml (artifactId)
        attr_accessor :plugin_name

        # The destination directory
        # default:
        #   .
        attr_accessor :dest_dir

        # Name of task.
        #
        # default:
        #   :package
        attr_accessor :name

        def initialize(*args, &task_block)
          setup_ivars(args)

          desc "Package a Maestro Ruby plugin into a Zip file" unless ::Rake.application.last_comment

          task name, *args do |_, task_args|
            RakeFileUtils.send(:verbose, verbose) do
              task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
              run_task verbose
            end
          end
        end

        def setup_ivars(args)
          @name = args.shift || :package
          @verbose, @use_pom = true, true
          @directories = [ 'src', 'vendor', 'images' ]
          @files = [ 'manifest.json', 'README.md', 'LICENSE' ]
          @version, @plugin_name = nil, nil
          @dest_dir = '.'
          @pom_path = './pom.xml'
          @manifest_template_path = './manifest.template.json'
        end

        def run_task(verbose)
          parse_pom if @use_pom

          # Make sure we have a valid name and version
          abort "ERROR: Plugin name is missing" unless @plugin_name
          abort "ERROR: Plugin version is missing" unless @version

          # Add the commit hash to the version if it's available
          git_version! if File.exists?('.git')

          # If we use a template, use it to create the manifest
          update_manifest if File.exists?(@manifest_template_path)

          # Create the zip file
          create_zip_file("#{@plugin_name}-#{@version}.zip")

        end

        private

        def parse_pom
          pom = File.open(@pom_path)
          doc = Nokogiri::XML(pom.read)
          pom.close
          @plugin_name ||= doc.at_xpath('/xmlns:project/xmlns:artifactId').text
          @version ||= doc.at_xpath('/xmlns:project/xmlns:version').text
        end

        def git_version!
          git = Git.open('.')
          # check if there are modified files
          if git.status.select { |s| s.type == 'M' }.empty?
            commit = git.log.first.sha[0..5]
            @version = "#{@version}-#{commit}"
          else
            warn "WARNING: There are modified files, not using commit hash in version"
          end
          @version
        end

        # update the version number in the manifest file.
        def update_manifest
          manifest = JSON.parse(IO.read(@manifest_template_path))
          if manifest.instance_of? Array
            manifest.each { |m| m['version'] = @version }
          else
            manifest['version'] = @version
          end

          File.open('manifest.json','w'){ |f| f.write(JSON.pretty_generate(manifest)) }
        end

        def create_zip_file(zip_file)
          Zippy.create zip_file do |z|
            @directories.each { |dir| add_dir z, dir }
            @files.each { |file| add_file z, file }
          end
        end

        # add a file to the zip file
        def add_file( zippyfile, f )
          puts "Writing #{f} at #{@dest_dir}"  if verbose
          zippyfile["#{@dest_dir}/#{f}"] = File.open(f)
        end

        # add a directory to the zip file
        def add_dir( zippyfile, d )
          glob = "#{d}/**/*"
          FileList.new( glob ).each { |f|
            if (File.file?(f))
              add_file zippyfile, f
            end
          }
        end

      end

    end
  end
end
