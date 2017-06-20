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
  ### This class represents a Mobile Device stored in the JSS.
  ###
  ### ---
  ### ===Adding devices to the JSS
  ###
  ### This class cannot be used to add new mobile devices to the JSS. That can only be done
  ### via the enrollment process.  See JSS::MobileDeviceInvitation for sending
  ### an enrollment invite to a device.
  ###
  ### ---
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
  ### ---
  ### ===MDM Commands
  ###
  ### The following methods can be used to send an APNS command to the device represented by an
  ### instance of JSS::MobileDevice, equivalent to clicking one of the buttons on
  ### the Management Commands section of the Management tab of the Mobile Device details page in the JSS UI.
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
  ### @see JSS::APIObject
  ###
  ###
  class MobileDevice < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    include JSS::Updatable
    include JSS::Locatable
    include JSS::Purchasable
    include JSS::Uploadable
    include JSS::Extendable

    extend JSS::Matchable

    #####################################
    ### Class Methods
    #####################################

    ### @return [Array<String>] all mobiledevice serial_numbers
    def self.all_serial_numbers(refresh = false)
      self.all(refresh).map{|i| i[:serial_number]}
    end

    ### @return [Array<String>] all mobiledevice phone numbers
    def self.all_phone_numbers(refresh = false)
      self.all(refresh).map{|i| i[:phone_number]}.select{|p| not p.empty?}
    end

    ### @return [Array<String>] all mobiledevice wifi mac addrs
    def self.all_wifi_mac_addresses(refresh = false)
      self.all(refresh).map{|i| i[:wifi_mac_address]}
    end

    ### @return [Array<String>] all mobiledevice udids
    def self.all_udids(refresh = false)
      self.all(refresh).map{|i| i[:udid]}
    end

    ### @return [Array<Hash>] the list of all managed mobile devices
    def self.all_managed(refresh = false)
      self.all(refresh).select{|d| d[:managed] }
    end

    ### @return [Array<Hash>] the list of all unmanaged mobile devices
    def self.all_unmanaged(refresh = false)
      self.all(refresh).select{|d| not d[:managed] }
    end

    ### @return [Array<Hash>] the list of all iPhones
    def self.all_iphones(refresh = false)
      self.all(refresh).select{|d| d[:model].start_with? "iPhone" }
    end

    ### @return [Array<Hash>] the list of all iPads
    def self.all_ipads(refresh = false)
      self.all(refresh).select{|d| d[:model].start_with? "iPad" }
    end

    ###
    ### Send an MDM command to a managed mobile device.
    ###
    ### @param dev[Integer,String] the id, name, serialnum, udid, phone num, or wifi macaddr of the device
    ###
    ### @param command[Symbol] the command to send, one of the keys of MOBILE_DEV_MDM_COMMANDS
    ###
    ### @return [Boolean] true if command was sent successfully
    ###
    ### See also {#blank_push}, {#update_inventory}, {#device_lock},
    ### {#erase_device}, {#clear_passcode}, and {#unmanage_device}
    ###
    def self.send_mdm_command(dev,command)

      raise JSS::NoSuchItemError, "Unknown command '#{command}'" unless MOBILE_DEV_MDM_COMMANDS.keys.include? command
      command_xml ="#{JSS::APIConnection::XML_HEADER}<mobile_device><command>#{MOBILE_DEV_MDM_COMMANDS[command]}</command></mobile_device>"
      the_id = nil
      self.all_managed.each do |mmd|
        if [mmd[:id], mmd[:name], mmd[:serial_number], mmd[:phone_number], mmd[:udid], mmd[:wifi_mac_address]].include? dev
          the_id = mmd[:id]
          break
        end
      end # each do mmd

      if the_id
        response = JSS.api_connection.put_rsrc( "#{RSRC_BASE}/id/#{the_id}", command_xml)
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

    ### these keys,  as well as :id and :name, can be used to look up objects of this class in the JSS
    OTHER_LOOKUP_KEYS = {
      udid: {rsrc_key: :udid, list: :all_udids},
      serialnumber: {rsrc_key: :serialnumber, list: :all_serial_numbers},
      serial_number: {rsrc_key: :serialnumber, list: :all_serial_numbers},
      macaddress: {rsrc_key: :macaddress, list: :all_wifi_mac_addresses},
      mac_address: {rsrc_key: :macaddress, list: :all_wifi_mac_addresses}
    }.freeze

    ### This class lets us seach for computers
    SEARCH_CLASS = JSS::AdvancedMobileDeviceSearch

    ### This is the class for relevant Extension Attributes
    EXT_ATTRIB_CLASS = JSS::MobileDeviceExtensionAttribute

    #######
    ### The MDM commands sendable via the api
    ### and alternative versions
    ###
    MOBILE_DEV_MDM_COMMANDS = {
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

    ### @return [String] the airplay passwd on devices that can receive AirPlay (i.e. apple tvs)
    attr_reader :airplay_password

    ### @return [String] the asset tag
    attr_reader :asset_tag

    ### @return [Intger] how much space available on the device?
    attr_reader :available_mb

    ### @return [Integer] total storage on the device
    attr_reader :capacity_mb

    ### @return [Integer] how much of the capacity is in use?
    attr_reader :percentage_used

    ### @return [Integer] what percentage of the battery is remaining
    attr_reader :battery_level

    ### @return [String] the bluetooth mac addr
    attr_reader :bluetooth_mac_address

    ### @return [String] the wifi mac addr
    attr_reader :wifi_mac_address

    ### @return [Hash] !{:name=>"xxx", :id=>nnn} the computer associated with this device
    attr_reader :computer

    ### @return [String] what is this??
    attr_reader :device_id

    ### @return [String] the API's device_name and display_name are not used.
    attr_reader :name

    ### @return [Time] uses the value from the API's initial_entry_date_epoch
    attr_reader :initial_entry_date

    ### @return [String] the IP addr
    attr_reader :ip_address

    ### @return [String] the language setting
    attr_reader :languages


    ### @return [Time] uses the value from the API's last_backup_time_epoch
    attr_reader :last_backup_time

    ### @return [Time] uses the value from the API's last_inventory_update_utc
    attr_reader :last_inventory_update

    ### @return [Time] the last time this device enrolled in Jamf
    attr_reader :last_enrollment

    ### @return [String] the locales
    attr_reader :locales

    ### @return [Boolean] is this device managed?
    attr_reader :managed

    ### @return [Boolean] is this device supervised?
    attr_reader :supervised

    ### @return [String] the display name of the model
    attr_reader :model_display
    alias model model_display

    ### @return [String] the model identifier
    attr_reader :model_identifier

    ### @return [String] the model firmware
    attr_reader :modem_firmware

    ### @return [String] the OS version
    attr_reader :os_version

    ### @return [String] the OS build
    attr_reader :os_build

    ### @return [String] the phone number of the device's SIM card
    attr_reader :phone_number

    ### @return [String] the serial numbee
    attr_reader :serial_number


    ### @return [String] the site associated with this device
    attr_reader :site

    ### @return [Boolean] Is this device supervised?
    attr_reader :supervised

    ### @return [String] the tether state of the device
    attr_reader :tethered

    ### @return [String] the udid
    attr_reader :udid

    ### @return [Array<Hash>] the applications on the devices
    attr_reader :applications

    ### @return [Array<Hash>]
    ###
    ### The certificates on the device
    ###
    ### Each has has two keys:
    ### - :identity => Boolean
    ### - :common_name => String, possibly a udid
    attr_reader :certificates

    ### @return [Array<Hash>]
    ###
    ### One for each ConfigurationProfile on the device
    ###
    ### The Hash keys are:
    ### - :identifier => a unique id, often the sams as the uuid
    ### - :display_name => its name in the JSS
    ### - :uuid => the ConfigurationProfile uuid
    ### - :version => a String
    attr_reader :configuration_profiles


    ### @return [Array<Hash>]
    ###
    ### One for each group to which the device belongs
    ###
    ### The Hash keys are:
    ### - :name => the group name
    ### - :id => the group id in the JSS
    attr_reader :mobile_device_groups

    ### @return [Hash]
    ###
    ### A Hash of network data
    ###
    ### The Hash keys are:
    ### - :voice_roaming_enabled=>"Disabled",
    ### - :current_mobile_network_code=>"nnn",
    ### - :imei=>"nn nnnnnn nnnnnn n",
    ### - :home_mobile_country_code=>"nnn",
    ### - :iccid=>"nnnn nnnn nnnn nnnn nnnn",
    ### - :home_mobile_network_code=>"nnn",
    ### - :current_carrier_network=>"",
    ### - :data_roaming_enabled=>false,
    ### - :home_carrier_network=>"AT&T",
    ### - :carrier_settings_version=>"16.0",
    ### - :roaming=>false,
    ### - :cellular_technology=>"GSM",
    ### - :current_mobile_country_code=>"nnn"
    attr_reader :network

    ### @return [Array<Hash>]
    ###
    ### One per provisioning profile
    ###
    attr_reader :provisioning_profiles

    ### @return [Hash]
    ###
    ### A Hash of security data
    ###
    ### The Hash has these keys, all of which are Boolean
    ### - :passcode_present=>true,
    ### - :passcode_compliant=>true,
    ### - :passcode_compliant_with_profile=>true,
    ### - :data_protection=>true,
    ### - :block_level_encryption_capable=>true,
    ### - :file_level_encryption_capable=>true
    attr_reader :security


    #####################################
    ### Instance Methods
    #####################################

    ###
    ### @see APIObject#initialize
    ###
    def initialize(args = {})

      super args

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
      @initial_entry_date = JSS.epoch_to_time gen[:initial_entry_date_epoch]
      @ip_address = gen[:ip_address]
      @languages = gen[:languages]
      @last_backup_time = JSS.epoch_to_time  gen[:last_backup_time_epoch]
      @last_inventory_update = JSS.epoch_to_time gen[:last_inventory_update_epoch]
      @last_enrollment = JSS.epoch_to_time gen[:last_enrollment_epoch]
      @locales = gen[:locales]
      @managed = gen[:managed]
      @supervised = gen[:supervised]
      @model_display = gen[:model_display]
      @model_identifier = gen[:model_identifier]
      @modem_firmware = gen[:modem_firmware]
      @os_build = gen[:os_build]
      @os_version = gen[:os_version]
      @percentage_used = gen[:percentage_used]
      @phone_number = gen[:phone_number]
      @serial_number = gen[:serial_number]
      @site = JSS::APIObject.get_name(gen[:site])
      @supervised = gen[:supervised]
      @tethered = gen[:tethered]
      @udid = gen[:udid]
      @wifi_mac_address = gen[:wifi_mac_address]

      @mobile_device_groups = @init_data[:mobile_device_groups]
      @network = @init_data[:network]
      @extension_attributes = @init_data[:extension_attributes]
      @certificates = @init_data[:certificates]
      @configuration_profiles = @init_data[:configuration_profiles]
      @provisioning_profiles = @init_data[:provisioning_profiles]
      @security = @init_data[:security]
      @applications = @init_data[:applications]

    end # initialize

    ###
    ### Send a blank_push MDM command
    ###
    ### @see MobileDevice.send_mdm_command
    ###
    ### @return [Boolean]
    ###
    def blank_push
      self.class.send_mdm_command @id, :blank_push
    end



    ###
    ### Send an update_inventory MDM command
    ###
    ### @see MobileDevice.send_mdm_command
    ###
    ### @return [Boolean]
    ###
    def update_inventory
      self.class.send_mdm_command @id, :update_inventory
    end

    ###
    ### Send a device_lock MDM command
    ###
    ### @see MobileDevice.send_mdm_command
    ###
    ### @return [Boolean]
    ###
    def device_lock
      self.class.send_mdm_command @id, :device_lock
    end


    ###
    ### Send an erase_device MDM command
    ###
    ### @see MobileDevice.send_mdm_command
    ###
    ### @return [Boolean]
    ###
    def erase_device
      self.class.send_mdm_command @id, :erase_device
    end


    ###
    ### Send a clear_passcode MDM command
    ###
    ### @see MobileDevice.send_mdm_command
    ###
    ### @return [Boolean]
    ###
    def clear_passcode
      self.class.send_mdm_command @id, :clear_passcode
    end

    ###
    ### Send a unmanage_device MDM command
    ###
    ### @see MobileDevice.send_mdm_command
    ###
    ### @return [Boolean]
    ###
    def unmanage_device
      @managed = false if self.class.send_mdm_command(@id, :unmanage_device)
    end


    ### Aliases
    alias battery_percent battery_level
    alias managed? managed
    alias sn serial_number
    alias serialnumber serial_number

    alias noop blank_push
    alias send_blank_push blank_push
    alias recon update_inventory
    alias lock device_lock
    alias lock_device device_lock
    alias erase erase_device
    alias wipe erase_device
    alias unmanage unmanage_device
    alias make_unmanaged unmanage_device




    ##############################
    # private methods
    ##############################

    private

    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      md = doc.add_element self.class::RSRC_OBJECT_KEY.to_s

      md << ext_attr_xml

      if has_location?
        md << location_xml
      end
      if has_purchasing?
        md << purchasing_xml
      end

      return doc.to_s
    end

  end # class Mobile Device
end # module
