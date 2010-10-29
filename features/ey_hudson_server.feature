@wip
Feature: Managing ey hudson server
  I want to setup and manage a Hudson CI server hosted on Engine Yard AppCloud
  
  Scenario: Setup new Hudson CI server on AppCloud
    Given I have an environment "hudson" on account "drnic" on AppCloud
    And I am in the "rails" project folder
    When I run local executable "ey-hudson" with arguments "server -e hudson -c drnic"
    Then I should see "Hudson CI server recipe installed."
  
  
  
