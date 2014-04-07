# There are two types of checks you can perform that Nagios will process:
# active and NSCA checks.  Active checks are run on the Nagios
# monitoring host and actively check services.  NSCA checks are run
# by remote hosts and their output is sent back to the host
# for processing by the NSCA daemon.  Active checks are "actively" run
# by Nagios; NSCA checks are "passively" run by other servers.
#
# To create an active check, create logic that measures a service
# (such as a database, a web service, or a custom application) and
# returns a fully-populated ActiveStatus object.  By the same token,
# to create an NSCA check, create logic that measures a service and
# returns a fully-populated NscaHostStatus or NscaServiceStatus object.
# (There are many gems available that can help you connect to services
# and parse their output; this class does not attempt to be everything
# to everyone.)
#
# Plugin handles the formatting, and provides the appropriate
# exit code so Nagios will process it correctly.  When running on
# UNIX/Linux, Nagios will check the exit codes along with the string
# in the status message to determine how to handle it.  Under Windows,
# Nagios only cares about the strings in the status message.
#
# Plugin allows you to use an optional configuration file in case your
# plugin requires access to multiple configuration parameters.  If
# you supply a configuration file, it should be a YAML file, and it will
# be parsed in the check method before the measure method is called.
# measure() can then use the @config attribute to access configuration
# parameters.  The configuration file is expected to be in the same
# directory as the plugin.
class Plugin

  # Internal configuration access attribute
  attr_reader :config
  # Name of the plugin (e.g. check_service)
  attr_reader :name

  # Warning level
  attr_accessor :w
  # Critical level
  attr_accessor :c
  # Path to the configuration file
  attr_accessor :config_file
  # Name of host to check
  attr_accessor :host
  # Port of host to check (defaults to 80)
  attr_accessor :port
  # Set to true to use SSL
  attr_accessor :use_ssl
  # Whether we verify the host if using SSL to connect
  attr_accessor :verify_ssl

  # Plugin expects a hash with the following symbols:
  #   :host         # The hostname or IP address to check (required)
  #   :port         # The port on :host to check (default: 80)
  #   :name         # The name of the service, usually starting with 'check_' (default: <UNDEFINED>)
  #   :config_file  # Path to YAML configuration file (optional)
  #   :w            # Warning level (optional, usually numeric)
  #   :c            # Critical level (optional, usually numeric)
  #   :use_ssl      # True to use SSL, false otherwise (default: false)
  #   :verify_ssl   # If using SSL, set to true to verify the server (default: false)
  # :host must be provided, otherwise a NagiosError will be thrown.
  def initialize(params={})
    if !blank?(params)
      if params[:host].nil?
        raise NagiosError.new('Hostname must be provided')
      else
        @host = params[:host]
      end
      if params[:port].nil?
        @port = 80
      elsif params[:port].is_a?(String)
        begin
          @port = params[:port].to_i
        rescue
          raise NagiosError.new('Port number must be numeric')
        end
      else
        @port = params[:port]
      end
      @name = default(params[:name])
      @config_file = params[:config_file] if !params[:config_file].nil?
      @w = params[:w] if !params[:w].nil?
      @c = params[:c] if !params[:c].nil?
      if !params[:use_ssl].nil?
        @use_ssl = params[:use_ssl]
      else
        @use_ssl = false
      end
      if !params[:verify_ssl].nil?
        @verify_ssl = params[:verify_ssl]
      else
        @verify_ssl = false
      end
    else
      raise NagiosError.new('At least hostname must be provided')
    end
  end

  # The name of the Plugin.  This should conform to the Nagios
  # convention of "check_<service>" as the name of the script to
  # run.  The name can have extensions such as ".py" or ".rb";
  # they will be stripped off.  This name will show up in capital
  # letters as the service name in Nagios status information columns
  def name=(value)
    @name = default(value)
  end

  # Returns a Status with the message to print to STDOUT
  # and an exit code to return if running under UNIX/Linux. If
  # the measure method throws an exception or the status object
  # is not a properly-populated Status object, then this method
  # will throw a NagiosError.
  #
  # This method will run the user-overloaded measure() method.  If
  # measure() should return an uncaught exception, the exception
  # message will be returned to Nagios as an UNKNOWN status, so
  # make sure to handle all known error conditions within measure()
  # to make the output of your script meaningful.
  #
  # Scripts should call this method at the very end.  The general
  # flow of a script running on UNIX/Linux should be as follows:
  #
  #   class MyCheck < Plugin
  #     def measure
  #       stat = ActiveStatus.new
  #       stat.status = <...service check code goes here, returns Nagios::Status::<constant> status...>
  #       stat.message = <...service message state construction goes here...>
  #       # UNIX/Linux exit codes are taken core of for you
  #     end
  #   end
  #
  #   plugin = MyCheck.new( { :name => 'check_service', :host = '<my_host>', :w => 15, :c => 5 })
  #   status = plugin.check
  #   $stdout.puts status.message  # status.message needs to be output to STDOUT
  #   exit status.exit_code  # For UNIX/Linux
  #
  # It is up to the developer to handle command-line arguments.
  # (See the trollop gem for a good example of command-line parameter
  # hadling.)  Nagios plugins usually accept "w" as a warning level and "c"
  # as a critical level, but it is up to the plugin developer if
  # these values are used in the measure method.
  def check
    start_time = Time.now
    end_time = -1
    status = nil

    # If there is a config file, load it
    if !blank? @config_file
      begin
        @config = YAML.load_file(@config_file)
      rescue Psych::SyntaxError => e
        raise NagiosError.new('Error occurred while trying to parse YAML config file; please verify that config file is valid YAML')
      end
    end

    # measure() is where the magic happens.  measure() should
    # return a Status object.  Any exceptions thrown
    # in measure() drop right out, so make sure you handle all
    # error conditions appropriately before using your plugin
    # with Nagios
    status = measure

    # Mark the end time for Nagios performance stats
    end_time = Time.now
    time_took = end_time - start_time

    # Since we can't effectively check for exceptions, we make
    # sure we get a good Status
    if !valid?(status)
      raise NagiosError.new('Returned status must be an instance or subclass of Status')
    elsif !valid_status?(status)
      raise NagiosError.new('Status must have be a valid status constant')
    elsif status.is_a?(NscaHostStatus) && !valid_passive_code?(status)
      raise NagiosError.new('Status passive code is invalid')
    elsif status.is_a? ActiveStatus
      if status.is_a? NscaServiceStatus
        if !valid_passive_code? status
          raise NagiosError.new('Status passive code is invalid')
        end
      elsif !valid_exit_code? status
        raise NagiosError.new('Status exit code is invalid')
      end
    elsif blank?(status.message)
      raise NagiosError.new('Status message must not be nil or empty')
    end

    # Status checks out as valid -- we now check the warning and critical
    # times and format the output based on the type of Status received
    if status.is_a? NscaHostStatus
      status.message = format_passive_host_check(status)
    elsif status.is_a? NscaServiceStatus
      if valid_value_w && valid_value_c
        if time_took >= @w && time_took < @c && status.status != ActiveStatus::WARNING
          status.status = ActiveStatus::WARNING
          status.message += '; check time >= ' + @w.to_s
        elsif time_took >= @c && status.status != ActiveStatus::CRITICAL
          status.status = ActiveStatus::CRITICAL
          status.message += '; check time >= ' + @c.to_s
        end
      end
      status.message = format_passive_service_check(status)
    else
      if valid_value_w && valid_value_c
        if time_took >= @w && time_took < @c && status.status != ActiveStatus::WARNING
          status.status = ActiveStatus::WARNING
          status.message += '; check time >= ' + @w.to_s
        elsif time_took >= @c && status.status != ActiveStatus::CRITICAL
          status.status = ActiveStatus::CRITICAL
          status.message += '; check time >= ' + @c.to_s
        end
      end
      status.message = format_active_service_check(status, start_time, end_time)
    end

    status
  end

  # This method should be overloaded by classes that subclass
  # Plugin.  For active checks, measure() should return an
  # ActiveStatus object.  For passive checks, measure()
  # should return a NscaHostStatus or NscaServiceStatus
  # object.
  #
  # The developer must determine how to best check the
  # service in question.  Below is an example of how measure()
  # should be structured.
  #
  #   status = ''
  #   message = ''
  #   begin
  #     random_measure = 1 + rand(4) # Bad real-world event simulator
  #     if random_measure == 1
  #       status = ActiveStatus::OK
  #       message = 'Everything looks good'
  #     elsif random_measure == 2
  #       status = ActiveStatus::WARNING
  #       message = 'Keep an eye on this service'
  #     elsif random_measure == 3
  #       status = ActiveStatus::CRITICAL
  #       message = 'There''s a problem'
  #     else
  #       status = ActiveStatus::UNKNOWN
  #       message = 'Can''t figure out what''s going on'
  #     end
  #   rescue StandardError => e
  #     # You should decide what kind of status to return in case
  #     # of an error.  You should not let errors go unhandled in
  #     # a Nagios plugin, otherwise Nagios will handle it as a
  #     # failure and you may be spammed with unnecessary notifications
  #     # for something that should only merit a warning
  #     status = ActiveStatus::WARNING
  #     message = 'Possibly recoverable error occurred'
  #   rescue Exception => e
  #     # It is wise to account for exceptions you don't anticipate
  #     # and create a status that is more meaningful for your service.
  #     # For your situation, unanticipated errors may be critical, or
  #     # they may be worth only a warning; you decide
  #     status = ActiveStatus::CRITICAL
  #     message = 'Something we didn''t anticipate occurred'
  #   ensure
  #     # Make sure the returned status has something in it if all else fails
  #     status = ActiveStatus::UNKNOWN
  #     message = 'Don''t know what happened'
  #   end
  #   ActiveStatus.new(status, message)
  def measure
    # Overload this method to populate the status object
    raise NagiosError.new('Call to measure should not invoke base class measure method; measure method should be overridden')
  end

private
    # This method uses the value of @name to create a default.
    # As long as the name sticks to the Nagios convention of
    # "check_<service>", this method can make a good guess as
    # to the default it should create
    def default(value=nil)
      if !blank? value
        if value.downcase.include? 'check_'
          value.downcase.gsub('check_', '').upcase
        else
          value.upcase
        end
      elsif blank?(value) && !blank?(@name)
        @name.downcase.gsub('check_', '').upcase
      else
        '<UNDEFINED>'
      end
    end

    def format_active_service_check(status, start_time, end_time)
      @name + ' ' + status.to_s + ' | time=' + (end_time - start_time).to_s + ';;;' + @w.to_s + ';' + @c.to_s
    end

    # NSCA check results are different from active check results
    # [<timestamp>] PROCESS_SERVICE_CHECK_RESULT;<host_name>;<svc_description>;<return_code>;<plugin_output>
    def format_passive_service_check(status)
      "#{@host}\t#{@name}\t#{status.passive_code}\t#{status.message}"
    end

    # NSCA check results are different from active check results
    # [<timestamp>] PROCESS_HOST_CHECK_RESULT;<host_name>;<host_status>;<plugin_output>
    def format_passive_host_check(status)
      "#{@host}\t#{status.passive_code}\t#{status.message}"
    end

    def valid?(status)
      blank?(status) || !status.is_a?(Status) ? false : true
    end

    def valid_status?(status)
      if blank?(status) || blank?(status.status) || !status.status.is_a?(String)
        false
      elsif status.is_a?(ActiveStatus) || status.is_a?(NscaServiceStatus)
        case status.status
        when ActiveStatus::OK
          true
        when ActiveStatus::WARNING
          true
        when ActiveStatus::UNKNOWN
          true
        when ActiveStatus::CRITICAL
          true
        else
          false
        end
      elsif status.is_a? NscaHostStatus
        case status.status
        when NscaHostStatus::UP
          true
        when NscaHostStatus::DOWN
          true
        when NscaHostStatus::UNREACHABLE
          true
        else
          false
        end
      end
    end

    def valid_exit_code?(status)
      if blank?(status) || !status.exit_code.is_a?(Integer) || !status.is_a?(ActiveStatus)
        false
      else
        case status.exit_code
        when ActiveStatus::OK_EXIT_CODE
          true
        when ActiveStatus::WARNING_EXIT_CODE
          true
        when ActiveStatus::UNKNOWN_EXIT_CODE
          true
        when ActiveStatus::CRITICAL_EXIT_CODE
          true
        else
          false
        end
      end
    end

    def valid_passive_code?(status)
      if blank?(status) || !status.passive_code.is_a?(Integer)
        false
      elsif status.is_a?(NscaServiceStatus)
        case status.passive_code
        when ActiveStatus::OK_EXIT_CODE
          true
        when ActiveStatus::WARNING_EXIT_CODE
          true
        when ActiveStatus::UNKNOWN_EXIT_CODE
          true
        when ActiveStatus::CRITICAL_EXIT_CODE
          true
        else
          false
        end
      elsif status.is_a?(NscaHostStatus)
        case status.passive_code
        when NscaHostStatus::UP_CODE
          true
        when NscaHostStatus::DOWN_CODE
          true
        when NscaHostStatus::UNREACHABLE_CODE
          true
        else
          false
        end
      else
        false
      end
    end

    def valid_value_w()
      @w.is_a?(Integer) && @w > 0
    end

    def valid_value_c()
      @c.is_a?(Integer) && @c > 0
    end
end
