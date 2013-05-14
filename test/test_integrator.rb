require 'test/unit'
require 'integrator'

class IntegratorTest < Test::Unit::TestCase

  def test_init
    assert_equal(Integrator.new.init, "Hello")
  end
end