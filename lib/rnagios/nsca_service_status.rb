# NscaServiceStatus is essentially an ActiveStatus object with
# only an extra :passive_code attribute.
class NscaServiceStatus < ActiveStatus

  # Stand-in for return code
  attr_reader :passive_code

  # We call super.initialize to setup the ActiveStatus object then
  # we set @passive_code to @exit_code.  The values are exactly the
  # same
  def initialize(status=nil, message=nil)
    if status.nil? || (status != OK && status != WARNING && status != CRITICAL && status != UNKNOWN)
      @status = UNKNOWN
    else
      @status = status
    end

    if message.nil?
      @message = '<EMPTY>'
    else
      @message = message
    end

    case @status
    when OK
      @passive_code = OK_EXIT_CODE
    when WARNING
      @passive_code = WARNING_EXIT_CODE
    when CRITICAL
      @passive_code = CRITICAL_EXIT_CODE
    when UNKNOWN
      @passive_code = UNKNOWN_EXIT_CODE
    end
  end

  # We call super.status to setup the ActiveStatus object then
  # we set @passive_code to @exit_code.  The values are exactly the
  # same
  def status=(value)
    if value.nil? || (value != OK && value != WARNING && value != CRITICAL && value != UNKNOWN)
      @status = UNKNOWN
    else
      @status = value
    end

    case @status
    when OK
      @passive_code = OK_EXIT_CODE
    when WARNING
      @passive_code = WARNING_EXIT_CODE
    when CRITICAL
      @passive_code = CRITICAL_EXIT_CODE
    when UNKNOWN
      @passive_code = UNKNOWN_EXIT_CODE
    end
  end

  def empty?
    @status == UNKNOWN && (@message.nil? || @message.empty? || @message == '<EMPTY>')
  end

end
