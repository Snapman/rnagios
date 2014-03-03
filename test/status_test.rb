require 'test/unit'
require 'rnagios'

class StatusTest < Test::Unit::TestCase

  def test_to_s
    s = Status.new
    assert_equal s.to_s, ': ', 'to_s should be ": "'
  end

  def test_empty
    s = Status.new
    assert_not_nil s.empty?, 'Status is not empty'
  end

  def test_status
    s = Status.new
    s.status = 'OK'
    assert_equal s.status, 'OK', 'Status should be OK'
  end

  def test_exit_code
    s = Status.new
    assert_equal s.exit_code, 0, 'Exit code should be 0'
  end

  def test_message
    s = Status.new
    s.message = 'A-OK'
    assert_equal s.message, 'A-OK', 'Message should be A-OK'
  end

end
