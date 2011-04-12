Feature: Managing ey jenkins server
  I want to install a Jenkins CI server hosted on Engine Yard AppCloud
  
  Background:
    Given I have setup my engineyard email/password for API access
    And I have "two accounts, two apps, two environments, ambiguous"
    And I want to fake out the boot sequence of Jenkins
    
  Scenario: Install new Jenkins CI server on AppCloud
    When I run local executable "ey-jenkins" with arguments "install_server . --account account_2 --environment giblets"
    Then file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/jenkins_master/recipes/default.rb" is created
    And file "cookbooks/jenkins_master/attributes/default.rb" contains ":plugins => %w[git github rake ruby greenballs envfile]"
    And I should see exactly
      """
            create  cookbooks
            create  cookbooks/jenkins_master/recipes/default.rb
            create  cookbooks/jenkins_master/templates/default/init.sh.erb
            create  cookbooks/jenkins_master/templates/default/proxy.conf.erb
            create  cookbooks/main/attributes/recipe.rb
            create  cookbooks/main/definitions/ey_cloud_report.rb
            create  cookbooks/main/libraries/ruby_block.rb
            create  cookbooks/main/libraries/run_for_app.rb
            create  cookbooks/main/recipes/default.rb
            create  cookbooks/jenkins_master/attributes/default.rb
      
      Uploading to 'giblets' environment on 'account_2' account...
      Environment is rebuilding...
      ..
      Jenkins is starting...
      .
      Done! Jenkins CI hosted at http://app-master-hostname.compute-1.amazonaws.com
      """
    When I run executable "jenkins" with arguments "default_host"
    Then I should see "http://app-master-hostname.compute-1.amazonaws.com"
  
  @wip
  Scenario: Install Jenkins CI server with additional Jenkins plugins
    When I run local executable "ey-jenkins" with arguments "install_server . -p ' chucknorris , googleanalytics ' -c account_2 -e giblets"
    Then file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/jenkins_master/recipes/default.rb" is created
    And file "cookbooks/jenkins_master/attributes/default.rb" contains ":plugins => %w[git github rake ruby greenballs envfile chucknorris googleanalytics]"

  Scenario: Display example explicit calls if multiple accounts/options
    When I run local executable "ey-jenkins" with arguments "install_server . -e giblets"
    Then file "cookbooks/main/recipes/default.rb" is not created
    And I should see exactly
      """
      Multiple environments possible, please be more specific:

        ey-jenkins install_server --environment 'giblets' --account 'main'
        ey-jenkins install_server --environment 'giblets' --account 'account_2'
      """
  
  Scenario: Ask for environment/account details if no obvious jenkins environment on AppCloud
    When I run local executable "ey-jenkins" with arguments "install_server ."
    Then file "cookbooks/main/recipes/default.rb" is not created
    And I should see exactly
      """
      No environments with name jenkins, jenkins_server, jenkins_production, jenkins_server_production.
      Either:
        * Create an AppCloud environment called jenkins, jenkins_server, jenkins_production, jenkins_server_production
        * Use --environment/--account flags to select AppCloud environment
      """
  
  
  
  
  
