require 'test/unit'
require 'rnagios'

class PluginTest < Test::Unit::TestCase

  def test_initialize
    assert_raise NagiosError, 'Hostname should be required' do
      p = Plugin.new
    end

    assert_raise NagiosError, 'Hostname should be required' do
      p = Plugin.new {}
    end

    assert_raise NagiosError, 'Hostname should be required' do
      p = Plugin.new ({ :host => nil })
    end

    assert_nothing_raised NagiosError, 'Minimum parameters were given and constructor still failed' do
      p = Plugin.new({ :host => 'myhost' })
      assert_equal p.port, 80, 'Port should be 80'
    end

    assert_nothing_raised NagiosError, 'Error occurred while trying to set port number' do
      p = Plugin.new({ :host => 'myhost', :port => '80' })
      assert p.port.is_a?(Integer), 'Port should be numeric'
      assert_equal p.port, 80, 'Port should be 80'
    end

    p = Plugin.new({ :host => 'myhost', :port => 80 })
    assert p.port.is_a?(Integer), 'Port should be numeric'
    assert_equal p.port, 80, 'Port should be 80'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => nil })
    assert_equal p.name, '<UNDEFINED>', 'Name should be <UNDEFINED>'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => '' })
    assert_equal p.name, '<UNDEFINED>', 'Name should be <UNDEFINED>'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'service' })
    assert_equal p.name, 'SERVICE', 'Name should be SERVICE'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service' })
    assert_equal p.name, 'SERVICE', 'Name should be SERVICE'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :config_file => nil })
    assert p.config_file.nil?, 'config_file should be nil'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :w => nil })
    assert p.w.nil?, 'w should be nil'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :c => nil })
    assert p.c.nil?, 'c should be nil'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :use_ssl => nil })
    assert !p.use_ssl, 'use_ssl should be false'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :use_ssl => false })
    assert !p.use_ssl, 'use_ssl should be false'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :use_ssl => true })
    assert p.use_ssl, 'use_ssl should be true'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :verify_ssl => nil })
    assert !p.verify_ssl, 'verify_ssl should be false'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :verify_ssl => false })
    assert !p.verify_ssl, 'verify_ssl should be false'

    p = Plugin.new({ :host => 'myhost', :port => 80, :name => 'check_service', :verify_ssl => true })
    assert p.verify_ssl, 'verify_ssl should be true'
  end

  def test_name
    p = Plugin.new({ :host => 'myhost', :port => 80, :name => nil })
    assert_equal p.name, '<UNDEFINED>', 'Name should be <UNDEFINED>'

    p.name = ''
    assert_equal p.name, '<UNDEFINED>', 'Name should be <UNDEFINED>'

    p.name = 'service'
    assert_equal p.name, 'SERVICE', 'Name should be SERVICE'

    p.name = 'check_service'
    assert_equal p.name, 'SERVICE', 'Name should be SERVICE'
  end

  class ActivePlugin < Plugin
    def measure
      ActiveStatus.new(ActiveStatus::OK, 'Test message')
    end
  end

  class NscaHostPlugin < Plugin
    def measure
      NscaHostStatus.new(NscaHostStatus::UP, 'Test message')
    end
  end

  class NscaServicePlugin < Plugin
    def measure
      NscaServiceStatus.new(ActiveStatus::OK, 'Test message')
    end
  end

  def test_check
    p = Plugin.new({ :host => 'localhost', :port => 80, :name => 'check_service' })
    assert_raise NagiosError, 'Measure method was not defined and check still ran' do
      p.check
    end

    p = ActivePlugin.new({ :host => 'localhost', :port => 80, :name => 'check_service' })
    assert_nothing_raised NagiosError, 'Measure method was defined and check failed' do
      s = p.check
      assert_equal s.status, ActiveStatus::OK, 'Status should be OK'
      assert s.message.start_with?('SERVICE'), 'Message should start with "SERVICE"'
      assert s.message.include?('Test message'), 'Message should contain "Test message"'
      assert_equal s.exit_code, ActiveStatus::OK_EXIT_CODE, 'Exit code should be OK_EXIT_CODE'
    end

    p = NscaHostPlugin.new({ :host => 'localhost', :port => 80, :name => 'check_service' })
    assert_nothing_raised NagiosError, 'Measure method was defined and check failed' do
      s = p.check
      assert_equal s.status, NscaHostStatus::UP, 'Status should be UP'
      assert s.message.include?('PROCESS_HOST_CHECK_RESULT'), 'Message should include "PROCESS_HOST_CHECK_RESULT"'
      assert s.message.include?('Test message'), 'Message should contain "Test message"'
      assert_equal s.passive_code, NscaHostStatus::UP_CODE, 'Exit code should be UP_CODE'
    end

    p = NscaServicePlugin.new({ :host => 'localhost', :port => 80, :name => 'check_service' })
    assert_nothing_raised NagiosError, 'Measure method was defined and check failed' do
      s = p.check
      assert_equal s.status, ActiveStatus::OK, 'Status should be OK'
      assert s.message.include?('PROCESS_SERVICE_CHECK_RESULT'), 'Message should include "PROCESS_SERVICE_CHECK_RESULT"'
      assert s.message.include?('Test message'), 'Message should contain "Test message"'
      assert_equal s.passive_code, ActiveStatus::OK_EXIT_CODE, 'Exit code should be OK_EXIT_CODE'
    end  
  end

  def test_measure
    p = Plugin.new({ :host => 'localhost', :port => 80, :name => 'check_service' })
    assert_raise NagiosError, 'Measure method was not defined and check still ran' do
      p.measure
    end
  end

end
