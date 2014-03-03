require 'test/unit'
require 'rnagios'

class NscaHostStatusTest < Test::Unit::TestCase

  def test_initialize
    s = NscaHostStatus.new
    assert_equal s.status, NscaHostStatus::UNREACHABLE, 'Status should be UNREACHABLE'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UNREACHABLE_CODE, 'Passive code is not UNREACHABLE code'

    s = NscaHostStatus.new(NscaHostStatus::UP)
    assert_equal s.status, NscaHostStatus::UP, 'Status should be UP'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UP_CODE, 'Passive code is not UP code'

    s = NscaHostStatus.new(NscaHostStatus::DOWN, 'Test message')
    assert_equal s.status, NscaHostStatus::DOWN, 'Status should be DOWN'
    assert_equal s.message, 'Test message', 'Message should be "Test message"'
    assert_equal s.passive_code, NscaHostStatus::DOWN_CODE, 'Passive code is not DOWN code'
  end

  def test_status
    s = NscaHostStatus.new
    assert_equal s.status, NscaHostStatus::UNREACHABLE, 'Status should be UNREACHABLE'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UNREACHABLE_CODE, 'Passive code is not UNREACHABLE code'

    s.status = NscaHostStatus::UP
    assert_equal s.status, NscaHostStatus::UP, 'Status should be UP'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UP_CODE, 'Passive code is not UP code'

    s.status = nil
    assert_equal s.status, NscaHostStatus::UNREACHABLE, 'Status should be UNREACHABLE'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UNREACHABLE_CODE, 'Passive code is not UNREACHABLE code'

    s.status = 'INVALID STATUS'
    assert_equal s.status, NscaHostStatus::UNREACHABLE, 'Status should be UNREACHABLE'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UNREACHABLE_CODE, 'Passive code is not UNREACHABLE code'

    s.status = NscaHostStatus::DOWN
    assert_equal s.status, NscaHostStatus::DOWN, 'Status should be DOWN'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::DOWN_CODE, 'Passive code is not DOWN code'

    s.message = 'Test message'
    assert_equal s.message, 'Test message', 'Message should be "Test message"'
    assert_equal s.passive_code, NscaHostStatus::DOWN_CODE, 'Passive code is not DOWN code'
  end

  def test_empty
    s = NscaHostStatus.new
    assert_equal s.status, NscaHostStatus::UNREACHABLE, 'Status should be UNREACHABLE'
    assert_equal s.message, '<EMPTY>', 'Message should be "<EMPTY>"'
    assert_equal s.passive_code, NscaHostStatus::UNREACHABLE_CODE, 'Passive code is not UNREACHABLE code'
    assert s.empty?, 'Status is not empty'
    s.status = nil
    s.message = nil
    assert s.empty?, 'Status is not empty'
  end

end
