# = net_segment.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A class representing a Network Segment in the JSS.
#

module PixJSS

  ### 
  ### A 'network segment' in the JSS
  ### 
  ### These are used in the JSS for scoping policies and other management activites.
  ### This class will mostly be used by the scripts that keep the JSS network segments
  ### in sync with the canonical document defining them in our wiki, 
  ### http://wiki.pixar.com/display/SYS/NetworkNetblocks
  ### 
  ### For initialization, the args are a hash. If the hash has only one member, it must 
  ### be either :name (a string), :starting_addrees (a string containing an IP address) or :jss_id (an integer). 
  ###
  ### If more than one member of the hash is provided, all data must be present
  ### and must include, minimally, :name, :starting_address & :ending_address or :cidr. The
  ### instance is built from the provided data and the JSS is not queried.
  ###
  ### Optional keys are :building, :department, :distribution_point, :netboot_server, 
  ### :swu_server, :override_departments, :override_buildings
  ###
  class JSSNetSegment
    include PixJSS
    include Comparable
  
    # String - name of the Network Segment in the jss
    # must be writable so that we can update in the jss if it changes on the wiki
    attr_accessor :name
    # String - starting IP adresss
    attr_reader :starting_address
    # String - ending IP adresss
    attr_reader :ending_address
    # Integer - the CIDR
    attr_reader :cidr
    # String - building for this segment, if applicable. Must be one of the buildings in the JSS
    attr_reader :building
    # String - department for this segment, if applicable. Must be one of the depts in the JSS
    attr_reader :department
    # String - the 'caspershare' afp/http server for this segment
    attr_reader :distribution_point
    # String - the netboot server for this segment
    attr_reader :netboot_server
    # String - the swupdate server for this segment.
    attr_reader :swu_server
    # Boolean - should machines checking in from this segment update their dept
    attr_reader :override_departments
    # Boolean - should machines checking in from this segment update their building
    attr_reader :override_buildings
    # Integer - the id of this segment in the JSS
    attr_reader :jss_id
    alias  id jss_id
    # String - the unique identifier for this subnet, regardless of the JSS id
    attr_reader :uid
    alias identifier uid 
    
    ###
    ### For initialization, the args are a hash. If the hash has only one member, it must 
    ### be either :name (a string), :starting_addrees (a string containing an IP address) or :jss_id (an integer). 
    ###
    def initialize(args)
     
      if args.count == 1
        # look up the segment in the JSS by name, starting addres, or id
        if args[:jss_id]
          @jss_id = args[:jss_id]
          rsrc_to_lookup = "networksegments/id/#{@jss_id}"
        elsif args[:name]
          @name = args[:name]
          rsrc_to_lookup = "networksegments/name/#{@name}"
        elsif args[:starting_address]
           @starting_address = args[:starting_address]
           qr = @@db_cnx.query "select network_segment_id from network_segments where starting_address = '#{@starting_address}'"
           raise MissingDataError, "No network segments starting with #{@starting_address} in the JSS." unless qr.count == 1
           @jss_id = qr.fetch[0]
           rsrc_to_lookup = "networksegments/id/#{@jss_id}"
        else
          raise MissingDataError, "Missing :name, :starting_address, or :id."
        end # if args
        
        # look up the data
        jss_data  = PixJSS::REST_CNX.get_rsrc(rsrc_to_lookup)[:network_segment]
        
        @jss_id = jss_data[:id]
        @name = jss_data[:name]
        @starting_address = jss_data[:starting_address]
        @ending_address = jss_data[:ending_address]
        @cidr = get_cidr(@starting_address,@ending_address)
        @building = jss_data[:building] == {} ? nil : jss_data[:building]
        @department = jss_data[:department] == {} ? nil : jss_data[:department] 
        @distribution_point = jss_data[:distribution_point] == {} ? nil : jss_data[:distribution_point] 
        @netboot_server = jss_data[:netboot_server] == {} ? nil : jss_data[:netboot_server]
        @swu_server = jss_data[:swu_server] == {} ? nil : jss_data[:swu_server]
        @override_departments = jss_data[:override_departments] 
        @override_buildings = jss_data[:override_buildings] 
        
        
      else
        # don't look up the segment, make it from the args, 
        # but we must have :name, :starting_address, & :ending_address or :cidr
        raise MissingDataError, "Missing :name." unless args[:name]
        raise MissingDataError, "Missing :starting_address." unless args[:starting_address]
        raise MissingDataError, "Missing :ending_address or :cidr." unless args[:ending_address] or args[:cidr]
        
        # load the attribs
        @jss_id = args[:jss_id] ? args[:jss_id] : nil
        @name = args[:name]
        @starting_address = args[:starting_address]
        
        if args[:cidr]
          @cidr = args[:cidr].to_i
          @ending_address = get_ending_address(@starting_address, @cidr)
        else
          @ending_address = args[:ending_address]
          @cidr = get_cidr(@starting_address,@ending_address)
        end # if args[:cidr]
        
        @building = args[:building] ? args[:building] : nil
        @department = args[:department]  ? args[:department] : nil
        @distribution_point = args[:distribution_point]  ?  args[:distribution_point] : nil
        @netboot_server = args[:netboot_server] ? args[:netboot_server] : nil
        @swu_server = args[:swu_server] ?  args[:swu_server] : nil
        @override_departments = args[:override_departments] ? true : false
        @override_buildings = args[:override_buildings] ? true : false
   
      end # if args.count
      
      # names can't have slashes, which they might if taken from the description
      @name.gsub!(/\//, "-")
      
      # we now have all our data, make our unique identifier, the startingaddr/cidr
      @uid = "#{@starting_address}/#{@cidr}"
      
      # and, if we're in the JSS, we have a rest resource
      @rest_rsrc = @jss_id ? "networksegments/id/#{@jss_id}" : nil
       
    end #init
    
    ###
    ### Thanks to comparable, we can tell if we're equal or not.
   ###
   def <=>(other)
      self.uid <=> other.uid
    end
    
    ###
    ### add this segment to the JSS 
    ###
    def add_to_jss
      raise AlreadyExistsError, "Net Segment already in JSS, can't add."  if @jss_id
      raise MissingDataError, "No Name for segment #{@uid}, can't add to JSS." unless @name
      @rest_rsrc = URI::encode "networksegments/name/#{@name}"
      rest_reply = PixJSS::REST_CNX.post_rsrc( :rsrc => @rest_rsrc, :xml => rest_xml )
      rest_reply =~ /<id>(\d+)<\/id>/
      @jss_id = $1
      @rest_rsrc = "networksegments/id/#{@jss_id}"
    end # add
    
    ###
    ### delete this segment from the JSS
    ###
    def delete_from_jss
      raise NoSuchItemError, "Net Segment not in JSS, can't delete."  unless @rest_rsrc
      PixJSS::REST_CNX.delete_rsrc(@rest_rsrc)
      @jss_id = nil
      @rest_rsrc = nil
    end # delete
    
    ###
    ### update this segment in the JSS with current object values
    ###
    def update_jss
      raise NoSuchItemError, "Net Segment not in JSS, can't update."  unless @rest_rsrc
      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => rest_xml )
    end # update
    
    
    ######################
    # private methods
    private
    
    ###
    ### given a starting and ending address, return the cidr
    ### NOTE: This method assumes that the largest subnet defined is a class C, 
    ### and that therefore all cidrs are in the range 24 - 32
    ###
    def get_cidr(starting,ending)
      starting_last_byte = starting.split(".")[3].to_i
      ending_last_byte = ending.split(".")[3].to_i
      num_addrs = ending_last_byte - starting_last_byte + 1
      case num_addrs
        when 256 then 24
        when 128 then 25
        when 64 then 26
        when 32 then 27
        when 16 then 28
        when 8 then 29
        when 4 then 30
        when 2 then 31
        when 1 then 32
      end # case
    end # cidr
    
    ###
    ### given a starting address and CIDR, return the ending address
    ### NOTE: This method assumes that the largest subnet defined is a class C, 
    ### and that therefore all cidrs are in the range 24 - 32
    ###
    def get_ending_address(starting, cidr)
      ip_bytes = starting.split(".")
      last_byte = ip_bytes[3].to_i + (2**(32 - cidr)) - 1
      return [ip_bytes[0], ip_bytes[1], ip_bytes[2], last_byte.to_s ].join('.')
    end # ending_address
    
    ###
    ### the xml formated data for adding or updating this in the JSS
    ###
    def rest_xml
      xml_payload = <<-ENDXML 
#{REST_XML_HEADER}
<network_segment>
  <name>#{@name}</name>
  <starting_address>#{@starting_address}</starting_address>
  <ending_address>#{@ending_address}</ending_address>
  <distribution_point>#{@distribution_point}</distribution_point>
  <netboot_server>#{@netboot_server}</netboot_server>
  <swu_server>#{@swu_server}</swu_server>
  <building>#{@building}</building>
  <department>#{@department}</department>
  <override_buildings>#{@override_buildings}</override_buildings>
  <override_departments>#{@override_departments}</override_departments>
</network_segment>
ENDXML
      xml_payload
    end #rest_xml
  end # class JSSNetSegment
end # module
