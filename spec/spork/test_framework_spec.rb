require File.dirname(__FILE__) + '/../spec_helper'

describe "a TestFramework", :shared => true do
  describe ".default_port" do
    it "uses the DEFAULT_PORT when the environment variable is not set" do
      @klass.default_port.should == @klass::DEFAULT_PORT
    end

    it 'uses ENV["#{short_name.upcase}_DRB"] as port if present' do
      env_name = "#{@klass.short_name.upcase}_DRB"
      orig, ENV[env_name] = ENV[env_name], "9000"
      begin
        @klass.default_port.should == 9000
      ensure
        ENV[env_name] = orig
      end
    end
  end

  describe ".helper_file" do
    it "returns ::HELPER_FILE for the TestFramework" do
      @klass.helper_file.should == @klass::HELPER_FILE
    end
  end
end

describe Spork::TestFramework do

  before(:each) do
    @fake = FakeFramework.new
  end

  describe ".available_test_frameworks" do
    before(:each) do
      Spork::TestFramework.supported_test_frameworks.each { |s| s.stub!(:available?).and_return(false) }
    end

    it "returns a list of all available servers" do
      Spork::TestFramework.available_test_frameworks.should == []
      Spork::TestFramework::RSpec.stub!(:available?).and_return(true)
      Spork::TestFramework.available_test_frameworks.should == [Spork::TestFramework::RSpec]
    end

    it "returns rspec before rspec2 before cucumber when all are available" do
      Spork::TestFramework::RSpec.stub!(:available?).and_return(true)
      Spork::TestFramework::RSpec2.stub!(:available?).and_return(true)
      Spork::TestFramework::Cucumber.stub!(:available?).and_return(true)
      Spork::TestFramework.available_test_frameworks.should == [Spork::TestFramework::RSpec, Spork::TestFramework::RSpec2, Spork::TestFramework::Cucumber]
    end
  end

  describe ".supported_test_frameworks" do
    it "returns all defined servers" do
      Spork::TestFramework.supported_test_frameworks.should include(Spork::TestFramework::RSpec)
      Spork::TestFramework.supported_test_frameworks.should include(Spork::TestFramework::RSpec2)
      Spork::TestFramework.supported_test_frameworks.should include(Spork::TestFramework::Cucumber)
    end

    it "returns a list of servers matching a case-insensitive prefix" do
      # TODO verify that having both versions returned is correct, or at least acceptable
      Spork::TestFramework.supported_test_frameworks("rspec").should == [Spork::TestFramework::RSpec, Spork::TestFramework::RSpec2]
      Spork::TestFramework.supported_test_frameworks("rs").should == [Spork::TestFramework::RSpec, Spork::TestFramework::RSpec2]
      Spork::TestFramework.supported_test_frameworks("rspec2").should == [Spork::TestFramework::RSpec2]
      Spork::TestFramework.supported_test_frameworks("cuc").should == [Spork::TestFramework::Cucumber]
    end
  end

  describe ".short_name" do
    it "returns the name of the framework, without the namespace prefix" do
      Spork::TestFramework::Cucumber.short_name.should == "Cucumber"
    end
  end

  describe ".available?" do
    it "returns true when the helper_file exists" do
      FakeFramework.available?.should == false
      create_helper_file(FakeFramework)
      FakeFramework.available?.should == true
    end
  end

  describe ".bootstrapped?" do
    it "recognizes if the helper_file has been bootstrapped" do
      bootstrap_contents = File.read(FakeFramework::BOOTSTRAP_FILE)
      File.stub!(:read).with(@fake.helper_file).and_return("")
      @fake.bootstrapped?.should == false
      File.stub!(:read).with(@fake.helper_file).and_return(bootstrap_contents)
      @fake.bootstrapped?.should == true
    end
  end

  describe ".bootstrap" do
    it "bootstraps a file" do
      create_helper_file
      @fake.bootstrap

      $test_stderr.string.should include("Bootstrapping")
      $test_stderr.string.should include("Edit")
      $test_stderr.string.should include("favorite text editor")

      File.read(@fake.helper_file).should include(File.read(FakeFramework::BOOTSTRAP_FILE))
    end
  end

  describe ".factory" do
    # Currently, both frameworks are detected by spec_helper.rb,
    # therefore they will both appear available or unavailable together
    def stub_rspec_available(availability)
      Spork::TestFramework::RSpec.stub!(:available?).and_return(availability)
      Spork::TestFramework::RSpec2.stub!(:available?).and_return(availability)
    end
    
    it "defaults to use rspec over cucumber" do
      stub_rspec_available(true)
      Spork::TestFramework::Cucumber.stub!(:available?).and_return(true)
      Spork::TestFramework.factory(STDOUT, STDERR).class.should == Spork::TestFramework::RSpec
    end

    it "defaults to use cucumber when rspec not available" do
      stub_rspec_available(false)
      Spork::TestFramework::Cucumber.stub!(:available?).and_return(true)
      Spork::TestFramework.factory(STDOUT, STDERR).class.should == Spork::TestFramework::Cucumber
    end
  end
end
