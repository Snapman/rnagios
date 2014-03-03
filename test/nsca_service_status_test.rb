require 'test/unit'
require 'rnagios'

class NscaServiceStatusTest < Test::Unit::TestCase

  def test_initialize
    s = NscaServiceStatus.new
    assert_equal s.status, ActiveStatus::UNKNOWN, 'Status should be UNKNOWN'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::UNKNOWN_EXIT_CODE, 'Exit code is not UNKNOWN code'

    s = NscaServiceStatus.new(ActiveStatus::OK)
    assert_equal s.status, ActiveStatus::OK, 'Status should be OK'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::OK_EXIT_CODE, 'Exit code is not OK code'

    s = NscaServiceStatus.new(ActiveStatus::WARNING, 'Test message')
    assert_equal s.status, ActiveStatus::WARNING, 'Status should be WARNING'
    assert_equal s.message, 'Test message', 'Message should be "Test message"'
    assert_equal s.passive_code, ActiveStatus::WARNING_EXIT_CODE, 'Exit code is not WARNING code'
  end

  def test_status
    s = NscaServiceStatus.new
    assert_equal s.status, ActiveStatus::UNKNOWN, 'Status should be UNKNOWN'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::UNKNOWN_EXIT_CODE, 'Exit code is not UNKNOWN code'

    s.status = ActiveStatus::OK
    assert_equal s.status, ActiveStatus::OK, 'Status should be OK'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::OK_EXIT_CODE, 'Exit code is not OK code'

    s.status = nil
    assert_equal s.status, ActiveStatus::UNKNOWN, 'Status should be UNKNOWN'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::UNKNOWN_EXIT_CODE, 'Exit code is not UNKNOWN code'

    s.status = 'INVALID STATUS'
    assert_equal s.status, ActiveStatus::UNKNOWN, 'Status should be UNKNOWN'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::UNKNOWN_EXIT_CODE, 'Exit code is not UNKNOWN code'

    s.status = ActiveStatus::WARNING
    assert_equal s.status, ActiveStatus::WARNING, 'Status should be WARNING'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::WARNING_EXIT_CODE, 'Exit code is not WARNING code'

    s.message = 'Test message'
    assert_equal s.message, 'Test message', 'Message should be "Test message"'
    assert_equal s.passive_code, ActiveStatus::WARNING_EXIT_CODE, 'Exit code is not WARNING code'
  end

  def test_empty
    s = NscaServiceStatus.new
    assert_equal s.status, ActiveStatus::UNKNOWN, 'Status should be UNKNOWN'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, ActiveStatus::UNKNOWN_EXIT_CODE, 'Exit code is not UNKNOWN code'
    assert s.empty?, 'Status is not empty'
    s.status = nil
    s.message = nil
    assert s.empty?, 'Status is not empty'
  end

end
