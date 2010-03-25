Feature: Diagnostic Mode
  To help a developer quickly pinpoint why files are being loaded
  Spork provides a diagnostic mode
  That provides a list of which project files were loaded during prefork, and who loaded them.

  Scenario: Running spork --diagnose
    # Given I am in the directory "test_project"
    And a file named "spec/spec_helper.rb" with:
      """
      require 'rubygems'
      require 'spork'

      Spork.prefork do
        require 'lib/awesome.rb'
        require '../external_dependency/super_duper.rb'
      end

      Spork.each_run do
        puts "I'm loading the stuff just for this run..."
      end
      """
    And a file named "lib/awesome.rb" with:
      """
      class Awesome
      end
      """
    And a file named "../external_dependency/super_duper.rb" with:
      """
      class Awesome
      end
      """
    When I run "spork --diagnose"
    Then the stderr should contain "Loading Spork.prefork block..."
    And I should see "lib/awesome.rb"
    And I should see "spec/spec_helper.rb:5"
    And I should not see "super_duper.rb"
    And I should not see "diagnose.rb"
     