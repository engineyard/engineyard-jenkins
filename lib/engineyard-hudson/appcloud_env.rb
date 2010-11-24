require "engineyard"
require "engineyard/thor"
require "engineyard/cli"
require "engineyard/cli/ui"
require "engineyard/error"
module Engineyard
  module Hudson
    class AppcloudEnv
      include EY::UtilityMethods
      
      # Returns [environment, account] based on current .eyrc credentials and/or CLI options
      # Returns [nil, nil] if no unique environment can be selected
      def find_environments(options = {})
        Thor::Base.shell = EY::CLI::UI
        EY.ui = EY::CLI::UI.new
        query_environments = options[:environment] ? [options[:environment]] : default_query_environments
        query_environments.inject([]) do |envs, env_name|
          begin
            if application = fetch_environment(env_name, options[:account])
              envs << [env_name, application.account.name]
            end
          rescue EY::NoEnvironmentError
          rescue EY::MultipleMatchesError => e
            # e.message looks something like:
            # Multiple environments possible, please be more specific:
            # 
            #   hudson # ey <command> --environment='hudson' --account='drnic-demo'
            #   hudson # ey <command> --environment='hudson' --account='rails-hudson'
            e.message.scan(/--environment='([^']+)' --account='([^']+)'/) do
              envs << [$1, $2]
            end
          end
          envs
        end
      end
      
      def default_query_environments
        %w[hudson hudson_server hudson_production hudson_server_production]
      end
    end
  end
end