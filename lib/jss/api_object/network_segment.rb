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
  ### A 'network segment' in the JSS
  ###
  ### These are used in the JSS for scoping policies and other management activites.
  ### This class will mostly be used by the scripts that keep the JSS network segments
  ### in sync with the canonical document defining them in our wiki,
  ### http://wiki.pixar.com/display/SYS/NetworkNetblocks
  ###
  ### For initialization, the args are a hash. If the hash has only one member, it must
  ### be either :name (a string), :starting_addrees (a string containing an IP address) or :id (an integer).
  ###
  ### If more than one member of the hash is provided, all data must be present
  ### and must include, minimally, :name, :starting_address & :ending_address or :cidr. The
  ### instance is built from the provided data and the JSS is not queried.
  ###
  ### Optional keys are :building, :department, :distribution_point, :netboot_server,
  ### :swu_server, :override_departments, :override_buildings
  ###
  ### See also JSS::APIObject
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
    ### Return a hash of all NetworkSegments in the jss,
    ### Key is jss ID, value is an IPAddr object representing the
    ### subnet as a masked IPv4 address.
    ### Using the #include? and #to_range methods on those
    ### objects is very useful.
    ###
    def self.network_ranges(refresh = false)
      @@network_ranges = nil if refresh
      return @@network_ranges if @@network_ranges
      @@network_ranges = {}
      self.all.each{|ns| @@network_ranges[ns[:id]] =  IPAddr.masked_v4addr(ns[:starting_address], ns[:ending_address])}
      @@network_ranges
    end # def network_segments
    def self.subnets(refresh = false); self.network_ranges refresh; end

    ###
    ### return the id of the network segment that contains the given IP address
    ### or nil if none found.
    ### Even tho IPAddr.include? will take a String or an IPAddr
    ### I convert the ip to an IPAddr so that an exception will be raised if
    ### the ip isn't a valid ip.
    ###
    def self.network_segment_for_ip(ip)
      self.network_ranges.each{ |id, subnet| return id if subnet.include?(IPAddr.new(ip)) }
      nil
    end

    ###
    ### return the network segment id (or nil) for the machine running this code
    ###
    def self.my_network_segment
      net_segment_for_ip JSS.my_ip_address
    end



    #####################################
    ### Attributes
    #####################################


    ### IPAddr - starting IP adresss
    attr_reader :starting_address

    ### IPAddr - ending IP adresss
    attr_reader :ending_address

    ### Integer - the CIDR
    attr_reader :cidr

    ### String - building for this segment. Must be one of the buildings in the JSS
    attr_reader :building

    ### String - department for this segment. Must be one of the depts in the JSS
    attr_reader :department

    ### String - the name of the distribution point to be used from this network segment
    attr_reader :distribution_point

    ### String - the mount url for the distribution point
    attr_reader :url

    ### String - the netboot server for this segment
    attr_reader :netboot_server

    ### String - the swupdate server for this segment.
    attr_reader :swu_server

    ### Boolean - should machines checking in from this segment update their dept
    attr_reader :override_departments

    ### Boolean - should machines checking in from this segment update their building
    attr_reader :override_buildings

    ### String - the unique identifier for this subnet, regardless of the JSS id
    attr_reader :uid
    alias identifier uid

    ### IPAddr - the IPAddr object representing this network segment
    attr_reader :subnet


    ###
    ### Initialization takes a hash requireing at least :name, :id, or :data
    ### To look up an existing object, use :name or :id
    ### If you have the JSON data from a previous API lookup (in a hash)
    ### provide it with :data => <JSONdata>
    ###
    ### To create a new net segment in the JSS use :id => :new and also provide
    ### :name, :starting_address, and either :ending_address or :cidr
    ###
    def initialize(args = {} )

      super args

      if args[:id] == :new
        raise MissingDataError, "Missing :starting_address." unless args[:starting_address]
        raise MissingDataError, "Missing :ending_address or :cidr." unless args[:ending_address] or args[:cidr]
        @init_data[:starting_address] = args[:starting_address]
        @init_data[:ending_address] = args[:ending_address]
        @init_data[:cidr] = args[:cidr]
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
      if data[:ending_address]
        @ending_address = IPAddr.new @init_data[:ending_address]
        @cidr = IPAddr.cidr_from_ends(@starting_address,@ending_address)
      else
        @cidr = data[:cidr].to_i if @init_data[:cidr]
        @ending_address = IPAddr.ending_address(@starting_address, @cidr)
      end # if args[:cidr]

      ### we now have all our data, make our unique identifier, the startingaddr/cidr
      @uid = "#{@starting_address}/#{@cidr}"

      ### the IPAddr object for this whole net segment
      @subnet = IPAddr.new @uid

    end #init

    ###
    ### Thanks to comparable, we can tell if we're equal or not.
    ###
    def <=>(other)
      self.subnet <=> other.subnet
    end

    ###
    ### set the building, arg is a name or id of a building in the jss
    ###
    def building= (newval)
      new = JSS::Building.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No building matching '#{newval}'" unless new
      @building = new[:name]
      @needs_update = true
    end

    ###
    ### set the department, arg is a name or id of a department in the jss
    ###
    def department= (newval)
      new = JSS::Department.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No department matching '#{newval}' in the JSS" unless new
      @department = new[:name]
      @needs_update = true
    end

    ###
    ### set the distribution_point, arg is a name or id of a distribution_point in the jss
    ###
    def distribution_point= (newval)
      new = JSS::DistributionPoint.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No distribution_point matching '#{newval}' in the JSS" unless new
      @distribution_point = new[:name]
      @needs_update = true
    end

    ###
    ### set the netboot_server, arg is a name or id of a netboot_server in the jss
    ###
    def netboot_server= (newval)
      new = JSS::NetbootServer.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No netboot_server matching '#{newval}' in the JSS" unless new
      @netboot_server = new[:name]
      @needs_update = true
    end

    ###
    ### set the netboot_server, arg is a name or id of a netboot_server in the jss
    ###
    def swu_server= (newval)
      new = JSS::SoftwareUpdateServer.all.select{|b| b[:id] == newval or b[:name] == newval }[0]
      raise JSS::MissingDataError, "No swu_server matching '#{newval}' in the JSS" unless new
      @swu_server = new[:name]
      @needs_update = true
    end

    ###
    ### reset the starting address
    ###
    def starting_address= (newval)
      @starting_address = IPAddr.new newval # this will raise an error if the IP addr isn't valid
      raise JSS::InvalidDataError, "New starting address #{@starting_address} is higher than ending address #{@ending_address}" if @starting_address > @ending_address
      @cidr = IPAddr.cidr_from_ends(@starting_address ,@ending_address)
      @uid = "#{@starting_address}/#{@cidr}"
      @subnet = IPAddr.new @uid
      @needs_update = true
    end

    ###
    ### reset the ending address
    ###
    def ending_address= (newval)
      @ending_address = IPAddr.new newval # this will raise an error if the IP addr isn't valid
      raise JSS::InvalidDataError, "New ending address #{@ending_address} is lower than starting address #{@starting_address}" if @ending_address < @starting_address
      @cidr = IPAddr.cidr_from_ends(@starting_address,@ending_address)
      @uid = "#{@starting_address}/#{@cidr}"
      @subnet = IPAddr.new @uid
      @needs_update = true
    end

    ###
    ### reset the cidr
    ###
    def cidr= (newval)
      @cidr = newval
      @ending_address = IPAddr.ending_address(@starting_address, @cidr)
      @uid = "#{@starting_address}/#{@cidr}"
      @subnet = IPAddr.new @uid
      @needs_update = true
    end

    ###
    ### is a given address in this network segment?
    ###
    def include? (some_addr)
      @subnet.include? some_addr
    end


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
