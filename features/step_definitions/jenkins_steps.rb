Given /^I want to fake out the boot sequence of Jenkins$/ do
  base_path = File.join(File.dirname(__FILE__) + "/../../fixtures/jenkins_boot_sequence/")
  FakeWeb.register_uri(:get, "http://app-master-hostname.compute-1.amazonaws.com/", [
    {:body => File.read(base_path + "pre_jenkins_booting.html")},
    {:body => File.read(base_path + "jenkins_booting.html")},
    {:body => File.read(base_path + "jenkins_ready.html")}
  ])
end

Given /^I have public key "([^"]*)" on host "([^"]*)"$/ do |public_key_value, host|
  mock_target = File.expand_path("../../../tmp/scp_mock", __FILE__)
  File.open(mock_target, "w") { |file| file << public_key_value }
end

Given /^I set "([^"]*)" as the default Jenkins server$/ do |host|
  require "jenkins"
  require "jenkins/config"
  Jenkins::Api.setup_base_url(:host => host, :port => 80)
  Jenkins::Api.send(:cache_base_uri)
end

