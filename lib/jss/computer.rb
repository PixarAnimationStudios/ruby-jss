# = computer.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A Class representing a client Computer in the JSS
#


module PixJSS
  
  #####################################
  # Constants
  #####################################
  
  ###
  ### Mappings 
  ### the common symbols used throughout PixJSS mapped to
  ### the names they use in various database tables and REST resources
  ###  
  
  # The mapping of standardized symbols used throughout this module
  # to REST attrib names in the JSS computers
  #
  # NOTE some of these fields are in the computers table, some in the 
  # locations table. A join is needed (via the location_history table)
  # to get the equivalent of our ldap entry.
  COMPUTER_ATTRS_TO_REST_ATTRS = {
            :id => 'id',
            :pixid => 'barcode_1',
            :platform => 'platform',
            :macaddr => 'mac_address',
            :alt_macaddr => 'alt_mac_address',
            :name => 'computer_name',
            :atag => 'asset_tag',
            :last_ip => 'last_ip',
            :last_reported_ip => 'last_reported_ip',
            :owner => 'username',
            :full_name => 'realname',
            :building => 'building',
            :room => 'room',
            :dept => 'department',
            :phone => 'phone',
            :email => 'email',
            :title => 'position',
            :ldap_uid => 'ldap_uid'
  }
  
  # A shorter but less descriptive name for the COMPUTER_ATTRS_TO_JSS_FIELDS constant
  CMAP = COMPUTER_ATTRS_TO_REST_ATTRS 
  
  # The mapping of standardized symbols used throughout this module
  # to JSS Field names in the JSS computers table
  #
  COMPUTER_ATTRS_TO_JSS_FIELDS = {
            :id => 'computer_id',
            :name => 'computer_name',
            :pixid => 'bar_code_1'
  }
  CDMAP = COMPUTER_ATTRS_TO_JSS_FIELDS
  
  # The computers table in the JSS
  COMPUTERS_TABLE = "computers"
  
  # The locations table in the JSS
  LOCATIONS_TABLE = "locations"
  
  # The location history join table in the JSS
  LOCATION_HIST_TABLE = "location_history"
  
  ###
  ### Web UI
  ###
  
  # the Computer Details Page - you'll have to append the computer id before 
  # loading this.
  WEBUI_COMPUTER_DETAILS_URLBASE = "http://#{JSS_HOST}:#{JSS_PORT}/viewComputer.html?computer_id="
  
  #####################################
  # Module Variables
  #####################################
  
  # a hash of all computers in the jss, name => jss_id
  @@computers = nil
  
  #####################################
  # Module Methods
  #####################################
  
  ###
  ### Return a hash of all computers in the jss, 
  ### Key is jss ID, value is computer name
  ###
  ### NOTE this isn't a hash of Computer objects
  ### since it would be slow to generate that when all we want is the names & ids
  ### If you want the objects, use this array to generate them as needed
  ###
  def computers(refresh = false)
    @@computers = nil if refresh
    return @@computers if @@computers
    
    @@computers = {}
    check_connection
    theQuery = "SELECT computer_name, computer_id FROM #{COMPUTERS_TABLE}"
    @@db_cnx.query(theQuery).each {|c| @@computers[c[1]] = c[0] }
    @@computers
  end # def computers
  
  
  #####################################
  # Classes
  #####################################
  
  ### 
  ### A Computer in the JSS
  ### 
  ### Unlike Pkgs & Scripts, this class can't be used to create new records in the
  ### JSS (although it can change some of the data stored there).
  ### Thus, new instantiations of this class are always looked up in the JSS
  ### one at a time via REST. The reason being that the REST API returns ALL the
  ### relevant data about a machine - a pretty extensive set. 
  ### To reproduce the SQL queries needed for generate that data set would 
  ### be silly, even if it might be faster when running the query.
  ### 
  ### For details about using the REST API see http://casper.pixar.com:9006/apiFrontPage.rest
  ### 
  class JSSComputer
    
    # This module is mixed in to provide access to site-defined inventory data
    # stored in the JSS, e.g. Extension Attribute Values, special smart-groups, etc.
    #include PixJSS::SiteExtensionAttributes
    
    ###############################
    # Class Constants
    
    #######
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
    
    # Info about peripherals, if we ever start keeping it
    SUBSET_PERIPH = "Peripherals"
    
    # HW includes: make, model, os, os vers, os build, proc type, proc arch, proc speed, numprocs, 
    # ram, bootrom, battery capacity, cache, ramslots, optical drives, nic speed, smc vers, 
    # storage devices (model, rev, sn, size, connection type, smart status),
    # & partitions (name-indicating boot partition, size, fv2 status, fv2%),
    # and printers (name, uri, type, location)
    SUBSET_HW = "Hardware"
    
    # Software includes Installed apps (with count, each app includes name, path and version),
    # unix executables (we don't collect that), Installed Licensed Software (just a name list)
    # installed by casper ( a pkg/dmg list), installed by SWU/Installer (a pkg list), 
    # cached by casper, available SWU's, running services, fonts, plugins.
    SUBSET_SW = "Software"
    
    # ExtAttrs includes: each EA with a name and a value
    SUBSET_EA = "ExtensionAttributes"
    
    # GroupsAccts includes: a list of JSS groups to which this computer belongs, and 
    # all local accts, for which we have loginname, real name, homepath, home size, isadmin, FV1 status.
    SUBSET_GRPACCT = "GroupsAccounts"
    
    # iOS devices: a list of devices, with a count. Each device has an id, name, udid, SN, and username
    SUBSET_IOS = "iPhones"
    
    # Conf Profiles: a list of installed profiles, with a count. Each has an ID, name, and udid
    # Note that this subset takes a VERY long time to query, as of Aug 2012
    SUBSET_PROFILES = "ConfigurationProfiles"
    
    # Boot partitions are noted with the string "(Boot Partition)" at the end 
    BOOT_FLAG = " (Boot Partition)"
    

    
    ###############################
    # Attributes
    
    # Boolean - is there a matching machine in the JSS?
    attr_reader :exists
    alias exists? exists
    alias exist? exists
    
    # Integer- the id number of the computer in the JSS
    attr_reader :id
    
    # String - the serial number as stored in the JSS
    attr_reader :sn
    alias serial_number sn
    alias serialnumber sn
    
    # String - the en0 macaddress in dot-separated format (as stored in the jss)
    attr_reader :macaddress 
    
    # String - the en1 macaddress in dot-separated format (as stored in the jss)
    attr_reader :alt_macaddress
    
    # DateTime - the last contact time
    attr_reader :last_contact
    
    # DateTime - the last recon time
    attr_reader :last_recon
    
    # String - the owner 
    attr_reader :user
    
    # String - the building where it's located
    attr_reader :building
    
    # String - the room number
    attr_reader :room
    
    # Boolean - is this machine "managed" by Casper?
    attr_reader :managed
    alias managed? managed
    
    # String - the name of the computer in the jss
    attr_reader :name
    
    # Hash - the full dataset returned by the REST API
    attr_reader :raw_data
    
    # String - the machine's pixid as stored in the JSS's bar_code_1 field
    attr_reader :pixid
    
    ###
    ### Initialize
    ### Args must include :id or :macaddress or :name
    ###
    def initialize (args = {})
    
      raise MissingDataError, "Missing :macaddress, :name, or :id." unless args[:macaddress] or args[:id] or args[:name]
      
      jss_macaddr = args[:macaddress].strip.downcase.gsub ':', '.' if args[:macaddress]
      
      PixJSS.check_connection
      
      @exists = false
      
      @rest_rsrc = case
        when args[:id]
          "computers/id/#{args[:id]}"
        when args[:macaddress]
          "computers/macaddress/#{jss_macaddr}"
        when args[:name]
          "computers/name/#{args[:name]}"
        else
          raise MissingDataError, "Missing :id, :macaddress, or :name"
      end
      
      
      
      # To start, we only get the general and location data, for speed.
      # the rest will be queried as needed. See the SUBSET Class Constants above
      begin
        @raw_data = PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_GENERAL}&#{SUBSET_LOCATION}")[:computer]
      rescue RestClient::ResourceNotFound
        raise NoSuchItemError, "JSS computer not found: #{@rest_rsrc}"
      end
      
      @exists = true
      
      # now we have raw data with something in it, so fill out the instance vars
      @id = @raw_data[:general][:id]
      @pixid = @raw_data[:general][:barcode_1].empty? ? nil : @raw_data[:general][:barcode_1]
      @sn = @raw_data[:general][:serial_number].to_s
      @macaddress = @raw_data[:general][:mac_address].to_s
      @alt_macaddress = @raw_data[:general][:alt_mac_address].to_a
      @last_contact = @raw_data[:general][:last_contact_time].empty? ? nil : DateTime.parse(@raw_data[:general][:last_contact_time])
      @last_recon = @raw_data[:general][:report_date].empty? ? nil : DateTime.parse(@raw_data[:general][:report_date])
      @managed = @raw_data[:general][:remote_management][:managed]
      @name = @raw_data[:general][:name].to_s
      @user = @raw_data[:location][:username].to_s
      @building = @raw_data[:location][:building].empty? ? nil : @raw_data[:location][:building]
      @room = @raw_data[:location][:room]

      # these hold the raw REST output for each subset as we read it, so we don't have to look it up
      # multiple times. THey are populated buy the private methods below
      # note that general and location are stored in @raw_data above 
      @raw_purch = nil
      @raw_periph = nil
      @raw_hw = nil
      @raw_sw = nil
      @raw_ea = nil
      @raw_grpacct = nil
      @raw_ios = nil
      @raw_profiles = nil
      
      
    end # initialize    
    
    ###
    ### set the pixid in the JSS
    ###
    def pixid= (new_pixid)
          xml_payload = <<-ENDXML
#{PixJSS::REST_XML_HEADER}
<computer>
  <general>
    <barcode_1>#{new_pixid}</barcode_1>
  </general>
</computer>
ENDXML

      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => xml_payload )
      @pixid = new_pixid
    end
    
    ###
    ### Return an Array - the JSS groups to which thismachine belongs (smart and static)
    ###
    def computer_groups
      data = raw_grpacct[:computer_group_memberships][:group]
      return data.class == Array ? data : [data]
    end
    
    ###
    ### Return an Array of hashes - all the local accts on the machine. 
    ### Each item has keys :name, :realname, :uid, :home, :home_size, :administrator, :filevault_enabled
    ###
    def accts
      data = raw_grpacct[:local_accounts][:user]
      return data ? data : []
    end
    
    ###
    ### Return an Array of hashes for each storage device
    ###
    def drives
      data = raw_hw[:storage][:device]
      return data.class == Array ? data : [data]
    end
    
    ###
    ### Return a hash of details about the boot partition and
    ### and it's drive or nil if no boot partition found on a local drive.
    ### The hash keys are the same as those available from the JSS data
    ### but with device_ or partition_ prepended, thusly:
    ###         {:partition_filevault_status=>"Not Encrypted",
    ###          :device_revision=>"FH415B",
    ###          :partition_percentage_full=>46,
    ###          :device_size=>"320.07 GB",
    ###          :device_serial_number=>"6082P134T",
    ###          :partition_filevault_percent=>0,
    ###          :device_model=>"TOSHIBA MK3255GSXF",
    ###          :device_smart_status=>"Verified",
    ###          :partition_size=>"319.21 GB",
    ###          :device_connection_type=>"NO",
    ###          :partition_name=>"Kreik"}    
    ###
    def boot_partition
      the_partition = {}
      the_drive = {}
      drives.each do |drive|
        # drive[:partition] will be a hash if there's one partition,
        # or an array of hashes if there are more than one.
        if drive[:partition].class == Hash
          the_partition = drive[:partition] if drive[:partition][:name].end_with? BOOT_FLAG
        else
          drive[:partition].each {|p| @boot_partition = p if p[:name].end_with? BOOT_FLAG}
        end # if
        unless the_partition.empty?
          the_drive = drive
          break
        end
      end # each drive
      return nil if the_partition.empty?
      
      @boot_partition = {}
      the_drive.each_key { |k| @boot_partition[("device_" + k.to_s).to_sym] = the_drive[k] }
      the_partition.each_key { |k| @boot_partition[("partition_" + k.to_s).to_sym] = the_partition[k] }

      @boot_partition[:partition_name] = @boot_partition[:partition_name].chomp BOOT_FLAG
      @boot_partition.delete :device_partition
      return @boot_partition
    end # boot partition
    
    ###
    ### Return an array of hashes for each printer on this computer
    ### Keys are :name, :uri, :type, :location
    ###
    def printers
      raw_hw[:mapped_printers][:printer]
    end
    
    ###
    ### A bunch of simple data from the hardware subset
    ###
    def make ; raw_hw[:make] ; end
    def model ; raw_hw[:model] ; end
    def os_name ; raw_hw[:os_name] ; end
    def os_version ; raw_hw[:os_version] ; end
    def os_build ; raw_hw[:os_build] ; end
    def proc_type ; raw_hw[:processor_type] ; end
    def arch ; raw_hw[:processor_architecture] ; end
    def proc_speed ; raw_hw[:processor_speed] ; end
    def cores ; raw_hw[:number_processors] ; end
    def ram ; raw_hw[:total_ram] ; end
    def boot_rom ; raw_hw[:boot_rom] ; end
    def bus_speed ; raw_hw[:bus_speed] ; end
    def battery_capacity ; raw_hw[:battery_capacity] ; end
    def cache_size ; raw_hw[:cache_size] ; end
    def available_ram_slots ; raw_hw[:available_ram_slots] ; end
    def optical_drive ; raw_hw[:optical_drive] ; end
    def nic_speed ; raw_hw[:nic_speed] ; end
    def smc_version ; raw_hw[:smc_version] ; end
    
    
    ###
    ### Return an array hashes of all apps installed on this machine
    ### keys are :name, :path, and :version
    ###
    def apps ; raw_sw[:applications][:application] ; end
    
    
    ###
    ### Return an array of the JSS-defined "licensed software" titles
    ### installed on this machine.
    ###
    def licensed_sw ; raw_sw[:licensed_software][:name] ; end
    
    
    ###
    ### Delete this computer from the JSS 
    ###
    def delete
      PixJSS::REST_CNX.delete_rsrc @rest_rsrc
      
      @id = nil
      @sn = nil
      @macaddress = nil
      @alt_macaddress = nil
      @last_contact = nil
      @apps = nil
      @groups = nil
      @user = nil
      @building = nil
      @room = nil
    end #delete
    
    ###
    ### is this computer in inventory now?
    ### it has to be unmanaged and have the user "inventory"
    ###
    def in_inventory?
      (@managed == false) and (@user.downcase == "inventory")
    end
    alias inv? in_inventory?
    
    
    ###
    ### make a new "location history" record for this machine, showing it's in inventory.
    ### args can be empty, or may include :room
    ### 
    def to_inv args = {}
    
      invuser = "inventory"
      invroom = args[:room].nil? ? @room : args[:room]
      
      xml_payload = <<-ENDXML
#{REST_XML_HEADER}
<computer>
  <location>
    <username>inventory</username>
    <real_name>inventory</real_name>
    <email_address>inventory</email_address>
    <position>inventory</position>
    <phone>inventory</phone>
    <department>inventory</department>
    <building></building>
    <room>#{invroom}</room>
  </location>
</computer>
ENDXML
      
      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => xml_payload )
      
      self.make_unmanaged
      
      @user = invuser
      @room = args[:room]
      
    end #to_inv
    
    ###
    ### Make this machine unmanaged in the JSS
    ###
    def make_unmanaged
      xml_payload = <<-ENDXML
#{REST_XML_HEADER}
<computer>
  <general>
    <remote_management>
      <management_password></management_password>
      <management_username></management_username>
      <managed>false</managed>
    </remote_management>
  </general>
</computer>
ENDXML
  
      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => xml_payload )
      @managed = false
    end # make unmanaged
    
    ###
    ### Make this machine managed by the JSS
    ###
    def make_managed
      PixJSS.set_mgmt_pw
      xml_payload = <<-ENDXML
#{REST_XML_HEADER}
<computer>
  <general>
    <remote_management>
      <management_username>#{PixJSS::MGMT_ACCT}</management_username>
      <management_password>#{PixJSS.mgmt_pw}</management_password>
      <managed>true</managed>
    </remote_management>
  </general>
</computer>
ENDXML
  
      PixJSS::REST_CNX.put_xml( :rsrc => @rest_rsrc, :xml => xml_payload )
      @managed = true
    end # make managed
    
    ##############################
    private # private methods
    ##############################
    
    ###
    ### return purchasing details from the JSS - Hash
    ###
    def raw_purch
      @raw_purch ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_PURCH}")[:computer][:purchasing]
    end
    
    ###
    ### return preipheral details from the JSS - Array
    ###
    def raw_periph
      @raw_periph ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_PERIPH}")[:computer][:peripherals][:peripheral]
    end
    
    ###
    ### return software details from the JSS - Hash
    ###
    def raw_sw
      @raw_sw ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_SW}")[:computer][:software]
    end
    
    ###
    ### return hardware details from the JSS - Hash
    ###
    def raw_hw
      @raw_hw ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_HW}")[:computer][:hardware]
    end
    
    ###
    ### return ExtAttr details from the JSS - Hash
    ### This one we convert from the REST Array into a hash, because each array item
    ### is just a hash of :name, and :value. So why not turn the whole thing 
    ### into a proper hash
    ###
    def raw_ea
      return @raw_ea if @raw_ea
      @raw_ea = {}
      PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_EA}")[:computer][:extension_attributes][:attribute].each do |ea|
        @raw_ea[ea[:name]] = ea[:value]
      end
      return @raw_ea
    end
    
    ###
    ### return Group & Acct details from the JSS - Hash
    ###
    def raw_grpacct
      @raw_grpacct ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_GRPACCT}")[:computer][:groups_accounts]
    end
    
    ###
    ### return iOS details from the JSS - Array
    ###
    def raw_ios
      @raw_ios ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_IOS}")[:computer][:iphones][:iphone]
    end
    
    ###
    ### return Profile details from the JSS - Array
    ###
    def raw_profiles
      @raw_profiles ||= PixJSS::REST_CNX.get_rsrc(@rest_rsrc + "/subset/#{SUBSET_PROFILES}")[:computer][:configuration_profiles][:configuration_profile]
    end
    
  end # class JSSComputer
end # module