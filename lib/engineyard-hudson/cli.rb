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
        shell.say "Coming soon!", :green
      end
      
      desc "version", "show version information"
      def version
        shell.say Engineyard::Hudson::VERSION
      end

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