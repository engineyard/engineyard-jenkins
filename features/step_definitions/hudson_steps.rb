Given /^I have an environment "([^"]*)" on account "([^"]*)" on AppCloud$/ do |env, account|
  ENV['EYRC'] = File.join(@home_path, ".eyrc")
end
