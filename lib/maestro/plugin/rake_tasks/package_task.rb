require 'maestro/plugin/rake_tasks/version'
require 'maestro/plugin/rake_tasks/pom'
require 'rake'
require 'rake/tasklib'
require 'zip'
require 'git'
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

          # If we use a template, use it to create the manifest
          update_manifest(git_version)

          # Create the zip file
          create_zip_file("#{@plugin_name}-#{@version}.zip")

        end

        private

        def parse_pom
          pom = Pom.new(@pom_path)
          @plugin_name ||= pom.artifact_id
          @version ||= pom.version
        end

        def git_version
          return @version unless Dir.exists?(".git")
          git = Git.open('.')
          # check if there are modified files
          if git.status.select { |s| s.type == 'M' }.empty?
            commit = git.log.first.sha[0..5]
            "#{@version}-#{commit}"
          else
            warn "WARNING: There are modified files, not using commit hash in version"
            @version
          end
        end

        # update the version number in the manifest file.
        def update_manifest(manifest_version)
          manifest = JSON.parse(IO.read(@manifest_template_path))
          if manifest.instance_of? Array
            manifest.each { |m| m['version'] = manifest_version }
          else
            manifest['version'] = manifest_version
            if !manifest['tasks'].nil? and manifest['tasks'].instance_of? Array
              manifest['tasks'].each { |m| m['version'] = manifest_version }
            end
          end

          File.open('manifest.json','w'){ |f| f.write(JSON.pretty_generate(manifest)) }
        end

        def create_zip_file(zip_file)
          Zip::File.open(zip_file, Zip::File::CREATE) do |z|
            @directories.each { |dir| add_dir z, dir }
            @files.each { |file| add_file z, file }
          end
        end

        # add a file to the zip file
        def add_file( zipfile, f )
          if File.exists?(f)
            puts "Writing #{f} at #{@dest_dir}" if verbose
            zipfile.add(f, "#{@dest_dir}/#{f}")
          else
            puts "Ignoring missing file #{f} at #{@dest_dir}"
          end
        end

        # add a directory to the zip file
        def add_dir( zipfile, d )
          FileList.new("#{d}/**/*").each { |f| add_file(zipfile, f) if File.file?(f) }
        end

      end

    end
  end
end
