### Copyright 2022 Pixar

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
module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  #
  # This class represents a Mobile Device stored in the JSS.
  #
  # ---
  # === Adding devices to the JSS
  #
  # When creating new MobileDevices in the JSS with this class
  # (using {Jamf::MobileDevice.make}) you must specify a udid, and serial_number
  # before calling `create` or `save`. You can provide these values with the
  # `.make` call, or afterward using setters.
  #
  # ---
  # === Management History & Logs
  #
  # MobileDevice Management History and logs can now be retrieved both from a
  # MobileDevice instance, and directly via class methods without fetching an
  # instance. This is handled by the mixed-in {Jamf::ManagementHistory} module,
  # Q.V. for details.
  #
  # ---
  # === MDM Commands
  #
  # See the {Jamf::MDM} mixin module for Class and Instance methods for
  # sending MDM commands to mobiledevices.
  #
  # To send MDM commands without fetching mobiledevice instances, use the class
  # methods, which can take multiple identifiers at once.
  #
  # NOTE: If the {#name=} method is used to change the name of a supervized device,
  # the DeviceName MDM command will be sent to the device when
  # the changes are sent to the server via {#save} or {#update}
  #
  class MobileDevice < Jamf::APIObject

    # Mix-Ins
    #####################################

    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Locatable
    include Jamf::Purchasable
    include Jamf::Uploadable
    include Jamf::Extendable
    include Jamf::Sitable
    include Jamf::MDM
    include Jamf::ManagementHistory

    extend Jamf::Matchable

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'mobiledevices'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_devices

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

    # these keys,  as well as :id and :name, can be used to look up objects
    # of this class in the JSS
    # the wierd alises wifi_mac_addresse,  mac_addresse and macaddresse
    # are for proper pluralization of 'mac_address' and such
    OTHER_LOOKUP_KEYS = {
      udid: {
        aliases: [:uuid, :guid],
        fetch_rsrc_key: :udid
      },
      serial_number: {
        aliases: [:serialnumber, :sn],
        fetch_rsrc_key: :serialnumber
      },
      wifi_mac_address: {
        aliases: [
          :wifi_mac_addresse,
          :mac_address,
          :mac_addresse,
          :macaddress,
          :macaddresse,
          :macaddr
        ],
        fetch_rsrc_key: :macaddress
      }
    }.freeze

    HW_PREFIX_TV = 'AppleTV'.freeze
    HW_PREFIX_IPAD = 'iPad'.freeze
    HW_PREFIX_IPHONE = 'iPhone'.freeze

    NON_UNIQUE_NAMES = true

    # file uploads can send attachments to the JSS using :mobiledevices as the sub-resource.
    UPLOAD_TYPES = { attachment: :mobiledevices }.freeze

    # This class lets us seach for computers
    SEARCH_CLASS = Jamf::AdvancedMobileDeviceSearch

    # This is the class for relevant Extension Attributes
    EXT_ATTRIB_CLASS = Jamf::MobileDeviceExtensionAttribute

    # What kind of devices are we for MDM purposes?
    MDM_COMMAND_TARGET = :mobiledevices

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 21

    # Class Methods
    #####################################

    # @return [Array<String>] all mobiledevice phone numbers
    def self.all_phone_numbers(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).map { |i| i[:phone_number] }.reject(&:empty?)
    end

    # @return [Array<Hash>] the list of all managed mobile devices
    def self.all_managed(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:managed] }
    end

    # @return [Array<Hash>] the list of all unmanaged mobile devices
    def self.all_unmanaged(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).reject { |d| d[:managed] }
    end

    # @return [Array<Hash>] the list of all supervised mobile devices
    def self.all_supervised(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:supervised] }
    end

    # @return [Array<Hash>] the list of all unsupervised mobile devices
    def self.all_unsupervised(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).reject { |d| d[:supervised] }
    end

    # @return [Array<Hash>] the list of all iPhones
    def self.all_iphones(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model].start_with? 'iPhone' }
    end

    # @return [Array<Hash>] the list of all iPads
    def self.all_ipads(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model].start_with? 'iPad' }
    end

    # @return [Array<Hash>] the list of all iPads
    def self.all_apple_tvs(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model_identifier].start_with? 'AppleTV' }
    end

    # Attributes
    #####################################

    ############
    # The values returned in the General subset are stored as direct attributes

    # identifiers
    ###########################

    # @return [String]
    attr_reader :serial_number
    alias sn serial_number
    alias serialnumber serial_number

    # @return [String]
    attr_reader :udid

    # @return [String]
    attr_reader :asset_tag

    # @return [String]
    attr_reader :display_name

    # @return [String]
    attr_reader :device_name

    # @return [String] An Apple TV identifier
    attr_reader :device_id

    # @return [String]
    attr_reader :exchange_activesync_device_identifier

    # settings
    ###########################

    # @return [Boolean] is this device managed?
    attr_reader :managed
    alias managed? managed

    # @return [Boolean] is this device supervised?
    attr_reader :supervised
    alias supervised? supervised

    # @return [String] the device_ownership_level
    attr_reader :device_ownership_level

    # @return [String] the tether state of the device
    attr_reader :tethered

    # @return [Boolean] is this device shared?
    attr_reader :shared

    # @return [Boolean] is this device ble_capable?
    attr_reader :ble_capable

    # @return [String] the airplay passwd on devices that can receive AirPlay (i.e. apple tvs)
    attr_reader :airplay_password

    # @return [String] the languages
    attr_reader :languages

    # @return [String] the locales
    attr_reader :locales

    # software
    ###########################

    # @return [String] the model firmware
    attr_reader :modem_firmware

    # @return [String] the OS version
    attr_reader :os_version

    # @return [String] the OS build
    attr_reader :os_build

    # @return [String] the OS type
    attr_reader :os_type

    # hardware
    ###########################

    # @return [String] the display name of the model
    attr_reader :model

    # @return [String] the display name of the model
    attr_reader :model_number

    # @return [String] the display name of the model
    attr_reader :model_display

    # @return [String] the model identifier
    attr_reader :model_identifier

    # usage
    ##########################

    # @return [Intger] how much space available on the device?
    attr_reader :available_mb
    alias available available_mb

    # @return [Integer] total storage on the device
    attr_reader :capacity_mb
    alias capacity capacity_mb

    # @return [Integer] how much of the capacity is in use?
    attr_reader :percentage_used

    # @return [Integer] what percentage of the battery is remaining
    attr_reader :battery_level
    alias battery_percent battery_level

    # network
    ##########################

    # @return [String] the bluetooth mac addr
    attr_reader :bluetooth_mac_address

    # @return [String] the wifi mac addr
    attr_reader :wifi_mac_address

    # @return [String] the IP addr
    attr_reader :ip_address

    # @return [String] the phone number of the device's SIM card
    attr_reader :sim_phone_number
    alias device_phone_number sim_phone_number

    # timestamps
    ##########################

    # @return [Time] uses the value from the API's initial_entry_date_epoch
    attr_reader :initial_entry_date

    # @return [Time] uses the value from the API's last_backup_time_epoch
    attr_reader :last_backup_time
    alias last_backup_date last_backup_time
    alias last_backup last_backup_time

    # @return [Time] uses the value from the API's last_inventory_update_utc
    attr_reader :last_inventory_update

    # @return [Time] the last time this device enrolled in Jamf
    attr_reader :last_enrollment

    # @return [Time] last_cloud_backup_date
    attr_reader :last_cloud_backup_date

    # subsets

    # @return [Array<Hash>] the applications on the device
    attr_reader :applications

    # @return [Array<Hash>]
    #
    # The certificates on the device
    #
    # Each has has two keys:
    # - :identity => Boolean
    # - :common_name => String, possibly a udid
    attr_reader :certificates

    # @return [Array<Hash>]
    #
    # One for each ConfigurationProfile on the device
    #
    # The Hash keys are:
    # - :identifier => a unique id, often the sams as the uuid
    # - :display_name => its name in the JSS
    # - :uuid => the ConfigurationProfile uuid
    # - :version => a String
    attr_reader :configuration_profiles

    # @return [Array<Hash>]
    #
    # One for each group to which the device belongs
    #
    # The Hash keys are:
    # - :name => the group name
    # - :id => the group id in the JSS
    attr_reader :mobile_device_groups

    # @return [Hash]
    #
    # A Hash of network data
    #
    # The Hash keys are:
    # - :voice_roaming_enabled=>"Disabled",
    # - :current_mobile_network_code=>"nnn",
    # - :imei=>"nn nnnnnn nnnnnn n",
    # - :home_mobile_country_code=>"nnn",
    # - :iccid=>"nnnn nnnn nnnn nnnn nnnn",
    # - :home_mobile_network_code=>"nnn",
    # - :current_carrier_network=>"",
    # - :data_roaming_enabled=>false,
    # - :home_carrier_network=>"AT&T",
    # - :carrier_settings_version=>"16.0",
    # - :roaming=>false,
    # - :cellular_technology=>"GSM",
    # - :current_mobile_country_code=>"nnn"
    attr_reader :network

    # @return [Array<Hash>]
    #
    # One per provisioning profile
    #
    attr_reader :provisioning_profiles

    # @return [Hash]
    #
    # A Hash of security data
    #
    # The Hash has these keys, all of which are Boolean
    # - :passcode_present=>true,
    # - :passcode_compliant=>true,
    # - :passcode_compliant_with_profile=>true,
    # - :data_protection=>true,
    # - :block_level_encryption_capable=>true,
    # - :file_level_encryption_capable=>true
    attr_reader :security

    # Instance Methods
    #####################################

    # @see APIObject#initialize
    #
    # When creating new records with .make,
    # udid:, serial_number:, and asset_tag: can be provided in
    # the args.
    #
    def initialize(**args)
      super
      if @in_jss

        gen = @init_data[:general]

        # identifiers
        @serial_number = gen[:serial_number]
        @udid = gen[:udid]
        @asset_tag = gen[:asset_tag]
        @device_id = gen[:device_id]
        @device_name = gen[:device_name]
        @display_name = gen[:display_name]
        @exchange_activesync_device_identifier = gen[:exchange_activesync_device_identifier]

        # settings
        @managed = gen[:managed]
        @supervised = gen[:supervised]
        @device_ownership_level = gen[:device_ownership_level]
        @tethered = gen[:tethered]
        @shared = gen[:shared]
        @ble_capable = gen[:ble_capable]

        @airplay_password = gen[:airplay_password]
        @languages = gen[:languages]
        @locales = gen[:locales]

        # software
        @os_type = gen[:os_type]
        @os_build = gen[:os_build]
        @os_version = gen[:os_version]
        @modem_firmware = gen[:modem_firmware]

        # hardware
        @model = gen[:model]
        @model_number = gen[:model_number]
        @model_identifier = gen[:model_identifier]
        @model_display = gen[:model_display]

        # usage
        @capacity_mb = gen[:capacity_mb]
        @available_mb = gen[:available_mb]
        @percentage_used = gen[:percentage_used]
        @battery_level = gen[:battery_level]

        # network
        @bluetooth_mac_address = gen[:bluetooth_mac_address]
        @wifi_mac_address = gen[:wifi_mac_address]
        @sim_phone_number = gen[:phone_number]
        @ip_address = gen[:ip_address]

        # timestamps
        @initial_entry_date = JSS.epoch_to_time gen[:initial_entry_date_epoch]
        @last_backup_time = JSS.epoch_to_time gen[:last_backup_time_epoch]
        @last_cloud_backup_date = JSS.epoch_to_time gen[:last_cloud_backup_date_epoch]
        @last_inventory_update = JSS.epoch_to_time gen[:last_inventory_update_epoch]
        @last_enrollment = JSS.epoch_to_time gen[:last_enrollment_epoch]

        # subsets
        @mobile_device_groups = @init_data[:mobile_device_groups]
        @network = @init_data[:network]
        @extension_attributes = @init_data[:extension_attributes]
        @certificates = @init_data[:certificates]
        @configuration_profiles = @init_data[:configuration_profiles]
        @provisioning_profiles = @init_data[:provisioning_profiles]
        @security = @init_data[:security]
        @applications = @init_data[:applications]
      else
        @udid = args[:udid]
        @serial_number = args[:serial_number]
        @asset_tag = args[:asset_tag]
      end
    end # initialize

    def tv?
      model_identifier.start_with? HW_PREFIX_TV
    end
    alias apple_tv? tv?

    def ipad?
      model_identifier.start_with? HW_PREFIX_IPAD
    end

    def iphone?
      model_identifier.start_with? HW_PREFIX_IPHONE
    end

    def name=(new_name)
      super
      @needs_mdm_name_change = true if managed? && supervised?
    end

    #
    def serial_number=(new_val)
      return nil if new_val == @serial_number
      @serial_number =  new_val.empty? ? new_val : Jamf::Validate.doesnt_already_exist(self.class, :serial_number, new_val, cnx: cnx)
      @need_to_update = true
    end

    #
    def udid=(new_val)
      return nil if new_val == @udid
      @udid = new_val.empty? ? new_val : Jamf::Validate.doesnt_already_exist(self.class, :udid, new_val, cnx: cnx)
      @need_to_update = true
    end

    #
    def asset_tag=(new_val)
      new_val = new_val.strip
      return nil if @asset_tag == new_val

      @asset_tag = new_val
      @need_to_update = true
    end

    # @param no_mdm_rename[Boolean] should a MDM `set device name` command be sent
    #   if the device is managed and supervised?
    def update(no_mdm_rename: false)
      super()
      return @id if no_mdm_rename || !@needs_mdm_name_change

      set_device_name @name if managed? && supervised?
      @needs_mdm_name_change = false
      @id
    end

    # private methods
    ##############################

    private

    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      md = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      general = md.add_element('general')
      general.add_element('name').text = @name
      general.add_element('udid').text = @udid
      general.add_element('serial_number').text = @serial_number
      general.add_element('asset_tag').text = @asset_tag

      md << ext_attr_xml if unsaved_eas?
      md << location_xml if has_location?
      md << purchasing_xml if has_purchasing?
      add_site_to_xml doc
      doc.to_s
    end

  end # class Mobile Device

end # module
