require 'thor/group'

module Engineyard
  module Hudson
    class Install < Thor::Group
      include Thor::Actions
      
      argument :project_path
      
      def self.source_root
        File.join(File.dirname(__FILE__), "install", "templates")
      end
      
      def attributes
        template "attributes.rb.erb", "cookbooks/hudson_slave/attributes/default.rb"
      end
      
      def recipe
        copy_file "recipes.rb", "cookbooks/hudson_slave/recipes/default.rb"
      end
      
      def enable_recipe
        file       = "cookbooks/main/recipes/default.rb"
        enable_cmd = "\nrequire_recipe 'hudson_slave'"
        if File.exists?(file_path = File.join(destination_root, file))
          if File.read(file_path).index(enable_cmd)
            say "        skip  ", :blue; say file
          else
            append_file file, enable_cmd
          end
        else
          create_file file, enable_cmd
        end
      end
      
      def readme
        shell.say ""
        shell.say "Finally, edit "; shell.say "cookbooks/hudson_slave/attributes/default.rb", :green
      end
    end
  end
end
