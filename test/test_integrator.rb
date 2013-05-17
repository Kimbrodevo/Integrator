require 'test/unit'
require 'fileutils'

require 'integrator'
require 'test/failure_processor'

class IntegratorTest < Test::Unit::TestCase

  def setup
    @inbox = "integration/inbox"
    @archive = "integration/archive"
    FileUtils.rm_rf(@inbox)
    FileUtils.rm_rf(@archive) 
    
    FileUtils.mkdir_p(@inbox)
    FileUtils.mkdir_p(@archive) 
    FileUtils.cp("test/fixture/1000.json", @inbox)
    log = File.open("/dev/null", "w")
    processors = [Processor.new]
    @integrator = Integrator.new("integration", processors, 0, log)
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

  def test_poll_pause
    assert_equal(1, @integrator.poll(2).length) 
  end

  def test_poll_failure
    processors = [FailureProcessor.new]
    integrator = Integrator.new("integration", processors, 5)
    integrator.poll

    assert_equal(false, File.exist?(File.join(@inbox, "1000.json")))
    assert_equal(true, File.exist?(File.join(@archive, "1000.json")))
  end
end