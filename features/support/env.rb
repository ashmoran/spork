require 'rubygems'
require 'fileutils'
require 'forwardable'
require 'tempfile'

begin
  require 'rspec/expectations'
rescue LoadError => e
  puts "*** Falling back to RSpec 1.3 expectations in Cucumber"
  require 'spec/expectations'  
end

require 'aruba'

require 'timeout'
# require 'spork'

require(File.dirname(__FILE__) + '/background_job.rb')

# Always use the local spork
# see: http://github.com/aslakhellesoy/aruba/issues/issue/7
ENV["PATH"] = File.expand_path(File.dirname(__FILE__) + "/../../bin") << ":" << ENV["PATH"]

# TODO check if we need ../../lib in the $LOAD_PATH
# $LOAD_PATH << $LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/../lib')

class SporkWorld
  def initialize
    # TODO remove
    # @current_dir = SANDBOX_DIR
    @background_jobs = []
  end

  private
  attr_reader :last_exit_status, :background_jobs

  # TODO remove this when Aruba background job support is stable
  def last_background_job_stdout
    @last_stdout = @background_job.stdout.read
  end

  def localized_command(command, args)
    case command
    when 'cucumber'
      command = Cucumber::BINARY
    else
      command = %x{which #{command}}.chomp
    end
    # "#{SporkWorld::RUBY_BINARY} -I #{Cucumber::LIBDIR} #{command} #{args}"
    "#{command} #{args}"
  end

  def run_in_background(command)
    in_current_dir do
      @background_job = BackgroundJob.run(command)
    end
    @background_jobs << @background_job
    @background_job
  end

  def terminate_background_jobs
    if @background_jobs
      @background_jobs.each do |background_job|
        background_job.kill
      end
    end
    @background_jobs.clear
    @background_job = nil
  end
end

World do
  SporkWorld.new
end

Before do
  
end

After do
  terminate_background_jobs
end
