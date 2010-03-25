require 'rubygems'
require 'rake'

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

namespace :cucumber do
  desc "Prepare RVM environments for Cucumber features"
  task :prepare do
    puts "******************************************"
    puts "Run the following commands in your shell,"
    puts "pending a better way to do this :-)"
    puts "(`rvm 1.9.1 exec bundle install` would be sweet)"
    puts "******************************************"
    puts
    
    puts "rvm use 1.8.7; rvm --force gemset delete spork-rails2; rvm gemset create spork-rails2"
    puts "rvm use 1.8.7; rvm --force gemset delete spork-rails3; rvm gemset create spork-rails3"
    puts "rvm use 1.9.1; rvm --force gemset delete spork-rails2; rvm gemset create spork-rails2"
    puts "rvm use 1.9.1; rvm --force gemset delete spork-rails3; rvm gemset create spork-rails3"
    puts
    
    puts "rvm use 1.8.7@spork-rails2; gem install bundler; bundle install --gemfile=features/gemfiles/rails2.gemfile"
    puts "rvm use 1.8.7@spork-rails3; gem install bundler; bundle install --gemfile=features/gemfiles/rails3.gemfile"
    puts "rvm use 1.9.1@spork-rails2; gem install bundler; bundle install --gemfile=features/gemfiles/rails2.gemfile"
    puts "rvm use 1.9.1@spork-rails3; gem install bundler; bundle install --gemfile=features/gemfiles/rails3.gemfile"
    puts
    
    # Temporary integration hack
    puts "Then install ashleymoran/rspec-core into 1.8.7@spork-rails3 and 1.9.1@spork-rails3 (may have to uninstall first)"
    puts "rake build && rvm 1.8.7@spork-rails3 gem install pkg/rspec-core-2.0.0.beta.4.gem"
    puts "rake build && rvm 1.9.1@spork-rails3 gem install pkg/rspec-core-2.0.0.beta.4.gem"
    puts
    
    puts "rvm use default # or whatever you're using to develop Spork"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    require 'yaml'
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Spork #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Test all supported versions of rails"
task :test_rails do
  FAIL_MSG = "!! FAIL !!"
  OK_MSG = "OK"
  UNSUPPORTED_MSG = "Unsupported"
  rails_gems = `gem list rails`.grep(/^rails\b/).first
  versions = rails_gems.scan(/\((.+)\)/).flatten.first.split(", ")
  versions_2_x_gems = versions.grep(/^2/)
  results = {}
  versions_2_x_gems.each do |version|
    if version < '2.0.5'
      puts "-----------------------------------------------------"
      puts "Rails #{version} is not officially supported by Spork"
      puts "Why?  http://www.nabble.com/rspec-rails-fails-to-find-a-controller-name-td23223425.html"
      puts "-----------------------------------------------------"
      results[version] = UNSUPPORTED_MSG
      next
    end
    
    
    puts "Testing version #{version}"
    pid = Kernel.fork do
      test_files = %w[features/rspec_rails_integration.feature features/rails_delayed_loading_workarounds.feature]
      
      unless version < '2.1'
        # pending a fix, the following error happens with rails 2.0:
        # /opt/local/lib/ruby/gems/1.8/gems/cucumber-0.3.11/lib/cucumber/rails/world.rb:41:in `use_transactional_fixtures': undefined method `configuration' for Rails:Module (NoMethodError)
        test_files << "features/cucumber_rails_integration.feature "
      end
      exec("env RAILS_VERSION=#{version} cucumber #{test_files * ' '}; echo $? > result")
    end
    Process.waitpid(pid)
    result = File.read('result').chomp
    FileUtils.rm('result')
    if result=='0'
      results[version] = OK_MSG
    else
      results[version] = FAIL_MSG
    end
  end
  
  puts "Results:"
  File.open("TESTED_RAILS_VERSIONS.txt", 'wb') do |f|
    results.keys.sort.each do |version|
      s = "#{version}:\t#{results[version]}"
      f.puts(s)
      puts(s)
    end
  end
  if results.values.any? { |r| r == FAIL_MSG }
    exit 1
  else
    exit 0
  end
end
