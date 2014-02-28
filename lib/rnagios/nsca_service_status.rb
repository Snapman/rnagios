# NscaServiceStatus is essentially an ActiveStatus object with
# only an extra :passive_code attribute, so NscaServiceStatus
# inherits from ActiveStatus and includes the NscaStatus module
# to get the :passive_code attribute.
class NscaServiceStatus < ActiveStatus

  # This gives us the @passive_code attribute
  include Nsca

  # We call super.initialize to setup the ActiveStatus object then
  # we set @passive_code to @exit_code.  The values are exactly the
  # same
  def initialize(status=nil, message=nil)
    super(status, message)

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
    super.status = value

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
    @status.nil? && @message.nil? && @passive_code.nil? && @status.empty? && @message.empty? && !@passive_code.is_a?(Integer)
  end

end
