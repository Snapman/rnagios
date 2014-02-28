# Superclass for ActiveStatus, NscaHostStatus, and NscaServiceStatus
class Status

  # A Nagios::Status constant
  attr_reader :status
  # UNIX/Linux exit code
  attr_reader :exit_code
  # The status output from the measure() method
  attr_accessor :message

  # Formats the given message for output to Nagios
  def to_s
    @status = '' if @status.nil?
    @message = '' if @message.nil?
    @status + ': ' + @message
  end

  def empty?
    @status.nil? && @message.nil? && @exit_code.nil? && @status.empty? && @message.empty? && !@exit_code.is_a?(Integer)
  end

end
