### Copyright 2017 Pixar

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

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Classes
  #####################################

  ###
  ### A Network Segment in the JSS
  ###
  ### @see JSS::APIObject
  ###
  class NetworkSegment  < JSS::APIObject

    #####################################
    ### Mix Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    include Comparable

    #####################################
    ### Class Constants
    #####################################

    ### the REST resource base
    RSRC_BASE = "networksegments"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :network_segments

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :network_segment

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:distribution_point, :starting_address, :override_departments ]

    #####################################
    ### Class Variables
    #####################################

    @@network_ranges = nil

    #####################################
    ### Class Methods
    #####################################

    ###
    ### All NetworkSegments in the jss as IPAddr objects representing the
    ### subnet as a masked IPv4 address.
    ###
    ### Using the #include? and #to_range methods on those
    ### objects is very useful.
    ###
    ### @return [Hash{Integer => IPAddr}] the network segments as masked IPv4 addresses
    ###
    def self.network_ranges(refresh = false)
      @@network_ranges = nil if refresh
      return @@network_ranges if @@network_ranges
      @@network_ranges = {}
      self.all.each{|ns| @@network_ranges[ns[:id]] =  IPAddr.jss_masked_v4addr(ns[:starting_address], ns[:ending_address])}
      @@network_ranges
    end # def network_segments

    ###
    ### An alias for {NetworkSegment.network_ranges}
    ###
    def self.subnets(refresh = false); self.network_ranges refresh; end

    ###
    ### Find the ids of the network segments that contain a given IP address.
    ###
    ### Even tho IPAddr.include? will take a String or an IPAddr
    ### I convert the ip to an IPAddr so that an exception will be raised if
    ### the ip isn't a valid ip.
    ###
    ### @param ip[String, IPAddr] the IP address to locate
    ###
    ### @return [Array<Integer>] the ids of the NetworkSegments containing the given ip
    ###
    def self.network_segment_for_ip(ip)
      ok_ip = IPAddr.new(ip)
      matches = []
      self.network_ranges.each{ |id, subnet| matches << id if subnet.include?(ok_ip) }
      matches
    end

    ###
    ### Find the current network segment ids for the machine running this code
    ###
    ### @return [Array<Integer>]  the NetworkSegment ids for this machine right now.
    ###
    def self.my_network_segment
      network_segment_for_ip JSS::Client.my_ip_address
    end



    #####################################
    ### Attributes
    #####################################


    ### @return [IPAddr] starting IP adresss
    attr_reader :starting_address

    ### @return [IPAddr] ending IP adresss
    attr_reader :ending_address

    ### @return [Integer] the CIDR
    attr_reader :cidr

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

    ### @return [String] the unique identifier for this subnet, regardless of the JSS id
    attr_reader :uid

    ### @return [IPAddr] the IPAddr object representing this network segment, created from the uid
    attr_reader :subnet

    ###
    ### @see APIObject#initialize
    ###
    def initialize(args = {} )

      super args

      if args[:id] == :new
        raise MissingDataError, "Missing :starting_address." unless args[:starting_address]
        raise MissingDataError, "Missing :ending_address or :cidr." unless args[:ending_address] or args[:cidr]
        @init_data[:starting_address] = args[:starting_address]
        @init_data[:ending_address] = args[:ending_address]
        @init_data[:cidr] = args[:cidr].to_i
      end

      @building = @init_data[:building]
      @department = @init_data[:department]
      @distribution_point = @init_data[:distribution_point]
      @netboot_server = @init_data[:netboot_server]
      @override_buildings = @init_data[:override_buildings]
      @override_departments = @init_data[:override_departments]
      @starting_address = IPAddr.new @init_data[:starting_address]
      @swu_server = @init_data[:swu_server]
      @url = @init_data[:url]

      ### by now, we must have either an ending address or a cidr
      ### along with a starting address, so figure out the other one.
      if @init_data[:ending_address]
        @ending_address = IPAddr.new @init_data[:ending_address]
        @cidr = IPAddr.jss_cidr_from_ends(@starting_address,@ending_address)
      else
        @cidr = @init_data[:cidr].to_i if @init_data[:cidr]
        @ending_address = IPAddr.jss_ending_address(@starting_address, @cidr)
      end # if args[:cidr]

      ### we now have all our data, make our unique identifier, the startingaddr/cidr
      @uid = "#{@starting_address}/#{@cidr}"

      ### the IPAddr object for this whole net segment
      @subnet = IPAddr.new @uid

    end #init

    ###
    ### Thanks to Comparable, we can tell if we're equal or not.
    ###
    ### See Comparable#<=>
    ###
    ### @return [-1,0,1] ar we less than, equal or greater than the other?
    ###
    def <=> (other)
      self.subnet <=> other.subnet
    end

    ###
    ### Set the building
    ###
    ### @param newval[String, Integer] the new building by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def building= (newval)
      new = JSS::Building.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No building matching '#{newval}'" unless new
      @building = new[:name]
      @need_to_update = true
    end

    ###
    ### set the override buildings option
    ###
    ### @param newval[Boolean] the new override buildings option
    ###
    ### @return [void]
    ###
    def override_buildings= (newval)
      raise JSS::InvalidDataError, "New value must be boolean true or false" unless JSS::TRUE_FALSE.include? newval
      @override_buildings = newval
      @need_to_update = true
    end

    ###
    ### set the department
    ###
    ### @param newval[String, Integer] the new dept by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def department= (newval)
      new = JSS::Department.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No department matching '#{newval}' in the JSS" unless new
      @department = new[:name]
      @need_to_update = true
    end

    ###
    ### set the override depts option
    ###
    ### @param newval[Boolean] the new setting
    ###
    ### @return [void]
    ###
    ###
    def override_departments= (newval)
      raise JSS::InvalidDataError, "New value must be boolean true or false" unless JSS::TRUE_FALSE.include? newval
      @override_departments = newval
      @need_to_update = true
    end

    ###
    ### set the distribution_point
    ###
    ### @param newval[String, Integer] the new dist. point by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def distribution_point= (newval)
      new = JSS::DistributionPoint.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No distribution_point matching '#{newval}' in the JSS" unless new
      @distribution_point = new[:name]
      @need_to_update = true
    end

    ###
    ### set the netboot_server
    ###
    ### @param newval[String, Integer] the new netboot server by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def netboot_server= (newval)
      new = JSS::NetbootServer.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No netboot_server matching '#{newval}' in the JSS" unless new
      @netboot_server = new[:name]
      @need_to_update = true
    end

    ###
    ### set the sw update server
    ###
    ### @param newval[String, Integer] the new server by name or id, must be in the JSS
    ###
    ### @return [void]
    ###
    def swu_server= (newval)
      new = JSS::SoftwareUpdateServer.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No swu_server matching '#{newval}' in the JSS" unless new
      @swu_server = new[:name]
      @need_to_update = true
    end

    ###
    ### set the starting address
    ###
    ### @param newval[String, IPAddr] the new starting address
    ###
    ### @return [void]
    ###
    def starting_address= (newval)
      @starting_address = IPAddr.new newval # this will raise an error if the IP addr isn't valid
      raise JSS::InvalidDataError, "New starting address #{@starting_address} is higher than ending address #{@ending_address}" if @starting_address > @ending_address
      @cidr = IPAddr.jss_cidr_from_ends(@starting_address ,@ending_address)
      @uid = "#{@starting_address}/#{@cidr}"
      @subnet = IPAddr.new @uid
      @need_to_update = true
    end

    ###
    ### set the ending address
    ###
    ### @param newval[String, IPAddr] the new ending address
    ###
    ### @return [void]
    ###
    def ending_address= (newval)
      @ending_address = IPAddr.new newval # this will raise an error if the IP addr isn't valid
      raise JSS::InvalidDataError, "New ending address #{@ending_address} is lower than starting address #{@starting_address}" if @ending_address < @starting_address
      @cidr = IPAddr.jss_cidr_from_ends(@starting_address,@ending_address)
      @uid = "#{@starting_address}/#{@cidr}"
      @subnet = IPAddr.new @uid
      @need_to_update = true
    end

    ###
    ### set the cidr
    ###
    ### @param newval[String, IPAddr] the new cidr
    ###
    ### @return [void]
    ###
    def cidr= (newval)
      @cidr = newval
      @ending_address = IPAddr.jss_ending_address(@starting_address, @cidr)
      @uid = "#{@starting_address}/#{@cidr}"
      @subnet = IPAddr.new @uid
      @need_to_update = true
    end

    ###
    ### is a given address in this network segment?
    ###
    ### @param some_addr[IPAddr,String] the IP address to check
    ###
    ### @return [Boolean]
    ###
    def include? (some_addr)
      @subnet.include?  IPAddr.new(some_addr)
    end


    ### aliases
    alias identifier uid
    alias range subnet

    ######################
    ### private methods
    private

    ###
    ### the xml formated data for adding or updating this in the JSS
    ###
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      ns = doc.add_element "network_segment"
      ns.add_element('building').text = @building
      ns.add_element('department').text = @department
      ns.add_element('distribution_point').text = @distribution_point
      ns.add_element('ending_address').text = @ending_address
      ns.add_element('name').text = @name
      ns.add_element('netboot_server').text = @netboot_server
      ns.add_element('override_buildings').text = @override_buildings
      ns.add_element('override_departments').text = @override_departments
      ns.add_element('starting_address').text = @starting_address
      ns.add_element('swu_server').text = @swu_server
      return doc.to_s
    end #rest_xml

  end # class NetworkSegment
end # module
