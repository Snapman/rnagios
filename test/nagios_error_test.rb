require 'test/unit'
require 'rnagios'

class NagiosErrorTest < Test::Unit::TestCase

  def test_initialize
    error = NagiosError.new
    assert_equal error.message, 'NagiosError'

    error = NagiosError.new 'Error occurred'
    assert_equal error.message, 'Error occurred'
  end

end
