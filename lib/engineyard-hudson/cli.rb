require 'thor'

module Engineyard
  module Hudson
    class CLI < Thor
      map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help
      
      desc "server", "Setup a Hudson CI server on AppCloud"
      method_option :environment, :type => :string, :aliases => %w(-e),
        :desc => "Environment in which to deploy this application", :required => true
      method_option :account, :type => :string, :aliases => %w(-c),
        :desc => "Name of the account you want to deploy in"
      def server
        
      end
      
      desc "version", "show version information"
      def version
        shell.say Engineyard::Hudson::VERSION
      end
    end
  end
end