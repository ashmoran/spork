Feature: At exit during each run
  In order to make sure at_exit hooks defined during the run get called
  I want to override Kernel#at_exit

  Scenario: at exit (RSpec 1)
    Given I am using rvm "1.8.7"
    And I am using rvm gemset "spork-rails2"
    
    Given a file named "spec/spec_helper.rb" with:
      """
      require 'rubygems'
      gem 'rspec', '< 2.0.0'
      require 'spec'
      Spork.prefork do
        puts "loading"
        at_exit { puts "prefork at_exit called" }
      end

      Spork.each_run do
        puts "running"
        at_exit { printf "first " }
        at_exit { printf "second " }
      end

      """

    And a file named "spec/did_it_work_spec.rb" with:
      """
      describe "Did it work?" do
        it "checks to see if all worked" do
          puts "ran specs"
        end
      end
      """
    When I fire up a spork instance with "spork rspec"
    And I run "spec --drb spec/did_it_work_spec.rb"
    Then I should see "second first"
    Then I should not see "prefork at_exit called"

  Scenario Outline: at exit (RSpec 2)
    Given I am using rvm "<ruby_version>"
    And I am using rvm gemset "spork-rails3"

    Given a file named "spec/spec_helper.rb" with:
      """
      require 'rubygems'
      require 'bundler'
      require 'rspec/core'
      
      Spork.prefork do
        puts "loading"
        at_exit { puts "prefork at_exit called" }
      end

      Spork.each_run do
        puts "running"
        at_exit { printf "first " }
        at_exit { printf "second " }
      end

      """

    And a file named "spec/did_it_work_spec.rb" with:
      """
      describe "Did it work?" do
        it "checks to see if all worked" do
          puts "ran specs"
        end
      end
      """
    When I fire up a spork instance with "spork rspec2"
    And I run "rspec --drb spec/did_it_work_spec.rb"
    Then I should see "second first"
    Then I should not see "prefork at_exit called"
    
    Examples:
      | ruby_version |
      | 1.8.7        |
      | 1.9.1        |
