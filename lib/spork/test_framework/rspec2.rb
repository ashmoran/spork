class Spork::TestFramework::RSpec2 < Spork::TestFramework
  DEFAULT_PORT = 8989
  HELPER_FILE = File.join(Dir.pwd, "spec/spec_helper.rb")

  def run_tests(argv, stderr, stdout)
    ::Rspec::Core::Runner.new.run(argv, stderr, stdout)
  end
end
