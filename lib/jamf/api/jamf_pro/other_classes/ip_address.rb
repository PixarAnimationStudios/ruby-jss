# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# The module
module Jamf

  # handle nils and IPAddrs

  # A wrapper for IPAddr - allowing initialize to take an unused cnx:
  # and providing #to_jamf
  #
  class IPAddress < IPAddr

    # @param an_ip[String,IPAddr]
    #
    # @param cnx [void] unused, but required
    #
    def initialize(an_ip)
      if an_ip.nil?
        @empty_ip = true
        return
      end

      super an_ip
    end

    # @return [String] the IP formatted for passing to the API as a string.
    #
    def to_jamf
      return Jamf::BLANK if @empty_ip

      to_s
    end

  end # class  Timestamp

end # module
