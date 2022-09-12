# Copyright 2022 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.

module JamfRubyExtensions

  module IPAddr

    module Utils

      ### Convert starting and ending IPv4 IP addresses (either Strings or IPAddrs)
      ### into a single masked IPv4 IPAddr
      ###
      ### @param starting[Strings, IPAddr] the starting IP address
      ###
      ### @param ending[Strings, IPAddr] the ending IP address
      ###
      ### @return [IPAddr] the IP address range represented as a masked IPv4 address
      ###
      ### @example
      ###   IPAddr.j_masked_v4addr '10.0.0.0', '10.0.0.255' # => #<IPAddr: IPv4:10.0.0.0/255.255.255.0>
      ###
      def j_masked_v4addr(starting,ending)
        IPAddr.new "#{starting}/#{self.j_cidr_from_ends(starting,ending)}"
      end #self.j_masked_v4addr(starting,ending)
      alias jss_masked_v4addr j_masked_v4addr

      ### Given starting and ending IPv4 IP addresses (either Strings or IPAddrs)
      ### return the CIDR notation routing prefix mask
      ###
      ### @param starting[Strings, IPAddr] the starting IP address
      ###
      ### @param ending[Strings, IPAddr] the ending IP address
      ###
      ### @return [FixNum] the CIDR notation routing prefix mask
      ###
      ### @example
      ###   IPAddr.j_cidr_from_ends '10.0.0.0', '10.0.0.255' # => 24
      ###
      def j_cidr_from_ends(starting,ending)

        starting = IPAddr.new(starting) unless starting.kind_of? IPAddr
        ending = IPAddr.new(ending) unless ending.kind_of? IPAddr

        ### how many possible addresses in the range?
        num_addrs =  ending.to_i - starting.to_i + 1

        ### convert the number of possible addresses to
        ### binary then subtract the number of bits from
        ### the full length of an IPv4 addr
        ### (32 bits) and that gives the CIDR prefix
        return 32 - num_addrs.to_s(2).length + 1

      end #self.get_cidr(starting,ending)
      alias jss_cidr_from_ends j_cidr_from_ends

      ### Convert a starting address (either String or IPAddr) and a
      ### CIDR notation routing prefix mask into the IPv4 address
      ### of at the end of the range of addresses.
      ###
      ### @param starting[Strings, IPAddr] the starting IP address
      ###
      ### @param cidr[FixNum] the CIDR mask
      ###
      ### @return [IPAddr] the ending IP address of the range.
      ###
      ### @example
      ###   IPAddr.j_ending_address '10.0.0.0', 24 # => #<IPAddr: IPv4:10.0.0.255>
      ###
      def j_ending_address(starting, cidr)
        IPAddr.new( "#{starting}/#{cidr}").to_range.max
      end # ending_address
      alias jss_ending_address j_ending_address

    end # module

  end # module

end # module
