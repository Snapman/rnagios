class NagiosError < StandardError

  def initialize(message=nil)
    super(message) if !message.nil? && !message.empty?
  end

end
