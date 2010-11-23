require 'thor'
require 'engineyard-hudson/thor-ext/actions/directory'

module Engineyard
  module Hudson
    class CLI < Thor

      desc "install PROJECT_PATH", "Install Hudson node/slave recipes into your project."
      def install(project_path)
        require 'engineyard-hudson/cli/install'
        Engineyard::Hudson::Install.start(ARGV[1..-1])
      end
      
      desc "install_server [PROJECT_PATH]", "Install Hudson CI into an AppCloud environment."
      method_option :verbose, :aliases => ["-V"], :desc => "Display more output"
      def install_server(project_path=nil)
        temp_project_path = File.expand_path(project_path || File.join(Dir.tmpdir, "temp_hudson_server"))
        shell.say "Temp installation dir: #{temp_project_path}" if options[:verbose]
        FileUtils.mkdir_p(temp_project_path)
        FileUtils.chdir(FileUtils.mkdir_p(temp_project_path)) do
          require 'engineyard-hudson/cli/install_server'
          Engineyard::Hudson::InstallServer.start(ARGV.unshift(temp_project_path))
        end
      end
      
      desc "version", "show version information"
      def version
        require 'engineyard-hudson/version'
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