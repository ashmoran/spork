require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + "/../test_framework_spec"

describe Spork::TestFramework::RSpec2 do
  before(:each) do
    @klass = Spork::TestFramework::RSpec2
  end

  it_should_behave_like "a TestFramework"
end
