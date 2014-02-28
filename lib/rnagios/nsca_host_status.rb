# NscaHostStatus has a different set of statuses from ActiveStatus.
# Instead of OK, WARNING, UNKNOWN, and CRITICAL, NscaHostStatus
# uses UP, DOWN, and UNREACHABLE.  These statuses are all meant to apply
# only to hosts and not services.  Also, passive checks do not need to
# concern themselves with exit codes, as their output will be sent via
# the send_nsca program to a Nagios server for processing.  It just so
# happens that the 'host status' is exactly the same as the UNIX/Linux
# exit codes, but we use the @passive_code attribute anyway for clarity.
class NscaHostStatus < Status

  # This gives us the @passive_code attribute
  include Nsca

  # Host is up and available
  UP = 'UP'
  # Host is down and unavailable
  DOWN = 'DOWN'
  # Host is unreachable (e.g. behind a router or host that is down)
  UNREACHABLE = 'UNREACHABLE'

  # Host status code for UP
  UP_CODE = 0
  # Host status code for DOWN
  DOWN_CODE = 1
  # Host status code for UNREACHABLE
  UNREACHABLE_CODE = 2

  # If status is not given, it will default to UNREACHABLE.  If message
  # is not given, it will default to <EMPTY>.  UNIX/Linux exit codes
  # are assigned automatically.
  def initialize(status=nil, message=nil)
    if status.nil? || (status != UP && status != DOWN && status != UNREACHABLE)
      @status = UNREACHABLE
    else
      @status = status if !status.nil?
    end

    if message.nil?
      @message = '<EMPTY>'
    else
      @message = message
    end

    case @status
    when UP
      @passive_code = UP_CODE
    when DOWN
      @passive_code = DOWN_CODE
    when UNREACHABLE
      @passive_code = UNREACHABLE_CODE
    end
  end

  # if status is not given, it will default to UNREACHABLE
  def status=(value)
    if status.nil? || (status != UP && status != DOWN && status != UNREACHABLE)
      @status = UNREACHABLE
    else
      @status = value
    end

    case @status
    when UP
      @passive_code = UP_CODE
    when DOWN
      @passive_code = DOWN_CODE
    when UNREACHABLE
      @passive_code = UNREACHABLE_CODE
    end
  end

  def empty?
    @status.nil? && @message.nil? && @passive_code.nil? && @status.empty? && @message.empty? && !@passive_code.is_a?(Integer)
  end

end
  
