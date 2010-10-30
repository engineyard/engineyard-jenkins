Feature: Managing a rails project as a Hudson CI job on AppCloud
  I want to build/test my project in the same environment I run in Engine Yard AppCloud
  
  Scenario: Setup first project as a slave for Hudson
    Given I have an environment "hudson" on account "drnic" on AppCloud
    And I have an environment "my_app_ci" on account "drnic" on AppCloud
    And I am in the "rails" project folder
    When I run local executable "ey-hudson" with arguments "install ."
    Then file "cookbooks/hudson_slave/attributes/default.rb" is created
    And file "cookbooks/hudson_slave/recipes/default.rb" is created
    And file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/main/libraries/ruby_block.rb" is created
    And I should see exactly
      """
            create  cookbooks
            create  cookbooks/main/attributes/recipe.rb
            create  cookbooks/main/definitions/ey_cloud_report.rb
            create  cookbooks/main/libraries/ruby_block.rb
            create  cookbooks/main/libraries/run_for_app.rb
            create  cookbooks/hudson_slave/attributes/default.rb
            create  cookbooks/hudson_slave/recipes/default.rb
            create  cookbooks/main/recipes/default.rb
      
      Finally:
      * edit cookbooks/hudson_slave/attributes/default.rb as necessary.
      * run: ey recipes upload
      * run: ey recipes apply
      * Boot your environment if not already booted.
      When the recipe completes, your project will commence its first build on Hudson CI.
      """
  
  Scenario: Setup project with existing cookbooks as a slave for Hudson
    Given I have an environment "hudson" on account "drnic" on AppCloud
    And I have an environment "my_app_ci" on account "drnic" on AppCloud
    And I am in the "rails" project folder
    And I already have cookbooks installed
    When I run local executable "ey-hudson" with arguments "install ."
    Then file "cookbooks/hudson_slave/attributes/default.rb" is created
    And file "cookbooks/hudson_slave/recipes/default.rb" is created
    And file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/redis/recipes/default.rb" is created
    And I should see exactly
      """
            create  cookbooks/hudson_slave/attributes/default.rb
            create  cookbooks/hudson_slave/recipes/default.rb
            append  cookbooks/main/recipes/default.rb

      Finally:
      * edit cookbooks/hudson_slave/attributes/default.rb as necessary.
      * run: ey recipes upload
      * run: ey recipes apply
      * Boot your environment if not already booted.
      When the recipe completes, your project will commence its first build on Hudson CI.
      """

  
  
