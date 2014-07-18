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

  ############
  ### This class represents Mobile Devices stored in the JSS.
  ###
  ### See JSS::APIObject for general info on instantiating.
  ###
  ### The API returns MobileDevice data in Subsets.  The items in the General, Location
  ### and Purchasing subsets are stored in direct attributes of the instance.  In otherwords
  ### there are no @general, @purchasing or @location attributes matching the :general and :location
  ### hashes that come with the API JSON data, but rather the items in those JSON hashes
  ### are attributes of the MobileDevice instance.
  ###
  ### The other subsets each are stored in an attribute as hashes, as they come in from the
  ### JSON data, and are currently not editable via this class.
  ###
  ### Those are:
  ###  :applications,
  ###  :certificates,
  ###  :configuration_profiles,
  ###  :extension_attributes,
  ###  :mobile_device_groups,
  ###  :network,
  ###  :provisioning_profiles,
  ###  :security
  ###
  ### subset :applications - An Array (of hashes?)
  ###
  ### subset :certificates - an Array oh Hashes with these keys
  ###   :identity => Boolean
  ###   :common_name => String, possibly a udid
  ###
  ### subset :configuration_profiles - An Array of Hashes, one for each ConfigurationProfile on the device
  ### The Hash keys are:
  ###  :identifier => a unique id, often the sams as the uuid
  ###  :display_name => its name in the JSS
  ###  :uuid => the ConfigurationProfile uuid
  ###  :version => a String
  ###
  ### subset :extension_attributes - An Array of Hashes, one for each ComputerExtentionAttribute
  ### The Hash keys are:
  ###  :id => the ExtAttrib id
  ###  :name => the ExtAttrib name
  ###  :type => the data type of the ExtAttrib value
  ###  :value => the value for the ExtAttrib on this computer as of the last report.
  ###
  ### subset :mobile_device_groups - An Array of Hashes, one for each group to which the device belongs
  ### The Hash keys are:
  ###  :name => the group name
  ###  :id => the group id in the JSS
  ###
  ### subset :network - A Hash, with these keys
  ### The Hash keys are:
  ###   :voice_roaming_enabled=>"Disabled",
  ###   :current_mobile_network_code=>"nnn",
  ###   :imei=>"nn nnnnnn nnnnnn n",
  ###   :home_mobile_country_code=>"nnn",
  ###   :iccid=>"nnnn nnnn nnnn nnnn nnnn",
  ###   :home_mobile_network_code=>"nnn",
  ###   :current_carrier_network=>"",
  ###   :data_roaming_enabled=>false,
  ###   :home_carrier_network=>"AT&T",
  ###   :carrier_settings_version=>"16.0",
  ###   :roaming=>false,
  ###   :cellular_technology=>"GSM",
  ###   :current_mobile_country_code=>"nnn"
  ###
  ### subset :provisioning_profiles - An Array (of of Hashes?)
  ###
  ### subset :security - A Hash with these keys, all of which are Boolean
  ###   :passcode_present=>true,
  ###   :passcode_compliant=>true,
  ###   :passcode_compliant_with_profile=>true,
  ###   :data_protection=>true,
  ###   :block_level_encryption_capable=>true,
  ###   :file_level_encryption_capable=>true
  ###
  ### See also JSS::APIObject
  ###
  class MobileDevice < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    include JSS::Updatable
    include JSS::Locatable
    include JSS::Purchasable
    include JSS::Matchable
    include JSS::FileUpload

    #####################################
    ### Class Methods
    #####################################

    def self.all_serial_numbers(refresh = false)
      self.all(refresh).map{|i| i[:serial_number]}
    end

    def self.all_phone_numbers(refresh = false)
      self.all(refresh).map{|i| i[:phone_number]}.select{|p| not p.empty?}
    end

    def self.all_wifi_mac_addresses(refresh = false)
      self.all(refresh).map{|i| i[:wifi_mac_address]}
    end

    def self.all_udids(refresh = false)
      self.all(refresh).map{|i| i[:udid]}
    end

    ### the list of all managed mobile devices
    def self.all_managed(refresh = false)
      self.all(refresh).select{|d| d[:managed] }
    end

    ### the list of all unmanaged mobile devices
    def self.all_unmanaged(refresh = false)
      self.all(refresh).select{|d| not d[:managed] }
    end

    ### the list of all iPhones
    def self.all_iphones(refresh = false)
      self.all(refresh).select{|d| d[:model].start_with? "iPhone" }
    end

    ### the list of all iPads
    def self.all_ipads(refresh = false)
      self.all(refresh).select{|d| d[:model].start_with? "iPad" }
    end

    ###
    ### Send an MDM command to a managed mobile device by JSS id, name, udid,
    ### serialnumber, wifi_mac_address, or phone number.
    ###
    ### The first arg is the device identifier, the second is the command to send.
    ### See the keys of API_MDM_COMMANDS for a list of available commands and alternatives.
    ###
    ### Returns true if the command was sent
    ###
    def self.send_mdm_command(dev,command)

      raise JSS::NoSuchItemError, "Unknown command '#{command}'" unless API_MDM_COMMANDS.keys.include? command
      command_xml ="#{JSS::APIConnection::XML_HEADER}<mobile_device><command>#{API_MDM_COMMANDS[command]}</command></mobile_device>"
      the_id = nil
      self.all_managed.each do |mmd|
        if [mmd[:id], mmd[:name], mmd[:serial_number], mmd[:phone_number], mmd[:udid], mmd[:wifi_mac_address]].include? dev
          the_id = mmd[:id]
          break
        end
      end # each do mmd

      if the_id
        response = JSS::API.put_rsrc( "#{RSRC_BASE}/id/#{the_id}", command_xml)
        response =~ %r{<notification_sent>(.+)</notification_sent>}
        return ($1 and $1 == "true")
      end
      raise JSS::UnmanagedError, "Cannot send command to unknown/unmanaged device '#{dev}'"
    end

    #####################################
    ### Class Constants
    #####################################
     ### The base for REST resources of this class
    RSRC_BASE = "mobiledevices"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_devices

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:device_name, :capacity, :tethered ]

    ### This class lets us seach for computers
    SEARCH_CLASS = JSS::AdvancedMobileDeviceSearch

    #######
    ### The MDM commands sendable via the api
    ### and alternative versions
    ###
    API_MDM_COMMANDS = {
      :blank_push => "BlankPush",
      :send_blank_push => "BlankPush",
      :blank => "BlankPush",
      :noop => "BlankPush",
      :update_inventory => "UpdateInventory",
      :recon => "UpdateInventory",
      :device_lock => "DeviceLock",
      :lock => "DeviceLock",
      :lock_device => "DeviceLock",
      :erase_device => "EraseDevice",
      :erase => "EraseDevice",
      :wipe => "EraseDevice",
      :clear_passcode => "ClearPasscode",
      :unmanage_device => "UnmanageDevice",
      :unmanage => "UnmanageDevice"
    }


    #####################################
    ### Attributes
    #####################################

    ############
    ### The values returned in the General and Location subset are stored as direct attributes
    ### Here are the  Location values

    ### String - the airplay passwd on devices that can receive AirPlay (i.e. apple tvs)
    attr_reader :airplay_password

    ### String
    attr_reader :asset_tag

    ### Intger - how much space available on the device?
    attr_reader :available_mb

    ### Integer - total storage on the device
    attr_reader :capacity_mb

    ### Integer - how much of the capacity is in use?
    attr_reader :percentage_used

    ### Integer - what percentage of the battery is remaining
    attr_reader :battery_level
    alias battery_percent battery_level

    ### String
    attr_reader :bluetooth_mac_address

    ### String
    attr_reader :wifi_mac_address

    ### Hash - {:name=>"xxx", :id=>nnn} the computer associated with this device
    attr_reader :computer

    ### String - what is this??
    attr_reader :device_id

    ### String - the API's device_name and display_name are not used.
    attr_reader :name

    ### DateTime - uses the value from the API's initial_entry_date_epoch
    attr_reader :initial_entry_date

    ### String
    attr_reader :ip_address

    ### String
    attr_reader :languages


    ### DateTime - uses the value from the API's last_backup_time_epoch
    attr_reader :last_backup_time

    ### DateTime - uses the value from the API's last_inventory_update_utc
    attr_reader :last_inventory_update

    ### String
    attr_reader :locales

    ### Boolean
    attr_reader :managed
    alias managed? managed

    ### String
    attr_reader :model_display

    ### String
    attr_reader :model_identifier

    ### String
    attr_reader :modem_firmware

    ### String
    attr_reader :os_version

    ### String
    attr_reader :os_build

    ### String - the phone number of the device's SIM card
    attr_reader :phone_number

    ###String
    attr_reader :serial_number
    alias sn serial_number
    alias serialnumber serial_number

    ### Hash {:name=>"xxx", :id=>nnn} the site associated with this device
    attr_reader :site

    ### Boolean
    attr_reader :supervised

    ### String
    attr_reader :tethered

    ### String
    attr_reader :udid

    ### The other subsets, see the class documentation for details

    attr_reader :applications

    attr_reader :certificates

    attr_reader :configuration_profiles

    attr_reader :extension_attributes

    attr_reader :mobile_device_groups

    attr_reader :network

    attr_reader :provisioning_profiles

    attr_reader :security


    #####################################
    ### Instance Methods
    #####################################

    ###
    ### Args must include :id, :udid, :serial_number, :macaddress, :name or :data
    ###
    ### ===MDM Commands
    ###
    ### The following methods can be used to send an APNS command to the device, equivalent to
    ### clicking one of the buttons on the Management Commands section of the Management tab
    ### of the Mobile Device details page in the JSS UI.
    ###
    ### The methods supported are:
    ### - blank_push  (aliases blank, noop, send_blank_push)
    ### - update_inventory (alias recon)
    ### - device_lock (aliases lock, lock_device)
    ### - erase_device (aliases wipe)
    ### - clear_passcode
    ### - unmanage_device (alias unmanage)
    ###
    ### Each returns true if the command as sent.
    ###
    ### ===Editing values
    ###
    ### Only a few values can be changed via the API, using these methods, q.v:
    ### - #asset_tag=  String
    ### - #extension_attribute=  Hash of :name or :id, and :value
    ### - #location= Hash of values in @location, not all are required
    ### - #purchasing= Hash of values in @purchasing, not all are required
    ###
    ### After modfying any values, #save must be called to save changes to the JSS.
    ###
    ### ===Adding devices to the JSS
    ###
    ### This class cannot be used to add new mobile devices to the JSS. That can only be done
    ### via the enrollment process.  See JSS::MobileDeviceInvitation for sending
    ### an enrollment invite to a device.
    ###
    ### For more info, see:
    ### https://your.casper.server:8443/api/index.htm#!/mobiledevices/findMobileDevicesByIdSubset_get
    ###
    def initialize(args = {})

      super args, [:udid, :serialnumber, :macaddress]

      gen = @init_data[:general]
      @airplay_password = gen[:airplay_password]
      @asset_tag = gen[:asset_tag]
      @available_mb = gen[:available_mb]
      @battery_level = gen[:battery_level]
      @bluetooth_mac_address = gen[:bluetooth_mac_address]
      @capacity_mb = gen[:capacity_mb]
      @computer = gen[:computer]
      @device_id = gen[:device_id]
      @device_name = gen[:device_name]
      @display_name = gen[:display_name]
      @initial_entry_date = JSS.parse_datetime gen[:initial_entry_date_epoch]
      @ip_address = gen[:ip_address]
      @languages = gen[:languages]
      @last_backup_time = JSS.parse_datetime  gen[:last_backup_time_epoch]
      @last_inventory_update = JSS.parse_datetime gen[:last_inventory_update_epoch]
      @locales = gen[:locales]
      @managed = gen[:managed]
      @model_display = gen[:model_display]
      @model_identifier = gen[:model_identifier]
      @modem_firmware = gen[:modem_firmware]
      @os_build = gen[:os_build]
      @os_version = gen[:os_version]
      @percentage_used = gen[:percentage_used]
      @phone_number = gen[:phone_number]
      @serial_number = gen[:serial_number]
      @site = gen[:site]
      @supervised = gen[:supervised]
      @tethered = gen[:tethered]
      @udid = gen[:udid]
      @wifi_mac_address = gen[:wifi_mac_address]

      parse_location
      parse_purchasing

      @mobile_device_groups = @init_data[:mobile_device_groups]
      @network = @init_data[:network]
      @extension_attributes = @init_data[:extension_attributes]
      @certificates = @init_data[:certificates]
      @configuration_profiles = @init_data[:configuration_profiles]
      @provisioning_profiles = @init_data[:provisioning_profiles]
      @security = @init_data[:security]

    end # initialize

    ###
    ### Send a blank_push MDM command
    ###
    def blank_push
      self.class.send_mdm_command @id, :blank_push
    end
    alias noop blank_push
    alias send_blank_push blank_push


    ###
    ### Send an update_inventory MDM command
    ###
    def update_inventory
      self.class.send_mdm_command @id, :update_inventory
    end
    alias recon update_inventory

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

    ###
    ### Send a clear_passcode MDM command
    ###
    def clear_passcode
      self.class.send_mdm_command @id, :clear_passcode
    end

    ###
    ### Send a unmanage_device MDM command
    ###
    def unmanage_device
      @managed = false if send_mdm_command(:unmanage_device)
    end
    alias unmanage unmanage_device
    alias make_unmanaged unmanage_device

    ##############################
    private # private methods
    ##############################



  end # class Mobile Device
end # module
