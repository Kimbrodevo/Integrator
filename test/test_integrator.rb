require 'test/unit'
require 'fileutils'

require 'integrator'

class IntegratorTest < Test::Unit::TestCase

  def setup
    FileUtils.mkdir_p("integration/inbox")
    FileUtils.cp("test/fixture/1000.json", "integration/inbox")
    
    processors = [Processor.new]
    @integrator = Integrator.new("integration", processors)
  end
  
  def test_load
    assert_equal(0, @integrator.load_file("1000.json")["account"]["admin"]["has_ec2_access"])    
    assert_equal("Mario Olive", @integrator.load_file("1000.json")["account"]["subscription"]["owner"])
  end
  
  def test_queued
    assert_equal(1, @integrator.queued)
  end
  
  def test_poll
    assert_equal(1, @integrator.poll.length)
  end
end