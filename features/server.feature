Feature: Managing ey hudson server
  I want to setup and manage a Hudson CI server hosted on Engine Yard AppCloud
  
  Scenario: Setup new Hudson CI server on AppCloud
    Given I have an environment "hudson" on account "drnic" on AppCloud
    When I run local executable "ey-hudson" with arguments "server ."
    Then file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/hudson_master/recipes/default.rb" is created
    And file "cookbooks/hudson_master/attributes/default.rb" contains ":plugins => %w[git github rake ruby greenballs]"
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
      
      Finally:
      * edit cookbooks/hudson_master/attributes/default.rb as necessary.
      * run: ey recipes upload # use --environment(-e) & --account(-c)
      * run: ey recipes apply  #   to select environment
      * Boot your environment if not already booted.
      When the recipe completes, your solo instance will host a Hudson CI!
      """
  
  Scenario: Setup Hudson CI server with additional Hudson plugins
    Given I have an environment "hudson" on account "drnic" on AppCloud
    When I run local executable "ey-hudson" with arguments "server . -p ' chucknorris , googleanalytics '"
    Then file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/hudson_master/recipes/default.rb" is created
    And file "cookbooks/hudson_master/attributes/default.rb" contains ":plugins => %w[git github rake ruby greenballs chucknorris googleanalytics]"
  
  
  
  
