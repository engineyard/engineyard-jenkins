require 'thor/group'

module Engineyard
  module Hudson
    class Server < Thor::Group
      include Thor::Actions
      
      class_option :plugins, :aliases => '-p', :desc => 'additional Hudson CI plugins (comma separated)'
      
      def self.source_root
        File.join(File.dirname(__FILE__), "server", "templates")
      end
      
      def cookbooks
        directory "cookbooks"
      end
      
      def attributes
        @plugins = %w[git github rake ruby greenballs] + (options[:plugins] || '').strip.split(/\s*,\s*/)
        template "attributes.rb.tt", "cookbooks/hudson_master/attributes/default.rb"
      end
      
      def readme
        say ""
        say "Finally:"
        say "* edit "; say "cookbooks/hudson_master/attributes/default.rb ", :yellow; say "as necessary."
        say "* run: "; say "ey recipes upload ", :green; say "# use --environment(-e) & --account(-c)"
        say "* run: "; say "ey recipes apply  ", :green; say "#   to select environment"
        say "* "; say "Boot your environment ", :yellow; say "if not already booted."
        say "When the recipe completes, your solo instance will host a Hudson CI!"
      end

      private
      def say(msg, color = nil)
        color ? shell.say(msg, color) : shell.say(msg)
      end
    end
  end
end
