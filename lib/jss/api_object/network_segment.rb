### Copyright 2019 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
module JSS

  ### Module Variables
  #####################################

  ### Module Methods
  #####################################

  ### Classes
  #####################################

  ### A Network Segment in the JSS
  ###
  ###
  class NetworkSegment < JSS::APIObject

    ### Mix Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    include Comparable

    ### Class Constants
    #####################################

    ### the REST resource base
    RSRC_BASE = 'networksegments'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :network_segments

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :network_segment

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 43

    ### Class Methods
    #####################################

    ### All NetworkSegments in the jss as IPAddr object Ranges representing the
    ### Segment, e.g. with starting = 10.24.9.1 and ending = 10.24.15.254
    ### the range looks like:
    ###   <IPAddr: IPv4:10.24.9.1/255.255.255.255>..#<IPAddr: IPv4:10.24.15.254/255.255.255.255>
    ###
    ### Using the #include? method on those Ranges is very useful.
    ###
    ### @param refresh[Boolean] re-read the data from the API?
    ###
    ### @param api[JSS::APIConnection] The API connection to query
    ###
    ### @return [Hash{Integer => Range}] the network segments as IPv4 address Ranges
    ###
    def self.network_ranges(refresh = false, api: JSS.api)
      api.network_ranges refresh
    end # def network_segments

    ### An alias for {NetworkSegment.network_ranges}
    ###
    ### DEPRECATED: This will be going away in a future release.
    ###
    ### @see {NetworkSegment::network_ranges}
    ###
    def self.subnets(refresh = false, api: JSS.api)
      network_ranges refresh, api: api
    end

    ### Given a starting address & ending address, mask, or cidr,
    ### return a Range object of IPAddr objects.
    ###
    ### starting_address: must be provided, and may be a masked address,
    ### in which case nothing else is needed.
    ###
    ### If starting_address: is an unmasked address, then one of ending_address:
    ### cidr: or mask: must be provided.
    ###
    ### If given, ending_address: overrides mask:, cidr:, and a masked starting_address:
    ###
    ### These give the same result:
    ###
    ### ip_range starting_address: '192.168.1.0', ending_address: '192.168.1.255'
    ### ip_range starting_address: '192.168.1.0', mask: '255.255.255.0'
    ### ip_range starting_address: '192.168.1.0', cidr: 24
    ### ip_range starting_address: '192.168.1.0/24'
    ### ip_range starting_address: '192.168.1.0/255.255.255.0'
    ###
    ### All the above will produce:
    ###    #<IPAddr: IPv4:192.168.1.0/255.255.255.255>..#<IPAddr: IPv4:192.168.1.255/255.255.255.255>
    ###
    ### An exception is raised if the starting address is above the ending address.
    ###
    ### @param starting_address[String] The starting address, possibly masked
    ###
    ### @param ending_address[String] The ending address. If given, it overrides mask:,
    ###  cidr: and a masked starting_address:
    ###
    ### @param mask[String] The subnet mask to apply to the starting address to get
    ###   the ending address
    ###
    ### @param cidr[String, Integer] he cidr value to apply to the starting address to get
    ###   the ending address
    ###
    ### @return [Range<IPAddr>] the valid Range
    ###
    def self.ip_range(starting_address: nil, ending_address: nil, mask: nil, cidr: nil)
      raise JSS::MissingDataError, 'starting_address: must be provided' unless starting_address

      starting_address = masked_starting_address(starting_address: starting_address, mask: mask, cidr: cidr)

      if ending_address
        startip = IPAddr.new starting_address.split('/').first
        endip = IPAddr.new ending_address.to_s
        validate_ip_range(startip, endip)
      else
        raise ArgumentError, 'Must provide ending_address:, mask:, cidr: or a masked starting_address:' unless starting_address.include? '/'
        subnet = IPAddr.new starting_address
        startip = subnet.to_range.first.mask 32
        endip = subnet.to_range.last.mask 32
      end

      startip..endip
    end

    ### If we are given a mask or cidr, append them to the starting_address
    ###
    ### @param starting[String] The starting address, possibly masked
    ###
    ### @param mask[String] The subnet mask to apply to the starting address to get
    ###   the ending address
    ###
    ### @param cidr[String, Integer] he cidr value to apply to the starting address to get
    ###   the ending address
    ###
    ### @return [String] the starting with the mask or cidr appended
    ###
    def self.masked_starting_address(starting_address: nil, mask: nil, cidr: nil)
      starting_address = "#{starting}/#{mask || cidr}" if mask || cidr
      starting_address.to_s
    end

    ### Raise an exception if a given starting ip is higher than a given ending ip
    ###
    ### @param startip[String] The starting ip
    ###
    ### @param endip[String] The ending ip
    ###
    ### @return [void]
    ###
    def self.validate_ip_range(startip, endip)
      return nil if IPAddr.new(startip.to_s) <= IPAddr.new(endip.to_s)

      raise JSS::InvalidDataError, "Starting IP #{startip} is higher than ending ip #{endip} "
    end

    ### Find the ids of the network segments that contain a given IP address.
    ###
    ### Even tho IPAddr.include? will take a String or an IPAddr
    ### I convert the ip to an IPAddr so that an exception will be raised if
    ### the ip isn't a valid ip.
    ###
    ### @param ip[String, IPAddr] the IP address to locate
    ###
    ### @param refresh[Boolean] should the data be re-queried?
    ###
    ### @param api[JSS::APIConnection] The API connection to query
    ###
    ### @return [Array<Integer>] the ids of the NetworkSegments containing the given ip
    ###
    def self.network_segments_for_ip(ip, refresh = false, api: JSS.api)
      ok_ip = IPAddr.new(ip)
      matches = []
      network_ranges(refresh, api: api).each { |id, subnet| matches << id if subnet.include?(ok_ip) }
      matches
    end

    # @deprecated use network_segments_for_ip
    # Here for Backward compatibility
    def self.network_segment_for_ip(ip, api: JSS.api)
      network_segments_for_ip(ip, api: api)
    end

    ### Find the current network segment ids for the machine running this code
    ###
    ### @return [Array<Integer>] the NetworkSegment ids for this machine right now.
    ###
    def self.my_network_segments(refresh = false, names: false, api: JSS.api)
      ids = network_segments_for_ip JSS::Client.my_ip_address, refresh, api: api
      return ids unless names

      ids_to_names = map_all_ids_to :name
      ids.map { |id| ids_to_names[id] }
    end

    # @deprecated use my_network_segments
    # Here for backward compatibility
    def self.my_network_segment(api: JSS.api)
      my_network_segments api: api
    end

    # All NetworkSegments in the given API as IPAddr object Ranges representing the
    # Segment, e.g. with starting = 10.24.9.1 and ending = 10.24.15.254
    # the range looks like:
    #   <IPAddr: IPv4:10.24.9.1/255.255.255.255>..#<IPAddr: IPv4:10.24.15.254/255.255.255.255>
    #
    # Using the #include? method on those Ranges is very useful.
    #
    # @param refresh[Boolean] should the data be re-queried?
    #
    # @param api[JSS::APIConnection] the API to query
    #
    # @return [Hash{Integer => Range}] the network segments as IPv4 address Ranges
    #   keyed by id
    #
    def self.network_ranges(refresh = false, api: JSS.api)
      @network_ranges = nil if refresh
      return @network_ranges if @network_ranges
      @network_ranges = {}
      all(refresh, api: api).each do |ns|
        @network_ranges[ns[:id]] = IPAddr.new(ns[:starting_address])..IPAddr.new(ns[:ending_address])
      end
      @network_ranges
    end # def network_segments

    ### Attributes
    #####################################

    ### @return [IPAddr] starting IP adresss
    attr_reader :starting_address

    ### @return [IPAddr] ending IP adresss
    attr_reader :ending_address

    ### @return [String] building for this segment. Must be one of the buildings in the JSS
    attr_reader :building

    ### @return [String] department for this segment. Must be one of the depts in the JSS
    attr_reader :department

    ### @return [String] the name of the distribution point to be used from this network segment
    attr_reader :distribution_point

    ### @return [String] the mount url for the distribution point
    attr_reader :url

    ### @return [String] the netboot server for this segment
    attr_reader :netboot_server

    ### @return [String] the swupdate server for this segment.
    attr_reader :swu_server

    ### @return [Boolean] should machines checking in from this segment update their dept
    attr_reader :override_departments

    ### @return [Boolean] should machines checking in from this segment update their building
    attr_reader :override_buildings

    ### Instantiate a NetworkSegment
    ###
    ### @see_also JSS::NetworkSegment.ip_range for how starting and ending
    ### addresses can be provided when using id: :new
    ###
    def initialize(args = {})
      super args

      if args[:id] == :new
        range = self.class.ip_range(
          starting_address: args[:starting_address],
          ending_address: args[:ending_address],
          mask: args[:mask],
          cidr: args[:cidr]
        )
        @init_data[:starting_address] = range.begin.to_s
        @init_data[:ending_address] = range.end.to_s
      end

      @starting_address = IPAddr.new @init_data[:starting_address]
      @ending_address = IPAddr.new @init_data[:ending_address]

      @building = @init_data[:building]
      @department = @init_data[:department]
      @distribution_point = @init_data[:distribution_point]
      @netboot_server = @init_data[:netboot_server]
      @override_buildings = @init_data[:override_buildings]
      @override_departments = @init_data[:override_departments]
      @swu_server = @init_data[:swu_server]
      @url = @init_data[:url]
    end # init

    ### a Range built from the start and end addresses.
    ### To be used for finding inclusion and overlaps.
    ###
    ### @return [Range<IPAddr>] the range of IPAddrs for this segment.
    ###
    def range
      @starting_address..@ending_address
    end

    ### Does this network segment overlap with another?
    ###
    ### @param other_segment[JSS::NetworkSegment] the other segment to check
    ###
    ### @return [Boolean] Does the other segment overlap this one?
    ###
    def overlap?(other_segment)
      raise TypeError, 'Argument must be a JSS::NetworkSegment' unless \
        other_segment.is_a? JSS::NetworkSegment
      other_range = other_segment.range
      range.include?(other_range.begin) || range.include?(other_range.end)
    end

    ### Does this network segment include an address or another segment?
    ### Inclusion means the other is completely inside this one.
    ###
    ### @param thing[JSS::NetworkSegment, String, IPAddr] the other thing to check
    ###
    ### @return [Boolean] Does this segment include the other?
    ###
    def include?(thing)
      if thing.is_a? JSS::NetworkSegment
        @starting_address <= thing.range.begin && @ending_address >= thing.range.end
      else
        thing = IPAddr.new thing.to_s
        range.include? thing
      end
    end

    ### Does this network segment equal another?
    ### equality means the ranges are equal
    ###
    ### @param other_segment[JSS::NetworkSegment] the other segment to check
    ###
    ### @return [Boolean] Does this segment include the other?
    ###
    def ==(other)
      raise TypeError, 'Argument must be a JSS::NetworkSegment' unless \
        other.is_a? JSS::NetworkSegment
      range == other.range
    end

    ### Set the building
    ###
    ### @param newval[String, Integer] the new building by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def building=(newval)
      new = JSS::Building.all.select { |b| (b[:id] == newval) || (b[:name] == newval) }[0]
      raise JSS::MissingDataError, "No building matching '#{newval}'" unless new
      @building = new[:name]
      @need_to_update = true
    end

    ### set the override buildings option
    ###
    ### @param newval[Boolean] the new override buildings option
    ###
    ### @return [void]
    ###
    def override_buildings=(newval)
      raise JSS::InvalidDataError, 'New value must be boolean true or false' unless JSS::TRUE_FALSE.include? newval
      @override_buildings = newval
      @need_to_update = true
    end

    ### set the department
    ###
    ### @param newval[String, Integer] the new dept by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def department=(newval)
      new = JSS::Department.all.select { |b| (b[:id] == newval) || (b[:name] == newval) }[0]
      raise JSS::MissingDataError, "No department matching '#{newval}' in the JSS" unless new
      @department = new[:name]
      @need_to_update = true
    end

    ### set the override depts option
    ###
    ### @param newval[Boolean] the new setting
    ###
    ### @return [void]
    ###
    ###
    def override_departments=(newval)
      raise JSS::InvalidDataError, 'New value must be boolean true or false' unless JSS::TRUE_FALSE.include? newval
      @override_departments = newval
      @need_to_update = true
    end

    ### set the distribution_point
    ###
    ### @param newval[String, Integer] the new dist. point by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def distribution_point=(newval)
      new = JSS::DistributionPoint.all.select { |b| (b[:id] == newval) || (b[:name] == newval) }[0]
      raise JSS::MissingDataError, "No distribution_point matching '#{newval}' in the JSS" unless new
      @distribution_point = new[:name]
      @need_to_update = true
    end

    ### set the netboot_server
    ###
    ### @param newval[String, Integer] the new netboot server by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def netboot_server=(newval)
      new = JSS::NetbootServer.all.select { |b| (b[:id] == newval) || (b[:name] == newval) }[0]
      raise JSS::MissingDataError, "No netboot_server matching '#{newval}' in the JSS" unless new
      @netboot_server = new[:name]
      @need_to_update = true
    end

    ### set the sw update server
    ###
    ### @param newval[String, Integer] the new server by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def swu_server=(newval)
      new = JSS::SoftwareUpdateServer.all.select { |b| (b[:id] == newval) || (b[:name] == newval) }[0]
      raise JSS::MissingDataError, "No swu_server matching '#{newval}' in the JSS" unless new
      @swu_server = new[:name]
      @need_to_update = true
    end

    ### set the starting address
    ###
    ### @param newval[String, IPAddr] the new starting address
    ###
    ### @return [void]
    ###
    def starting_address=(newval)
      self.class.validate_ip_range(newval, @ending_address)
      @starting_address = IPAddr.new newval.to_s
      @need_to_update = true
    end

    ### set the ending address
    ###
    ### @param newval[String, IPAddr] the new ending address
    ###
    ### @return [void]
    ###
    def ending_address=(newval)
      self.class.validate_ip_range(@starting_address, newval)
      @ending_address = IPAddr.new newval.to_s
      @need_to_update = true
    end

    ### set the ending address by applying a new cidr (e.g. 24)
    ### or mask (e.g. 255.255.255.0)
    ###
    ### @param newval[String, Integer] the new cidr or mask
    ###
    ### @return [void]
    ###
    def cidr=(newval)
      new_end = IPAddr.new("#{@starting_address}/#{newval}").to_range.end.mask 32
      self.class.validate_ip_range(@starting_address, new_end)
      @ending_address = new_end
      @need_to_update = true
    end

    ### set a new starting and ending addr at the same time.
    ###
    ### @see_also NetworkSegment.ip_range for how to specify the starting
    ### and ending addresses.
    ###
    ### @param starting_address[String] The starting address, possibly masked
    ###
    ### @param ending_address[String] The ending address
    ###
    ### @param mask[String] The subnet mask to apply to the starting address to get
    ###   the ending address
    ###
    ### @param cidr[String, Integer] he cidr value to apply to the starting address to get
    ###   the ending address
    ###
    ### @return [void]
    ###
    def set_ip_range(starting_address: nil, ending_address: nil, mask: nil, cidr: nil)
      range = self.class.ip_range(
        starting_address: starting_address,
        ending_address: ending_address,
        mask: mask,
        cidr: cidr
      )
      @starting_address = range.first
      @ending_address = range.last
      @need_to_update = true
    end

    ### aliases
    ######################
    alias mask= cidr=
    alias to_range range

    ### private methods
    ######################
    private

    ### the xml formated data for adding or updating this in the JSS
    ###
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      ns = doc.add_element 'network_segment'
      ns.add_element('building').text = @building
      ns.add_element('department').text = @department
      ns.add_element('distribution_point').text = @distribution_point
      ns.add_element('ending_address').text = @ending_address.to_s
      ns.add_element('name').text = @name
      ns.add_element('netboot_server').text = @netboot_server
      ns.add_element('override_buildings').text = @override_buildings
      ns.add_element('override_departments').text = @override_departments
      ns.add_element('starting_address').text = @starting_address.to_s
      ns.add_element('swu_server').text = @swu_server
      doc.to_s
    end # rest_xml

  end # class NetworkSegment

end # module
