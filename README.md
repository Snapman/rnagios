rnagios
=======
[![Gem Version](https://badge.fury.io/rb/rnagios.png)](http://badge.fury.io/rb/rnagios)

Ruby gem to make creating Nagios plugins easier

RNagios provides a framework to create Nagios monitoring plugins faster
and with less hassle.  In addition to using an optional configuration
file for more complicated status checks, RNagios handles the output
format that Nagios expects, calculates the time elapsed during checks,
and provides appropriate exit codes (for UNIX/Linux) so Nagios will
process it correctly.  RNagios can help you focus on the logic of the
check you are creating rather than the minutae of the Nagios plugin
creation process.

[How to use RNagios](https://github.com/Snapman/rnagios/wiki/RNagios)
