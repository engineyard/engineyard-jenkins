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
          say "No environments with name hudson, hudson_server, hudson_production, hudson_server_production.", :red
          say "Either:"
          say "  * Create an AppCloud environment called hudson, hudson_server, hudson_production, hudson_server_production"
          say "  * Use --environment/--account flags to select AppCloud environment"
          return
        elsif environments.size > 1
          say "Multiple environments possible, please be more specific:", :red
          say ""
          environments.each do |env_name, account_name, environment|
            say "  ey-hudson install_server --environment "; say "'#{env_name}' ", :yellow; say "--account "; 
              say "'#{account_name}'", :yellow
          end
          return
        end
        
        env_name, account_name, environment = environments.first
        public_hostname, status = environment.instances.first.public_hostname, environment.instances.first.status
        
        temp_project_path = File.expand_path(project_path || File.join(Dir.tmpdir, "temp_hudson_server"))
        shell.say "Temp installation dir: #{temp_project_path}" if options[:verbose]
        FileUtils.mkdir_p(temp_project_path)
        FileUtils.chdir(FileUtils.mkdir_p(temp_project_path)) do
          require 'engineyard-hudson/cli/install_server'
          Engineyard::Hudson::InstallServer.start(ARGV.unshift(temp_project_path))

          require 'engineyard/cli/recipes'
          say ""
          say "Uploading to "; say "'#{env_name}' ", :yellow; say "environment on "; say "'#{account_name}' ", :yellow; say "account..."
          environment.upload_recipes
          
          if status == "running"
            environment.run_custom_recipes
            say "Environment is rebuilding..."
            waiting = true
            while waiting
              begin
                Net::HTTP.start(public_hostname, 80) do |http|
                  waiting = http.get("/").body !~ /Please wait while Hudson is getting ready to work/
                end
              rescue Exception
              end
              sleep 1; print '.'; $stdout.flush
            end
            say ""
            say "Hudson is starting..."
            Net::HTTP.start(public_hostname, 80) do |http|
              while http.get("/").body =~ /Please wait while Hudson is getting ready to work/
                sleep 1; print '.'; $stdout.flush
              end
            end
            say ""
            say "Done! Hudson at "; say "http://#{public_hostname}", :green
          else
            # TODO untested
            require "ruby-debug"
            debugger
            say ""
            say "* Boot your environment via https://cloud.engineyard.com", :yellow
            say "* Hudson CI will be at http://#{public_hostname}"
          end
          say ""
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