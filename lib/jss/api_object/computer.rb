module JSS
  
  #####################################
  ### Module Constants
  #####################################
  
  #####################################
  ### Module Variables
  #####################################
  
  #####################################
  ### Module Methods
  #####################################
  
  
  ###
  ### A Computer in the JSS.
  ###
  ### Computers cannot be created in the JSS via this module. Please use other
  ### Casper methods (like the Recon App or QuickAdd package)
  ###
  ### Additionally, any data that arrives in the JSS via an "inventory update"
  ### (a.k.a. 'recon') cannot be modified through the API.
  ###
  ### Data that can be modified are:
  ### * Management Account (see #set_management_to)
  ### * asset_tag
  ### * barcodes 1 and 2
  ### * ip_address
  ### * udid
  ### * mac_addresses
  ### * location data from the Locatable module
  ### * purchasing data from the Purchasable module
  ###
  ### After making any changes, you must call #update to send those
  ### changes to the server.
  ###
  ### See also JSS::APIObject
  ###
  class Computer  < JSS::APIObject
    
    #####################################
    ### MixIns
    #####################################
    
    include JSS::Updatable
    include JSS::Locatable
    include JSS::Purchasable
    include JSS::FileUpload
    
    extend JSS::Matchable


    #####################################
    ### Class Methods
    #####################################
    
    ###
    ### Send an MDM command to a managed computer by id or name
    ###
    ### @param computer[String,Integer] the name or id of the computer to recieve the command
    ### @param command[Symbol] the command to send, one of the keys of API_MDM_COMMANDS
    ###
    ### @return [true] if the command was sent
    ###
    def self.send_mdm_command(computer,command)
      
      raise JSS::NoSuchItemError, "Unknown command '#{command}'" unless API_MDM_COMMANDS.keys.include? command
      
      command_xml ="#{JSS::APIConnection::XML_HEADER}<computer><command>#{API_MDM_COMMANDS[command]}</command></computer>"
      the_id = nil
      
      if computer.to_s =~ /^\d+$/
        the_id = computer
      else
        the_id = self.map_all_ids_to(:name).invert[computer]
      end
      
      if the_id
        response = JSS::API.put_rsrc("#{RSRC_BASE}/id/#{the_id}", command_xml) 
        response =~ %r{<notification_sent>(.+)</notification_sent>}
        return ($1 and $1 == "true")
      end
      raise JSS::UnmanagedError, "Cannot send command to unknown/unmanaged computer '#{computer}'"
    end
    
    
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "computers"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computers
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :computer
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:sus, :distribution_point, :alt_mac_address ]
    
    ### This class lets us seach for computers
    SEARCH_CLASS = JSS::AdvancedComputerSearch
    
    ### Boot partitions are noted with the string "(Boot Partition)" at the end 
    BOOT_FLAG = " (Boot Partition)"
    
    ### file uploads can send attachments to the JSS using :computers as the sub-resource.
    UPLOAD_TYPES = { :attachment => :computers}
    
    ### A mapping of Symbols available to the send_mdm_command class method, to 
    ### the String commands actuallly sent via the API.
    API_MDM_COMMANDS = {
      :blank_push => "BlankPush",
      :send_blank_push => "BlankPush",
      :blank => "BlankPush",
      :noop => "BlankPush",
      :device_lock => "DeviceLock",
      :lock => "DeviceLock",
      :lock_device => "DeviceLock",
      :erase_device => "EraseDevice",
      :erase => "EraseDevice",
      :wipe => "EraseDevice",
      :unmanage_device => "UnmanageDevice",
      :unmanage => "UnmanageDevice"
    }
    
    #####################################
    ### Attributes
    #####################################
    
    ### The values returned in the General, Location, and Purchasing subsets are stored as direct attributes
    ### Location and Purchasing are defined in the Locatable and Purchasable mixin modules.
    ### Here's General, in alphabetical order
    
    ### String - the secondary mac address
    attr_reader :alt_mac_address
    alias  alt_macaddress alt_mac_address
    
    ### String - the asset tag
    attr_reader :asset_tag
    
    ### String - the barcodes
    attr_reader :barcode_1, :barcode_2
    alias bar_code_1 barcode_1
    alias bar_code_2 barcode_2
    
    ### String - The name of the distribution point for this computer
    attr_reader :distribution_point
    
    ### DateTime - when was it added to the JSS
    attr_reader :initial_entry_date
    
    ### IPAddr - the last known IP address
    attr_reader :ip_address
    
    ### String - the version of the jamf binary
    attr_reader :jamf_version
    
    ### DateTime - the last contact time
    attr_reader :last_contact_time
    
    ### String - the primary macaddress
    attr_reader :mac_address
    
    ### Boolean - is this machine "managed" by Casper?
    attr_reader :managed
    alias managed? managed
    
    ### String - the name of the management account
    attr_reader :management_username
    
    ### Boolean - doesit support MDM?
    attr_reader :mdm_capable
    alias mdm? mdm_capable
    
    ### String - the name of the netboot server for this machine
    attr_reader :netboot_server
    
    ### String - what kind of computer?
    attr_reader :platform
    
    ### DateTime - the last recon time
    attr_reader :report_date
    alias last_recon report_date
    
    ### String - the serial number
    attr_reader :serial_number
    alias sn serial_number
    alias serialnumber serial_number
    
    ### Hash - the :name and :id of the site for this machine
    attr_reader :site
    
    ### String - the name of the Software Update Server assigned to this machine.
    attr_reader :sus
    
    ### String - the UDID of the computer
    attr_reader :udid
    
    
    ############
    ### The remaining subsets each go into an attribute of their own.
    ###
    
    ### configuration_profiles -  An Array of Hashes, one for each ConfigurationProfile on the computer
    ### 
    ### The Hash keys are:
    ### * :id => the ConfigurationProfile id in the JSS
    ### * :name => the username to whom this user-level profile has been applied
    ### * :uuid => the ConfigurationProfile uuid
    ###
    attr_reader :configuration_profiles
    
    ### extension_attributes - An Array of Hashes, one for each ComputerExtentionAttribute
    ###
    ### The Hash keys are:
    ### * :id => the ExtAttrib id
    ### * :name => the ExtAttrib name
    ### * :type => the data type of the ExtAttrib value, one of JSS::ComputerExtentionAttribute::DATA_TYPES
    ### * :value => the value for the ExtAttrib on this computer as of the last report.
    ###
    attr_reader :extension_attributes
    
    ### groups_accounts - A Hash containing info about the local accts and ComputerGroups to which
    ### this machine beloings
    ###
    ### The Hash keys are:
    ### * :computer_group_memberships => An Array of names of ComputerGroups to which this computer belongs
    ### * :local_accounts => An Array of Hashes for each local user acct on this computer. Each hash has these keys:
    ###   *   :name => String, the login name of the acct
    ###   *   :realname => the real name of the acct
    ###   *   :uid => String, the uid of the acct
    ###   *   :home => String, the path to the home folder
    ###   *   :home_size => String,  the size of the homedir as a string like "53245MB"
    ###   *   :home_size_mb => Integer,  the size of the homedir as an integer like 53245
    ###   *   :administrator => Boolean
    ###   *   :filevault_enabled => Boolean
    ###
    attr_reader :groups_accounts
    
    ### hardware - A Hash with these keys & sample data
    ###
    ### * :number_processors=>2,
    ### * :processor_speed_mhz=>2530,
    ### * :make=>"Apple",
    ### * :cache_size=>3072,
    ### * :processor_type=>"Intel Core i5",
    ### * :total_ram_mb=>8192,
    ### * :model=>"15-inch MacBook Pro (Mid 2010)",
    ### * :available_ram_slots=>0,
    ### * :processor_architecture=>"i386",
    ### * :bus_speed_mhz=>0,
    ### * :total_ram=>8192,
    ### * :os_name=>"Mac OS X",
    ### * :optical_drive=>"HL-DT-ST DVDRW  GS23N",
    ### * :model_identifier=>"MacBookPro6,2",
    ### * :cache_size_kb=>3072,
    ### * :boot_rom=>"MBP61.0057.B0F",
    ### * :os_version=>"10.9.3",
    ### * :mapped_printers=> An Array of Hashes, one per printer, with these keys
    ###   *  :name => the name of the printer
    ###   *  :location => the location of the printer
    ###   *  :type => the printer model
    ###   *  :uri => the uri to reach the printer on the network
    ### * :nic_speed=>"10/100/1000",
    ### * :processor_speed=>2530,
    ### * :active_directory_status=>"Not Bound",
    ### * :bus_speed=>0,
    ### * :os_build=>"13D65",
    ### * :smc_version=>"1.58f17",
    ### * :service_pack=>"",
    ### * :battery_capacity=>87
    ### * :storage=> An Array of Hashes, one per Drive, with these keys
    ###   * :smart_status=>"Verified",
    ###   * :connection_type=>"NO",
    ###   * :model=>"M4-CT256M4SSD2",
    ###   * :revision=>"040H",
    ###   * :serial_number=>"00000000130709JH7GhhC",
    ###   * :size=>262205,
    ###   * :disk=>"disk0",
    ###   * :drive_capacity_mb=>262205}],
    ###   * :partition=> A Hash with these keys
    ###     * :filevault2_status=>"Encrypted",
    ###     * :type=>"boot",
    ###     * :filevault2_percent=>100,
    ###     * :partition_capacity_mb=>38014,
    ###     * :lvgUUID=>"C4883AF5-3E58-4F76-A56C-094D4CEC7E9F",
    ###     * :percentage_full=>61,
    ###     * :lvUUID=>"745A262E-AEA6-4608-8A3A-6CDC225B4DE6",
    ###     * :filevault_status=>"Encrypted",
    ###     * :size=>38014,
    ###     * :pvUUID=>"C38051CF-5066-442F-A442-1035060ED462",
    ###     * :name=>"KimDrive40 (Boot Partition)",
    ###     * :filevault_percent=>100
    ###
    attr_reader :hardware
    
    ### DEPRECATED
    ### attr_reader :iphones 
    
    ### peripherals - An Array of Hashes, one per periph
    ###
    ### Each hash has keys & sample data:
    ### *  :id=>286,
    ### *  :type=>"Display",
    ### *  :field_0=>"HP",
    ### *  :field_1=>"HP LP2480zx",
    ### *  :field_2=>"DreamColor",
    ### *  :field_3=>"3CM10800F4",
    ### *  :field_4=>"",
    ### *  :field_5=>""
    ### *  :field_6=>"",
    ### *  :bar_code_1=>"",
    ### *  :bar_code_2=>"",
    ### *  :purchasing=> A hash with these keys:
    ###    * :warranty_expires_utc=>"",
    ###    * :is_leased=>false,
    ###    * :po_date=>"",
    ###    * :lease_expires=>"",
    ###    * :po_number=>"",
    ###    * :po_date_epoch=>0,
    ###    * :lease_expires_epoch=>0,
    ###    * :vendor=>"",
    ###    * :attachments=>[],
    ###    * :po_date_utc=>"",
    ###    * :lease_expires_utc=>"",
    ###    * :applecare_id=>"",
    ###    * :warranty_expires=>"",
    ###    * :life_expectancy=>0,
    ###    * :purchase_price=>"",
    ###    * :warranty_expires_epoch=>0,
    ###    * :is_purchased=>true,
    ###    * :purchasing_contact=>"",
    ###    * :purchasing_account=>""
    ###
    attr_reader :peripherals
    
    ### software - a Hash of softwar data
    ###
    ### The Hash has these keys:
    ### * :running_services => An Array of services running on the computer (if gathered) TODO - is each item a hash?
    ### * :installed_by_casper => An Array of Package names unstalled on this computer by Casper
    ### * :fonts => An Array of fonts on this computer (if gathered) TODO - is each item a hash?
    ### * :installed_by_installer_swu => An Array of pkg IDs for pkgs installed by SoftwareUpdate or the Apple Installer
    ### * :applications => An Array of Hashes, one per Application on the computer, with these keys:
    ###   *   :path => String, the path to the app
    ###   *   :name => String, the name of the app, including the .app suffix
    ###   *   :version => String, the version of the app at that path.
    ### * :cached_by_casper => An Array of Casper Package names cached on the machine, awaiting installation
    ### * :available_software_updates => An Array of available SoftwareUpdate (if gathered) TODO - is each item a hash?
    ### * :plugins => An Array of plugins installed on the machine (if gathered) TODO - is each item a hash?
    ### * :available_updates => A Hash - Deprecated?
    ### * :licensed_software => An Array, the names of Licenced Software (as defined in Casper) on this machine
    ### * :unix_executables => DEPRECATED
    ###
    attr_reader :software
    
    #####################################
    ### Instance Methods
    #####################################
    
    ###
    ### @param (see APIObject#initialize)
    ### As well as :id and :name, computers can be queried using :udid, :serialnumber, and :mac_address
    ###
    def initialize (args = {})
      
      super args, [:udid, :serialnumber, :mac_address]
      
      ### now we have raw @init_data with something in it, so fill out the instance vars
      @alt_mac_address = @init_data[:general][:alt_mac_address]
      @asset_tag = @init_data[:general][:asset_tag]
      @barcode_1 = @init_data[:general][:barcode_1]
      @barcode_2 = @init_data[:general][:barcode_2]
      @distribution_point = @init_data[:general][:distribution_point]
      @initial_entry_date = JSS.parse_datetime @init_data[:general][:initial_entry_date_epoch]
      @ip_address = @init_data[:general][:ip_address]
      @jamf_version = @init_data[:general][:jamf_version]
      @last_contact_time = JSS.parse_datetime @init_data[:general][:last_contact_time_epoch]
      @mac_address = @init_data[:general][:mac_address]
      @managed = @init_data[:general][:remote_management][:managed]
      @management_username = @init_data[:general][:remote_management][:management_username]
      @mdm_capable = @init_data[:general][:mdm_capable]
      @netboot_server = @init_data[:general][:netboot_server]
      @platform = @init_data[:general][:platform]
      @report_date = JSS.parse_datetime @init_data[:general][:report_date_epoch]
      @serial_number = @init_data[:general][:serial_number]
      @site = @init_data[:general][:site]
      @sus = @init_data[:general][:sus]
      @udid = @init_data[:general][:udid]
      
      parse_location
      parse_purchasing
      
      @configuration_profiles = @init_data[:configuration_profiles]
      @extension_attributes = @init_data[:extension_attributes]
      @groups_accounts = @init_data[:groups_accounts]
      @hardware = @init_data[:hardware]
      @peripherals = @init_data[:peripherals]
      @software = @init_data[:software]
      
      @management_password = nil
      
    end # initialize  
    
    ###
    ### @return [Array] the JSS groups to which thismachine belongs (smart and static)
    ###
    def computer_groups
      @groups_accounts[:computer_group_memberships]
    end
    
    ###
    ### @return [Array<Hash>] all the local accts on the machine. 
    ###   Each item has keys :name, :realname, :uid, :home, :home_size, :administrator, :filevault_enabled
    ###
    def local_accounts
      @groups_accounts[:local_accounts]
    end
    alias accounts local_accounts
    alias accts local_accounts
    
    ###
    ### @return [Array<Hash>]  each storage device
    ### 
    def drives
      @hardware[:storage]
    end
    
    ###
    ### @return [Array<Hash>]  each printer on this computer
    ###   Keys are :name, :uri, :type, :location
    ###
    def printers
      @hardware[:mapped_printers]
    end
    
    ###
    ### @return [Array<Hash>]  all apps installed on this machine.
    ###   Hash keys are :name, :path, and :version
    ###
    def apps ; @software[:applications] ; end
    
    ###
    ### @return [Array<String>] the JSS-defined "licensed software" titles
    ###   installed on this machine.
    ###
    def licensed_sw ; @software[:licensed_software] ; end
    
    ###
    ### Set or unset management acct and password for this computer
    ###
    ### @param name[String] the name of the management acct.
    ### @param password[String] the password of the management acct
    ###
    ### The changes will need to be pushed to the server with #update
    ### before they take effect. 
    ###
    ### CAUTION: this does nothing to confirm the name and password
    ### will work on the machine!
    ###
    def set_management_to (name, password)
      password = nil unless name
      @management_username = name
      @management_password = password
      @managed = name ? true : false
      @need_to_update = true
    end
    alias make_managed set_management_to
    
    ###
    ### Make the machine unmanaged.
    ###
    ### The same as 
    ###   #set_management_to nil, nil
    ### followed by
    ###   JSS::Computer.send_mdm_command @id, :unmanage_device
    ### 
    def make_unmanaged
      return nil unless managed?
      set_management_to(nil, nil)
      begin
        self.class.send_mdm_command(@id, :unmanage_device)
      rescue
      end
    end
    
    ###
    def asset_tag= (new_val)
      return nil if @asset_tag == new_val
      new_val.strip!
      @asset_tag = new_val
      @need_to_update = true
    end
    
    ###
    def barcode_1= (new_val)
      return nil if @barcode_1 == new_val
      new_val.strip!
      @barcode_1 = new_val
      @need_to_update = true
    end
    
    ###
    def barcode_2= (new_val)
      return nil if @barcode_2 == new_val
      new_val.strip!
      @barcode_2 = new_val
      @need_to_update = true
    end
    
    ###
    def ip_address= (new_val)
      return nil if @ip_address == new_val
      new_val.strip!
      ### this raises an error if its an invalid IP address
      IPAddr.new new_val
      @ip_address = new_val
      @need_to_update = true
    end
    
    ###
    def udid= (new_val)
      return nil if @udid == new_val
      new_val.strip!
      ### make sure it isn't already there
      begin
        JSS::Computer.new :udid => new_val
        raise JSS::AlreadyExistsError, "A computer with UDID #{new_val} already exists in the JSS"
      rescue JSS::NoSuchItemError
      end
      @udid = new_val
      @need_to_update = true
    end
    
    ###
    def mac_address= (new_val)
      return nil if @mac_address == new_val
      new_val.strip!
      raise JSS::InvalidDataError, "Primary MAC Address can't be emtpy" if new_val.to_s.empty?
      raise JSS::InvalidDataError, "Primary MAC Address can't be the same as the secondary" if new_val == @alt_mac_address
      begin
        other_id = JSS::Computer.new(:macaddress => new_val).id
        raise JSS::AlreadyExistsError, "A computer with MAC Address #{new_val} already exists in the JSS" unless @id == other_id
      rescue JSS::NoSuchItemError
      end
      @mac_address = new_val
      @need_to_update = true
    end
    
    ###
    def alt_mac_address= (new_val)
      return nil if @alt_mac_address == new_val
      new_val.strip!
      raise JSS::InvalidDataError, "Secondary MAC Address can't be the same as the primary" if new_val == @alt_mac_address
      begin
        other_id = JSS::Computer.new(:macaddress => new_val).id
        raise JSS::AlreadyExistsError, "A computer with MAC Address #{new_val} already exists in the JSS" unless @id == other_id
      rescue JSS::NoSuchItemError
      end
      @alt_mac_address = new_val
      @need_to_update = true
    end
    
    ###
    ### Send changes to the API
    ###
    def update
      super
      @management_password = nil
    end
    
    ###
    ### Delete this computer from the JSS 
    ###
    def delete
      super
      @alt_mac_address = nil
      @asset_tag = nil
      @barcode_1 = nil
      @barcode_2 = nil
      @distribution_point = nil
      @initial_entry_date = nil
      @ip_address = nil
      @jamf_version = nil
      @last_contact_time = nil
      @macaddress = nil
      @managed = nil
      @management_username = nil
      @mdm_capable = nil
      @netboot_server = nil
      @platform = nil
      @report_date = nil
      @serial_number = nil
      @site = nil
      @sus = nil
      @udid = nil
      
      @building = nil
      @department = nil
      @email_address = nil
      @phone = nil
      @position = nil
      @real_name = nil
      @room = nil
      @username = nil
      
      @configuration_profiles = nil
      @extension_attributes = nil
      @groups_accounts = nil
      @hardware = nil
      @peripherals = nil
      @purchasing = nil
      @software = nil
    end #delete
    
    ###
    ### Send a blank_push MDM command
    ###
    def blank_push
      self.class.send_mdm_command @id, :blank_push
    end
    alias noop blank_push
    alias send_blank_push blank_push
    
    ###
    ### Send a device_lock MDM command
    ###
    def device_lock
      self.class.send_mdm_command @id, :device_lock
    end
    alias lock device_lock
    alias lock_device device_lock
    
    ###
    ### Send an erase_device MDM command
    ###
    def erase_device
      self.class.send_mdm_command @id, :erase_device
    end
    alias erase erase_device
    alias wipe erase_device
    
    
    ##############################
     ### private methods
    ##############################
    private
    
    ###
    ### Return a String with the XML Resource
    ### for submitting  changes to the JSS via
    ### the API
    ###
    ### For Computers, only some items can be changed via the API
    ### In particular, any data gatherd by a Recon cannot be changed
    ###
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      computer = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      
      general = computer.add_element('general')
      general.add_element('name').text = @name
      general.add_element('alt_mac_address').text = @alt_mac_address
      general.add_element('asset_tag').text = @asset_tag
      general.add_element('barcode_1').text = @barcode_1
      general.add_element('barcode_2').text = @barcode_2
      general.add_element('ip_address').text = @ip_address
      general.add_element('mac_address').text = @mac_address
      general.add_element('udid').text = @udid
      
      rmgmt = general.add_element('remote_management')
      rmgmt.add_element('managed').text = @managed
      rmgmt.add_element('management_username').text = @management_username
      rmgmt.add_element('management_password').text = @management_password if @management_password

      computer << location_xml
      computer << purchasing_xml
      return doc.to_s
    end
    
  end # class Computer
end # module