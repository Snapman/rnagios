# Nsca adds a passive code to a Status object.  It is a
# module because NscaServiceStatus is essentially an ActiveStatus
# (with the same constants and methods) and cannot be represented
# by a NscaStatus object.
module Nsca

  # This attribute stands in for 'host status' in NscaHostStatus
  # and 'return_code' in NscaServerStatus
  attr_accessor :passive_code

end
