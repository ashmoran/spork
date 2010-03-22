# TODO something about Rails 3
Given /^I am in a fresh rails (2|3)? project named "(.+)"$/ do |rails_version, folder_name|
  @current_dir = SporkWorld::SANDBOX_DIR
  version_argument = ENV['RAILS_VERSION'] ? "_#{ENV['RAILS_VERSION']}_" : nil
  # run("#{SporkWorld::RUBY_BINARY} #{%x{which rails}.chomp} #{folder_name}")
  run([SporkWorld::RUBY_BINARY, '-I', Cucumber::LIBDIR, %x{which rails}.chomp, version_argument, folder_name].compact * " ")
  @current_dir = File.join(File.join(SporkWorld::SANDBOX_DIR, folder_name))
end

Given "the application has a model, observer, route, and application helper" do
  # TODO append to the generated file rather than overwrite
  Given 'a file named "Gemfile" with:',
    """
    # Edit this Gemfile to bundle your application's dependencies.
    source 'http://gemcutter.org'


    gem 'rails', '3.0.0.beta'

    ## Bundle edge rails:
    # gem 'rails', :git => 'git://github.com/rails/rails.git'

    # ActiveRecord requires a database adapter. By default,
    # Rails has selected sqlite3.
    gem 'sqlite3-ruby', :require => 'sqlite3'

    ## Bundle the gems you use:
    # gem 'bj'
    # gem 'hpricot', '0.6'
    # gem 'sqlite3-ruby', :require => 'sqlite3'
    # gem 'aws-s3', :require => 'aws/s3'

    ## Bundle gems used only in certain environments:
    # gem 'rspec', :group => :test
    # group :test do
    #   gem 'webrat'
    # end
    
    # Spork feature additions
    gem 'spork'
    gem 'rspec-rails'
    """
  Given 'a file named "app/models/user.rb" with:',
    """
    class User < ActiveRecord::Base
      $loaded_stuff << 'User'
    end
    """
  Given 'a file named "app/models/user_observer.rb" with:',
    """
    class UserObserver < ActiveRecord::Observer
      $loaded_stuff << 'UserObserver'
    end
    """
  Given 'a file named "app/helpers/application_helper.rb" with:',
    """
    module ApplicationHelper
      $loaded_stuff << 'ApplicationHelper'
    end
    """
  Given 'the following code appears in "config/environment.rb" after /Rails::Initializer.run/:',
    """
      config.active_record.observers = :user_observer
    """
  Given 'the following code appears in "config/routes.rb" after /^end/:',
    """
      $loaded_stuff << 'config/routes.rb'
    """
  Given 'a file named "config/initializers/initialize_loaded_stuff.rb" with:',
    """
    $loaded_stuff ||= []
    """
  Given 'a file named "config/initializers/log_establish_connection_calls.rb" with:',
    """
    class ActiveRecord::Base
      class << self
        def establish_connection_with_load_logging(*args)
          establish_connection_without_load_logging(*args)
          $loaded_stuff << 'ActiveRecord::Base.establish_connection'
        end
        alias_method_chain :establish_connection, :load_logging
      end
    end
    """
end