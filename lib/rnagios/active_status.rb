# Represents the status of an active check.  Valid status strings for
# Nagios are OK, WARNING, CRITICAL, and UNKNOWN.  UNIX/Linux exit codes
# are set automatically when you set the status attribute.
class ActiveStatus < Status

  # Indicates everything is good with the service
  OK = 'OK'
  # Indicates a status of concern; not necessarily catastrophic
  WARNING = 'WARNING'
  # Indicates a serious failure or error
  CRITICAL = 'CRITICAL'
  # Indicates that the status is unknown or can not be determined
  UNKNOWN = 'UNKNOWN'

  # UNIX/Linux exit code for Nagios OK
  OK_EXIT_CODE = 0
  # UNIX/Linux exit code for Nagios WARNING
  WARNING_EXIT_CODE = 1
  # UNIX/Linux exit code for Nagios CRITICAL
  CRITICAL_EXIT_CODE = 2
  # UNIX/Linux exit code for Nagios UNKNOWN
  UNKNOWN_EXIT_CODE = 3

  # If status is not given, it will default to UNKNOWN.  If message
  # is not given, it will default to <EMPTY>.  UNIX/Linux exit codes
  # are assigned automatically.
  def initialize(status=nil, message=nil)
    if status.nil? || (status != OK && status != WARNING && status != CRITICAL && status != UNKNOWN)
      @status = UNKNOWN
    else
      @status = status if !status.nil?
    end

    if message.nil?
      @message = '<EMPTY>'
    else
      @message = message
    end

    case @status
    when OK
      @exit_code = OK_EXIT_CODE
    when WARNING
      @exit_code = WARNING_EXIT_CODE
    when CRITICAL
      @exit_code = CRITICAL_EXIT_CODE
    when UNKNOWN
      @exit_code = UNKNOWN_EXIT_CODE
    end
  end

  def status=(value)
    if value.nil? || (value != OK && value != WARNING && value != CRITICAL && value != UNKNOWN)
      @status = UNKNOWN
    else
      @status = value
    end

    case @status
    when OK
      @exit_code = OK_EXIT_CODE
    when WARNING
      @exit_code = WARNING_EXIT_CODE
    when CRITICAL
      @exit_code = CRITICAL_EXIT_CODE
    when UNKNOWN
      @exit_code = UNKNOWN_EXIT_CODE
    end
  end

end
