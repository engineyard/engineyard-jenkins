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
            if environment = fetch_environment(env_name, options[:account])
              clean_host_name(environment)
              envs << [env_name, environment.account.name, environment]
            end
          rescue EY::NoEnvironmentError
          rescue EY::MultipleMatchesError => e
            # e.message looks something like:
            # Multiple environments possible, please be more specific:
            # 
            #   hudson # ey <command> --environment='hudson' --account='drnic-demo'
            #   hudson # ey <command> --environment='hudson' --account='rails-hudson'
            e.message.scan(/--environment='([^']+)' --account='([^']+)'/) do
              envs << [$1, $2, nil]
            end
          end
          envs
        end
      end
      
      def default_query_environments
        %w[hudson hudson_server hudson_production hudson_server_production]
      end
      
      # Currently the engineyard gem has badly formed URLs in its same data
      # This method cleans app_master_hostname.compute-1.amazonaws.com -> app-master-hostname.compute-1.amazonaws.com
      def clean_host_name(environment)
        environment.instances.first.public_hostname.gsub!(/_/,'-') if environment.instances.first
      end
    end
  end
end