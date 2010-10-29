@wip
Feature: Managing a rails project as a Hudson CI job on AppCloud
  I want to build/test my project in the same environment I run in Engine Yard AppCloud
  
  Scenario: Setup first project as a slave for Hudson
    Given I have an environment "hudson" on account "drnic" on AppCloud
    And I have an environment "my_app_ci" on account "drnic" on AppCloud
    And I am in the "rails" project folder
    When I run local executable "ey-hudson" with arguments "install . -e my_app_ci -c drnic"
    Then I should see "Edit cookbooks/hudson_slave/attributes/default.rb"
    And file "cookbooks/hudson_slave/attributes/default.rb" is created
    And file "cookbooks/hudson_slave/recipes/default.rb" is created
    And file "cookbooks/main/recipes/default.rb" is created
  
  
  
