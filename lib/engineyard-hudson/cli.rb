require 'thor'
require 'engineyard-hudson/thor-ext/actions/directory'
require 'engineyard-hudson/appcloud_env'

module Engineyard
  module Hudson
    class CLI < Thor

      desc "install PROJECT_PATH", "Install Hudson node/slave recipes into your project."
      def install(project_path)
        require 'engineyard-hudson/cli/install'
        Engineyard::Hudson::Install.start(project_path)
      end
      
      desc "install_server [PROJECT_PATH]", "Install Hudson CI into an AppCloud environment."
      method_option :verbose, :aliases     => ["-V"], :desc => "Display more output"
      method_option :environment, :aliases => ["-e"], :desc => "Environment in which to deploy this application", :type => :string
      method_option :account, :aliases     => ["-c"], :desc => "Name of the account you want to deploy in"
      # Generates a chef recipe cookbook, uploads it to AppCloud, and waits until Hudson CI has launched
      def install_server(project_path=nil)
        environments = Engineyard::Hudson::AppcloudEnv.new.find_environments(options)
        if environments.size == 0
          no_environments_discovered and return
        elsif environments.size > 1
          too_many_environments_discovered(environments) and return
        end
        
        env_name, account_name, environment = environments.first
        if environment.instances.first
          public_hostname = environment.instances.first.public_hostname
          status          = environment.instances.first.status
        end
        
        temp_project_path = File.expand_path(project_path || File.join(Dir.tmpdir, "temp_hudson_server"))
        shell.say "Temp installation dir: #{temp_project_path}" if options[:verbose]
        
        FileUtils.mkdir_p(temp_project_path)
        FileUtils.chdir(FileUtils.mkdir_p(temp_project_path)) do
          # 'install_server' generator
          require 'engineyard-hudson/cli/install_server'
          Engineyard::Hudson::InstallServer.start(ARGV.unshift(temp_project_path))

          say ""
          say "Uploading to "; say "'#{env_name}' ", :yellow; say "environment on "; say "'#{account_name}' ", :yellow; say "account..."
          require 'engineyard/cli/recipes'
          environment.upload_recipes
          
          if status == "running"
            say "Environment is rebuilding..."
            environment.run_custom_recipes
            watch_page_while public_hostname, 80, "/" do |req|
              req.body !~ /Please wait while Hudson is getting ready to work/
            end

            say ""
            say "Hudson is starting..."
            watch_page_while public_hostname, 80, "/" do |req|
              req.body =~ /Please wait while Hudson is getting ready to work/
            end
            
            require 'hudson'
            require 'hudson/config'
            ::Hudson::Config.config["base_uri"] = public_hostname
            ::Hudson::Config.store!
            
            say ""
            say "Done! Hudson CI hosted at "; say "http://#{public_hostname}", :green
          else
            say ""
            say "Almost there..."
            say "* Boot your environment via https://cloud.engineyard.com", :yellow
          end
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
      
      def no_environments_discovered
        say "No environments with name hudson, hudson_server, hudson_production, hudson_server_production.", :red
        say "Either:"
        say "  * Create an AppCloud environment called hudson, hudson_server, hudson_production, hudson_server_production"
        say "  * Use --environment/--account flags to select AppCloud environment"
      end
      
      def too_many_environments_discovered(environments)
        say "Multiple environments possible, please be more specific:", :red
        say ""
        environments.each do |env_name, account_name, environment|
          say "  ey-hudson install_server --environment "; say "'#{env_name}' ", :yellow; 
            say "--account "; say "'#{account_name}'", :yellow
        end
      end
      
      def watch_page_while(host, port, path)
        waiting = true
        while waiting
          begin
            Net::HTTP.start(host, port) do |http|
              req = http.get(path)
              waiting = yield req
            end
            sleep 1; print '.'; $stdout.flush
          rescue SocketError => e
            sleep 1; print 'x'; $stdout.flush
          rescue Exception => e
            puts e.message
            sleep 1; print '.'; $stdout.flush
          end
        end
      end
    end
  end
end
