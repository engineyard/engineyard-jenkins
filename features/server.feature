@wip
Feature: Managing ey hudson server
  I want to install a Hudson CI server hosted on Engine Yard AppCloud
  
  Scenario: Install new Hudson CI server on AppCloud
    Given I have an environment "hudson" on account "drnic" on AppCloud
    # or hudson_server, hudson_server_production, or hudson_production
    When I run local executable "ey-hudson" with arguments "install_server ."
    Then file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/hudson_master/recipes/default.rb" is created
    And file "cookbooks/hudson_master/attributes/default.rb" contains ":plugins => %w[git github rake ruby greenballs envfile]"
    And I should see exactly
      """
            create  cookbooks
            create  cookbooks/hudson_master/recipes/default.rb
            create  cookbooks/hudson_master/templates/default/init.sh.erb
            create  cookbooks/hudson_master/templates/default/proxy.conf.erb
            create  cookbooks/main/attributes/recipe.rb
            create  cookbooks/main/definitions/ey_cloud_report.rb
            create  cookbooks/main/libraries/ruby_block.rb
            create  cookbooks/main/libraries/run_for_app.rb
            create  cookbooks/main/recipes/default.rb
            create  cookbooks/hudson_master/attributes/default.rb
      
      Uploading to 'hudson' environment on 'drnic' account...
      Applying to 'hudson' environment on 'drnic' account...

      * Boot your environment if not already booted.
      You are now hosting a Hudson CI!
      """
  
  Scenario: Install Hudson CI server with additional Hudson plugins
    Given I have an environment "hudson" on account "drnic" on AppCloud
    When I run local executable "ey-hudson" with arguments "install_server . -p ' chucknorris , googleanalytics '"
    Then file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/hudson_master/recipes/default.rb" is created
    And file "cookbooks/hudson_master/attributes/default.rb" contains ":plugins => %w[git github rake ruby greenballs envfile chucknorris googleanalytics]"
  
  Scenario: Ask for environment/account details if no obvious hudson environment on AppCloud
    Given I have an environment "foobar" on account "drnic" on AppCloud
    When I run local executable "ey-hudson" with arguments "install_server ."
    Then file "cookbooks/main/recipes/default.rb" is not created
    And I should see exactly
      """
      Cannot find an obvious environment to install hudson.
      Either:
        * Create an AppCloud environment called hudson, hudson_server, hudson_production, hudson_server_production
        * Use --environment/--account flags to select AppCloud environment
      """
    When I run local executable "ey-hudson" with arguments "install_server . --account drnic --environment foobar"
    Then file "cookbooks/main/recipes/default.rb" is created
  
  
  
  
  
