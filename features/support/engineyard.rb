engineyard_loaded_path = $:.select { |path| path =~ %r|gems/engineyard-\d+| }.first
EY_ROOT = engineyard_loaded_path.gsub(%r|/\w+$|,'')

# helper to be stubbed out from engineyard spec_helper.rb
def shared_examples_for(title)
end

support = Dir[File.join(EY_ROOT,'/spec/support/*.rb')]
support.each{|helper| require helper }
World(Spec::Helpers)

# temporary monkey patch
module EY
  class Repo
    def urls
      lines = `git config -f #{Escape.shell_command(@path)}/.git/config --get-regexp 'remote.*.url'`.split(/\n/)
      raise NoRemotesError.new(@path) if lines.empty?
      lines.map { |c| c.split.last }
    end
  end # Repo
end # EY

require "fake_web"

Before do
  ENV["NO_SSH"] = "true"
  ENV['CLOUD_URL'] = EY.fake_awsm
  FakeWeb.allow_net_connect = true
end

After do
  ENV.delete('CLOUD_URL')
  ENV.delete('EYRC')
  ENV.delete('NO_SSH')
  FakeWeb.allow_net_connect = false
end