require 'test/unit'
require 'rnagios'

class RNagiosTest < Test::Unit::TestCase
  def test_active_check
    assert_equal "hello world", RNagios.hi("english")
  end

  def test_nsca_host_check
    assert_equal "hello world", RNagios.hi("ruby")
  end

  def test_nsca_service_check
    assert_equal "hola mundo",  RNagios.hi("spanish")
  end
end
