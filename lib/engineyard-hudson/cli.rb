require 'thor'
require 'engineyard-hudson/thor-ext/actions/directory'
require 'engineyard-hudson/appcloud_env'

module Engineyard
  module Hudson
    class CLI < Thor

      desc "install PROJECT_PATH", "Install Hudson node/slave recipes into your project."
      def install(project_path)
        require 'engineyard-hudson/cli/install'
        Engineyard::Hudson::Install.start(ARGV[1..-1])
      end
      
      desc "install_server [PROJECT_PATH]", "Install Hudson CI into an AppCloud environment."
      method_option :verbose, :aliases     => ["-V"], :desc => "Display more output"
      method_option :environment, :aliases => ["-e"], :desc => "Environment in which to deploy this application", :type => :string
      method_option :account, :aliases     => ["-c"], :desc => "Name of the account you want to deploy in"
      def install_server(project_path=nil)
        environments = Engineyard::Hudson::AppcloudEnv.new.find_environments(options)
        if environments.size == 0
          error "No environments with name hudson, hudson_server, hudson_production, hudson_server_production"
        elsif environments.size > 1
          say "Multiple environments possible, please be more specific:", :red
          say ""
          environments.each do |env_name, account_name|
            say "  ey-hudson install_server --environment "; say "'#{env_name}' ", :yellow; say "--account "; 
              say "'#{account_name}'", :yellow
          end
          return
        end
        environment, account = environments.first
        temp_project_path = File.expand_path(project_path || File.join(Dir.tmpdir, "temp_hudson_server"))
        shell.say "Temp installation dir: #{temp_project_path}" if options[:verbose]
        FileUtils.mkdir_p(temp_project_path)
        FileUtils.chdir(FileUtils.mkdir_p(temp_project_path)) do
          require 'engineyard-hudson/cli/install_server'
          Engineyard::Hudson::InstallServer.start(ARGV.unshift(temp_project_path))

          say ""
          say "Uploading to '#{environment}' environment on '#{account}' account..."
          say "Applying to '#{environment}' environment on '#{account}' account..."
          say ""
          say "* Boot your environment if not already booted.", :yellow
          say "You are now hosting a Hudson CI!"
        end
      end
      
      desc "version", "show version information"
      def version
        require 'engineyard-hudson/version'
        shell.say Engineyard::Hudson::VERSION
      end

      map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

      private
      def say(msg, color = nil)
        color ? shell.say(msg, color) : shell.say(msg)
      end

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