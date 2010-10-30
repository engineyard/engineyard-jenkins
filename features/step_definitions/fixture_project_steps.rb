Given /^I am in the "([^\"]*)" project folder$/ do |project|
  project_folder = File.expand_path(File.join(@fixtures_path, "projects", project))
  in_tmp_folder do
    FileUtils.cp_r(project_folder, project)
    setup_active_project_folder(project)
  end
end

Given /^I already have cookbooks installed$/ do
  cookbooks_folder = File.expand_path(File.join(@fixtures_path, "cookbooks"))
  in_project_folder do
    FileUtils.cp_r(cookbooks_folder, ".")
  end
end
