require 'thor'
require 'engineyard-jenkins/thor-ext/actions/directory'
require 'engineyard-jenkins/appcloud_env'

module Engineyard
  module Jenkins
    class CLI < Thor

      desc "install PROJECT_PATH", "Install Jenkins node/slave recipes into your project."
      method_option :host, :aliases => ['-h'], :desc => "Override Jenkins CI server host"
      method_option :port, :aliases => ['-p'], :desc => "Override Jenkins CI server port"
      def install(project_path)
        host, port = host_port(options)
        unless host && port
          say "USAGE: ey-jenkins install . --host HOST --port PORT", :red
          say ""
          say "HOST:PORT default to current jenkins CLI host (set by 'jenkins list --host HOST')"
        else
        
        
          require 'engineyard-jenkins/cli/install_generator'
          Engineyard::Jenkins::InstallGenerator.start(ARGV.unshift(project_path, host, port))
        end
      end
      
      desc "install_server [PROJECT_PATH]", "Install Jenkins CI into an AppCloud environment."
      method_option :verbose, :aliases     => ["-V"], :desc => "Display more output"
      method_option :environment, :aliases => ["-e"], :desc => "Environment in which to deploy this application", :type => :string
      method_option :account, :aliases     => ["-c"], :desc => "Name of the account you want to deploy in"
      # Generates a chef recipe cookbook, uploads it to AppCloud, and waits until Jenkins CI has launched
      def install_server(project_path=nil)
        environments = Engineyard::Jenkins::AppcloudEnv.new.find_environments(options)
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
        
        temp_project_path = File.expand_path(project_path || File.join(Dir.tmpdir, "temp_jenkins_server"))
        shell.say "Temp installation dir: #{temp_project_path}" if options[:verbose]
        
        FileUtils.mkdir_p(temp_project_path)
        FileUtils.chdir(temp_project_path) do
          # 'install_server' generator
          require 'engineyard-jenkins/cli/install_server_generator'
          Engineyard::Jenkins::InstallServerGenerator.start(ARGV.unshift(temp_project_path))

          say ""
          say "Uploading to "; say "'#{env_name}' ", :yellow; say "environment on "; say "'#{account_name}' ", :yellow; say "account..."
          require 'engineyard/cli/recipes'
          environment.upload_recipes
          
          if status == "running" || status == "error"
            say "Environment is rebuilding..."
            environment.run_custom_recipes
            watch_page_while public_hostname, 80, "/" do |req|
              req.body !~ /Please wait while Jenkins is getting ready to work/
            end

            say ""
            say "Jenkins is starting..."
            watch_page_while public_hostname, 80, "/" do |req|
              req.body =~ /Please wait while Jenkins is getting ready to work/
            end
            
            require 'jenkins'
            require 'jenkins/config'
            ::Jenkins::Config.config["base_uri"] = public_hostname
            ::Jenkins::Config.store!
            
            say ""
            say "Done! Jenkins CI hosted at "; say "http://#{public_hostname}", :green
          else
            say ""
            say "Almost there..."
            say "* Boot your environment via https://cloud.engineyard.com", :yellow
          end
        end
      end
      
      desc "version", "show version information"
      def version
        require 'engineyard-jenkins/version'
        shell.say Engineyard::Jenkins::VERSION
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
      
      # Returns the [host, port] for the target Jenkins CI server
      def host_port(options)
        host = options["host"]
        port = options["port"] || '80'
        [host, port]
      end
      
      def no_environments_discovered
        say "No environments with name jenkins, jenkins_server, jenkins_production, jenkins_server_production.", :red
        say "Either:"
        say "  * Create an AppCloud environment called jenkins, jenkins_server, jenkins_production, jenkins_server_production"
        say "  * Use --environment/--account flags to select AppCloud environment"
      end
      
      def too_many_environments_discovered(environments)
        say "Multiple environments possible, please be more specific:", :red
        say ""
        environments.each do |env_name, account_name, environment|
          say "  ey-jenkins install_server --environment "; say "'#{env_name}' ", :yellow; 
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
