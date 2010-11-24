engineyard_loaded_path = $:.select { |path| path =~ %r|gems/engineyard-\d+| }.first
EY_ROOT = engineyard_loaded_path.gsub(%r|/\w+$|,'')

# helper to be stubbed out from engineyard spec_helper.rb
def shared_examples_for(title)
end

support = Dir[File.join(EY_ROOT,'/spec/support/*.rb')]
support.each{|helper| require helper }
World(Spec::Helpers)

require "fakeweb"

Before do
  ENV["NO_SSH"] = "true"
  ENV['CLOUD_URL'] = EY.fake_awsm
  FakeWeb.allow_net_connect = true
end

After do
  ENV.delete('CLOUD_URL')
  ENV.delete('EYRC')
  ENV.delete('NO_SSH')
end