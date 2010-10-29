require 'thor'

module Engineyard
  module Hudson
    class CLI < Thor

      map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help
    end
  end
end