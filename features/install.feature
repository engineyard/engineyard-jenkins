Feature: Managing a rails project as a Jenkins CI job on AppCloud
  I want to build/test my project in the same environment I run in Engine Yard AppCloud
  
  Scenario: Setup first project as a slave for Jenkins
    Given I am in the "rails" project folder
    When I run local executable "ey-jenkins" with arguments "install ."
    Then file "cookbooks/jenkins_slave/attributes/default.rb" is created
    And file "cookbooks/jenkins_slave/recipes/default.rb" is created
    And file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/main/libraries/ruby_block.rb" is created
    And I should see exactly
      """
            create  cookbooks
            create  cookbooks/main/attributes/recipe.rb
            create  cookbooks/main/definitions/ey_cloud_report.rb
            create  cookbooks/main/libraries/ruby_block.rb
            create  cookbooks/main/libraries/run_for_app.rb
            create  cookbooks/jenkins_slave/attributes/default.rb
            create  cookbooks/jenkins_slave/recipes/default.rb
            create  cookbooks/main/recipes/default.rb
      
      Finally:
      * edit cookbooks/jenkins_slave/attributes/default.rb as necessary.
      * run: ey recipes upload # use --environment(-e) & --account(-c)
      * run: ey recipes apply  #   to select environment
      * Boot your environment if not already booted.
      When the recipe completes, your project will commence its first build on Jenkins CI.
      """
  
  Scenario: Setup project with existing cookbooks as a slave for Jenkins
    Given I am in the "rails" project folder
    And I already have cookbooks installed
    When I run local executable "ey-jenkins" with arguments "install ."
    Then file "cookbooks/jenkins_slave/attributes/default.rb" is created
    And file "cookbooks/jenkins_slave/recipes/default.rb" is created
    And file "cookbooks/main/recipes/default.rb" is created
    And file "cookbooks/redis/recipes/default.rb" is created
    And I should see exactly
      """
            create  cookbooks/jenkins_slave/attributes/default.rb
            create  cookbooks/jenkins_slave/recipes/default.rb
            append  cookbooks/main/recipes/default.rb

      Finally:
      * edit cookbooks/jenkins_slave/attributes/default.rb as necessary.
      * run: ey recipes upload # use --environment(-e) & --account(-c)
      * run: ey recipes apply  #   to select environment
      * Boot your environment if not already booted.
      When the recipe completes, your project will commence its first build on Jenkins CI.
      """

  
  
