require 'thor'
require 'engineyard-hudson/thor-ext/actions/directory'

module Engineyard
  module Hudson
    class CLI < Thor

      def self.common_options
        method_option :environment, :type => :string, :aliases => %w(-e), 
          :desc => "Environment in which to deploy this application", :required => true
        method_option :account, :type => :string, :aliases => %w(-c), 
          :desc => "Name of the account you want to deploy in"
      end
      
      desc "install PROJECT_PATH", "Install Hudson node/slave recipes into your project."
      def install(project_path)
        require 'engineyard-hudson/cli/install'
        Engineyard::Hudson::Install.start(ARGV[1..-1])
      end
      
      desc "server PROJECT_PATH", "Setup a Hudson CI server on AppCloud."
      def server(project_path)
        require 'engineyard-hudson/cli/server'
        Engineyard::Hudson::Server.start(ARGV[1..-1])
      end
      
      desc "version", "show version information"
      def version
        shell.say Engineyard::Hudson::VERSION
      end

      map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

      private
      def display(text)
        shell.say text
        exit
      end

      def error(text)
        shell.say "ERROR: #{text}", :red
        exit
      end
    end
  end
end