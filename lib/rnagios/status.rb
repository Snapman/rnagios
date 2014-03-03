# Superclass for ActiveStatus, NscaHostStatus, and NscaServiceStatus
class Status

  # A Nagios::Status constant
  attr_accessor :status
  # UNIX/Linux exit code
  attr_reader :exit_code
  # The status output from the measure() method
  attr_accessor :message

  def initialize(status=nil, message=nil)
    @status = status if !status.nil? && !status.empty?
    @message = message if !message.nil? && !message.empty?
    @exit_code = 0
  end

  # Formats the given message for output to Nagios
  def to_s
    @status = '' if @status.nil?
    @message = '' if @message.nil?
    @status + ': ' + @message
  end

  def empty?
    (@status.nil? && @message.nil?) || (@status.empty? && @message.empty?)
  end

end
