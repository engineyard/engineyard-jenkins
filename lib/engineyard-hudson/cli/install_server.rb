require 'thor/group'

module Engineyard
  module Hudson
    class InstallServer < Thor::Group
      include Thor::Actions
      
      class_option :plugins, :aliases => '-p', :desc => 'additional Hudson CI plugins (comma separated)'
      
      def self.source_root
        File.join(File.dirname(__FILE__), "install_server", "templates")
      end
      
      def cookbooks
        directory "cookbooks"
      end
      
      def attributes
        @plugins = %w[git github rake ruby greenballs envfile] + (options[:plugins] || '').strip.split(/\s*,\s*/)
        template "attributes.rb.tt", "cookbooks/hudson_master/attributes/default.rb"
      end
      
    end
  end
end
