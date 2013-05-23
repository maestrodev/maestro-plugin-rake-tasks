module Maestro
  module Plugin
    module RakeTasks
      class BundleTask < ::Rake::TaskLib
        include ::Rake::DSL if defined?(::Rake::DSL)

        # Depedency groups to omit
        # default:
        #   [ 'development', 'test' ]
        attr_accessor :without_groups

        # Name of task.
        #
        # default:
        #   :bundle
        attr_accessor :name

        def initialize(*args, &task_block)
          setup_ivars(args)

          desc 'Update the dependencies' unless ::Rake.application.last_comment

          task name, *args do |_, task_args|
            RakeFileUtils.send(:verbose, verbose) do
              task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
              run_task verbose
            end
          end
        end

        def setup_ivars(args)
          @name = args.shift || :bundle
          @without_groups = [ 'development', 'test' ]
        end

        def run_task(verbose)
          sh "bundle install --without #{@without_groups.join(' ')}" do |ok, res|
            raise 'Error bundling' if ! ok
          end
          sh 'bundle package' do |ok, res|
            raise 'Error bundling' if ! ok
          end
        end
      end
    end
  end
end
