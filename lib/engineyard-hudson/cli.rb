require 'thor'

module Engineyard
  module Hudson
    class CLI < Thor
      map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help
      
      desc "version", "show version information"
      def version
        shell.say Engineyard::Hudson::VERSION
      end
    end
  end
end