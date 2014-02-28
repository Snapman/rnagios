require 'test/unit'
require 'rnagios'

class ActiveStatusTest < Test::Unit::TestCase
  def test_active_check
    assert_equal "hello world", ActiveStatus.hi("english")
  end

  def test_nsca_host_check
    assert_equal "hello world", ActiveStatus.hi("ruby")
  end

  def test_nsca_service_check
    assert_equal "hola mundo",  ActiveStatus.hi("spanish")
  end
end
