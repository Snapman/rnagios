rnagios
=======

Ruby gem to make creating Nagios plugins easier

There are two types of checks you can perform that Nagios will process:
active and NSCA checks.  Active checks are run on the Nagios
monitoring host and actively check services.  NSCA checks are run
by remote hosts and their output is sent back to the ` host
for processing by the NSCA daemon.  Active checks are "actively" run
by Nagios; NSCA checks are "passively" run by other servers.

To create an active check, create logic that measures a service
(such as a database, a web service, or a custom application) and
returns a fully-populated ActiveStatus object.  By the same token,
to create an NSCA check, create logic that measures a service and
returns a fully-populated NscaHostStatus or NscaServiceStatus object.
(There are many gems available that can help you connect to services
and parse their output; this class does not attempt to be everything
to everyone.)
  
Plugin handles the formatting, and provides the appropriate
exit code so Nagios will process it correctly.  When running on
UNIX/Linux, Nagios will check the exit codes along with the string
in the status message to determine how to handle it.  Under Windows,
Nagios only cares about the strings in the status message.

Plugin allows you to use an optional configuration file in case your
plugin requires access to multiple configuration parameters.  If
you supply a configuration file, it should be a YAML file, and it will
be parsed in the check method before the measure method is called.
measure() can then use the @config attribute to access configuration
parameters.  The configuration file is expected to be in the same
directory as the plugin.
