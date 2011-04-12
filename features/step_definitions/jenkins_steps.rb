Given /^I want to fake out the boot sequence of Jenkins$/ do
  base_path = File.join(File.dirname(__FILE__) + "/../../fixtures/jenkins_boot_sequence/")
  FakeWeb.register_uri(:get, "http://app-master-hostname.compute-1.amazonaws.com/", [
    {:body => File.read(base_path + "pre_jenkins_booting.html")},
    {:body => File.read(base_path + "jenkins_booting.html")},
    {:body => File.read(base_path + "jenkins_ready.html")}
  ])
end

