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

        # The plugin version
        # default read from pom.xml (version)
        attr_accessor :version

        # The plugin name
        # default read from pom.xml (artifactId)
        attr_accessor :plugin_name

        # The zip file name
        # default: plugin_name + '_' + version + '.zip'
        attr_accessor :zip_file

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
          @verbose = true
          @directories = [ 'src', 'vendor', 'images' ]
          @files = [ 'manifest.json', 'README.md', 'LICENSE' ]
          pom = File.open('pom.xml')
          doc = Nokogiri::XML(pom.read)
          pom.close
          @plugin_name = doc.at_xpath('/xmlns:project/xmlns:artifactId').text
          file_version = doc.at_xpath('/xmlns:project/xmlns:version').text
          @zip_file = "#{@plugin_name}-#{file_version}.zip"
          @version = File.exists?('.git') ? git_version(file_version) : file_version
        end

        def run_task(verbose)
          update_manifest

          Zippy.create zip_file do |z|
            @directories.each { |dir| add_dir z, '.', dir }
            @files.each { |file| add_file z, '.', file}
          end

        end

        private

        def git_version(version)
          git = Git.open('.')
          # check if there are modified files
          if git.status.select { |s| s.type == 'M' }.empty?
            commit = git.log.first.sha[0..5]
            version = "#{version}-#{commit}"
          else
            puts "WARNING: There are modified files, not using commit hash in version"
          end
          version
        end


        def update_manifest
          # update manifest
          manifest = JSON.parse(IO.read('manifest.template.json'))
          manifest.each { |m| m['version'] = @version }
          File.open('manifest.json','w'){ |f| f.write(JSON.pretty_generate(manifest)) }
        end

        def add_file( zippyfile, dst_dir, f )
          puts "Writing #{f} at #{dst_dir}"  if verbose
          zippyfile["#{dst_dir}/#{f}"] = File.open(f)
        end

        def add_dir( zippyfile, dst_dir, d )
          glob = "#{d}/**/*"
          FileList.new( glob ).each { |f|
            if (File.file?(f))
              add_file zippyfile, dst_dir, f
            end
          }
        end

      end

    end
  end
end
