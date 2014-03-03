require 'rnagios/status'
require 'rnagios/active_status'
require 'rnagios/nsca_host_status'
require 'rnagios/nsca_service_status'
require 'rnagios/nagios_error'
require 'rnagios/plugin'

def blank?(value)
  value.nil? || value.empty?
end

# Check for Windows OS
def windows?
  (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
end

# Check for Mac OS
def mac?
 (/darwin/ =~ RUBY_PLATFORM) != nil
end

# Check for UNIX or UNIX-like OS
def unix?
  !OS.windows?
end

# Check for Linux
def linux?
  OS.unix? and not OS.mac?
end
