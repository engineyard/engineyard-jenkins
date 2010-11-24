Given /^I have setup my engineyard email\/password for API access$/ do
  ENV['EYRC'] = File.join(@home_path, ".eyrc")
  token = { ENV['CLOUD_URL'] => {
      "api_token" => "f81a1706ddaeb148cfb6235ddecfc1cf"} }
  File.open(ENV['EYRC'], "w"){|f| YAML.dump(token, f) }
end

When /^I have "two accounts, two apps, two environments, ambiguous"$/ do
  api_scenario "two accounts, two apps, two environments, ambiguous"
end
