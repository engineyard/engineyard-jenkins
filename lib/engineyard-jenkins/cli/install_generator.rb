require 'thor/group'

module Engineyard
  module Jenkins
    class InstallGenerator < Thor::Group
      include Thor::Actions
      
      argument :project_path
      argument :host
      argument :port
      argument :public_key
      
      def self.source_root
        File.join(File.dirname(__FILE__), "install_generator", "templates")
      end
      
      def install_cookbooks
        file       = "cookbooks/main/recipes/default.rb"
        unless File.exists?(File.join(destination_root, "cookbooks/main/recipes/default.rb"))
          directory "cookbooks"
        end
      end
      
      def attributes
        template "attributes.rb.tt", "cookbooks/jenkins_slave/attributes/default.rb"
      end
      
      def recipe
        copy_file "recipes.rb", "cookbooks/jenkins_slave/recipes/default.rb"
      end
      
      def enable_recipe
        file       = "cookbooks/main/recipes/default.rb"
        enable_cmd = "\nrequire_recipe 'jenkins_slave'"
        if File.exists?(file_path = File.join(destination_root, file))
          append_file file, enable_cmd
        else
          create_file file, enable_cmd
        end
      end
      
      def readme
        say ""
        say "Finally:"
        say "* edit "; say "cookbooks/jenkins_slave/attributes/default.rb ", :yellow; say "as necessary."
        say "* run: "; say "ey recipes upload ", :green; say "# use --environment(-e) & --account(-c)"
        say "* run: "; say "ey recipes apply  ", :green; say "#   to select environment"
        say "* "; say "Boot your environment ", :yellow; say "if not already booted."
        say "When the recipe completes, your project will commence its first build on Jenkins CI."
      end
      
      private
      def say(msg, color = nil)
        color ? shell.say(msg, color) : shell.say(msg)
      end
    end
  end
end
