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
    And I should see "Finally, edit cookbooks/hudson_slave/attributes/default.rb"
  
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
    And I should see "Finally, edit cookbooks/hudson_slave/attributes/default.rb"

  
  
