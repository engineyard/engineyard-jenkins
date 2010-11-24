Given /^I want to fake out the boot sequence of Hudson$/ do
  base_path = File.join(File.dirname(__FILE__) + "/../../fixtures/hudson_boot_sequence/")
  FakeWeb.register_uri(:get, "http://app-master-hostname.compute-1.amazonaws.com/", [
    {:body => File.read(base_path + "pre_hudson_booting.html")},
    {:body => File.read(base_path + "hudson_booting.html")},
    {:body => File.read(base_path + "hudson_ready.html")}
  ])
end

