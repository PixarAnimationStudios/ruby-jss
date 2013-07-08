# = peripheral.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A superclass for interacting with Peripherals in the JSS.
# Create custom site_peripheral_XXXX.rb files for defining the 
# details of the peripheral types defined in your JSS.
#


module PixJSS
  
  
  #####################################
  # Classes
  #####################################
  
  ### 
  ### A peripheral in the JSS
  ###
  ### NOTE This should be used as a SuperClass!
  ### Make your own site_peripheral_XXXX.rb file to define subclasses of Peripheral for 
  ### each "type" of peripheral defined in your JSS.
  ### 
  ### Those subclasses should set the @type and have methods for setting the
  ### @fields contents for the type.
  ### 
  class Peripheral
    
    ###############################
    # Class Constants
      
    # The computers table in the JSS
    PERIPHERAL_TABLE = "peripherals"
  
    # The API subsets - querying them only as needed
    # speeds up many things when using the API.
    # particularly when something's wrong or slow with the DB
    # on one particular subset.
    # when creating a new instance only General and Location are
    # queried first. Others as needed via methods
    
    # General includes: id, name, macaddr, alt macaddr, last IP, Serialnum,
    # udid, platform, barcodes, asset tag, remote mgmt, last report (recon), last contact,
    # dist point, suserver, netboot server
    SUBSET_GENERAL = "General"
    
    # Location includes: user, realname, email, position, phone, dept, bldg, room
    SUBSET_LOCATION = "Location"
    
    # Purchasing includes all GSX and applecare data 
    SUBSET_PURCH = "Purchasing"
    
    #####################################
    # Class Variables
    #####################################
    
    ## a holder for the list of all periphs in the JSS
    # see the #peripherals module method
    @@peripherals = nil
    
    #####################################
    # Class Methods
    #####################################
    
    ###
    ### Return a hash of all peripherals in the jss, 
    ### Key is jss ID, value is  the periph type
    ###
    def Peripheral.peripherals(refresh = false)
      @@peripherals = nil if refresh
      return @@peripherals if @@peripherals
      
      @@peripherals = {}
      PixJSS.check_connection
      
      # this returns an array of all periphs, with just the type, barcodes, and id
      PixJSS::REST_CNX.get_rsrc("peripherals")[:peripherals][:peripheral].each do |p|
        @@peripherals[p[:id]] = p[:type]
      end
      @@peripherals
      
    end # def peripherals
  
    #####################################
    # Attributes
    #####################################
    
    # Boolean - is there a matching machine in the JSS?
    attr_reader :exists
    alias exists? exists
    alias exist? exists
    
    # Integer- the id number of the peripheral in the JSS
    attr_reader :id
    
    # String - the serial number as stored in the JSS
    attr_reader :sn
    alias serial_number sn
    alias serialnumber sn
    
    # String - the type of periph
    # should be settable in a subclass of Peripheral
    attr_reader :type 
    
    # Hash  - the field values of the periph
    # Keys are the field name (strings) 
    # values are the field values (anything)
    # should be settable in a subclass of Peripheral
    attr_reader :fields
    
    # String - the "bar code 1" value
    attr_reader :barcode_1
    
    # String - the "bar code 2" value
    attr_reader :barcode_2
    
    # Integer- the id number of the computer to which 
    # this periph is, or was most recently, connected
    attr_reader :computer_id
    
    # String - the owner 
    # changed by changing the @computer_id
    attr_reader :user
    
    # String - the building where it's located
    # changed by changing the @computer_id
    attr_reader :building
    
    # String - the room number
    # changed by changing the @computer_id
    attr_reader :room
    
    # Hash - the full dataset returned by the REST API
    attr_reader :raw_data
    
    #### TO DO
    #  access purchasing data?
    
    #####################################
    # Instance Methods
    #####################################

    ###
    ### Initialize
    ###
    def initialize (id=nil)
      
      id ||= 0
      @id = id
      
      @rest_rsrc = "peripherals/id/#{@id}"
      
      # fields is empty to start, existant or not.
      @fields = {}
      
      # assume non-existance to start
      @exists = false
      @saved = false
      
      PixJSS.check_connection
      
      # To start, we only get the general and location data, for speed.
      # the rest will be queried as needed. See the SUBSET Class Constants above
      begin
        
        @restq = PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_GENERAL}&#{SUBSET_LOCATION}")
        return unless @restq[:peripheral]
        @raw_data = @restq[:peripheral]
        @exists = true
        @saved = true
        
      rescue RestClient::ResourceNotFound
        return 
      end
     
      # now we have raw data with something in it, so fill out the instance vars
      @id = @raw_data[:general][:id]
      @type =  @raw_data[:general][:fields][:type]
      @barcode_1 = @raw_data[:general][:bar_code_1].empty? ? nil : @raw_data[:general][:bar_code_1]
      @barcode_2 = @raw_data[:general][:bar_code_2].empty? ? nil : @raw_data[:general][:bar_code_2]
      @computer_id = @raw_data[:location][:computer_id]
      @user = @raw_data[:location][:username].to_s
      @building = @raw_data[:location][:building].empty? ? nil : @raw_data[:location][:building]
      @room = @raw_data[:location][:room]
      
      # fill in the fields
      @raw_data[:general][:fields][:field].each{|f| @fields[f[:name]] = f[:value] }
      
      # these hold the raw REST output for each subset as we read it, so we don't have to look it up
      # multiple times. THey are populated buy the private methods below
      # note that general and location are stored in @raw_data above 
      @raw_purch = nil
      
    end # initialize

    ###
    ### set the bar codes
    ###
    def barcode_1=(new_value)
        @barcode_1 = new_value
        @saved = false
    end
    
    def barcode_2=(new_value)
        @barcode_2 = new_value
        @saved = false
    end    
    
    ###
    ### Set the computer id
    ###
    def computer_id=(new_id)
      # allow the computer ID to be unset
      unless  new_id.nil? or new_id.to_s.empty? 
        raise PixJSS::NoSuchItemError, "No computer in the JSS with id #{new_id}" unless PixJSS.computers.keys.include? new_id.to_s
      end
      @computer_id = new_id
      @saved = false
    end
    
    ###
    ### disassociate this peripheral from any computer
    ###
    def disassociate
      @computer_id = 1

      xml = <<-ENDXML
#{REST_XML_HEADER}
<peripheral>
  <location>
    <computer_id>1</computer_id>
  </location>
</peripheral>
ENDXML
      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => xml )
    end
    alias unassign disassociate
    
    ### 
    ### Make a chunk of XML representing the peripheral
    ### for PUTting or POSTing
    ###
    def xml_payload
      xml_fields = "    <fields>"
      xml_fields += "\n      <type>#{@type}</type>"
      @fields.each do |k,v| 
        xml_fields += "\n      <field>"
        xml_fields += "\n        <name>#{k}</name>"
        xml_fields += "\n        <value>#{v}</value>"
        xml_fields += "\n      </field>"
      end
      xml_fields += "\n    </fields>"
      xml_fields
      
      # the full XML
      xml_payload = <<-ENDXML
#{REST_XML_HEADER}
<peripheral>
  <general>
    <bar_code_1>#{@barcode_1}</bar_code_1>
    <bar_code_2>#{@barcode_2}</bar_code_2>
#{xml_fields}
  </general>
  <location>
    <computer_id>#{@computer_id}</computer_id>
  </location>
</peripheral>
ENDXML

    end
    
    ###
    ### Create this peripheral in the JSS
    ### returns the newly created JSS id
    ###
    def create
      # data checks
      check_data

      response = PixJSS::REST_CNX.post_rsrc( :rsrc => @rest_rsrc, :xml => xml_payload )
    
      @saved = true
      @exists = true
      
      response =~ %r{<peripheral><id>(\d+)</id></peripheral>}
      @id = $1.to_i
      
    end # create
    
    ###
    ### Save any changes to peripheral in the JSS
    ###
    def save
      return nil if @saved
      return create unless @exists
      
      # data checks
      check_data
    
      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => xml_payload )
    
      @saved = true
    end # save
    
    ###
    ### Make sure data is good to submit
    ###
    def check_data
      
      PixJSS.check_connection
      
      raise "ID can't exist if not yet created" if (not @exists) and @id != 0
      
    end # check data
    
    
    ###
    ### Delete this peripheral from the JSS 
    ###
    def delete
      return nil unless @exists
      
      PixJSS::REST_CNX.delete_rsrc @rest_rsrc
      
      @id = 0
      @raw_data = nil
      @type = nil
      @barcode_1 = nil
      @barcode_2 = nil
      @computer_id = nil
      @user = nil
      @building = nil
      @room = nil
      @fields = nil
      @raw_purch = nil
      @exists = false
      @saved = false
    end #delete
    
  
    
    ##############################
    private # private methods
    ##############################
    
    ###
    ### return purchasing details from the JSS - Hash
    ###
    def raw_purch
      @raw_purch ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_PURCH}")[:computer][:purchasing]
    end

  end # class Peripheral
end # module