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

  # This class represents a Computer in the JSS.
  #
  # ===Adding Computers to the JSS
  #
  # This class cannot be used to add new Computers to the JSS. Please use other
  # Casper methods (like the Recon App or QuickAdd package)
  #
  # ---
  # ===Editing values
  #
  # Any data that arrives in the JSS via an "inventory update"
  # (a.k.a. 'recon') cannot be modified through this class, or the API.
  #
  # Data that can be modified are:
  # * Management Account (see #set_management_to)
  # * asset_tag
  # * barcodes 1 and 2
  # * ip_address
  # * udid
  # * mac_addresses
  # * location data via the Locatable module
  # * purchasing data via the Purchasable module
  # * Extension Attribute values via the Extendable module
  #   Note: as with other 'recon' generated values, Ext. Attrs.
  #   populated by scripts cannot be modified via the API.
  #   (the change would be overwritten the next time the machine
  #   did a recon)
  #
  # After making any changes, you must call #update to send those
  # changes to the server.
  #
  # ---
  # === MDM Commands
  #
  # ==== MDM Commands are Not Yet Supported!
  # *Hopefully they will be soon*
  #
  # The following methods will be used to send an APNS command to the computer represented by an
  # instance of JSS::Computer, equivalent to clicking one of the buttons on
  # the Management Commands section of the Management tab of the Computer details page in the JSS UI.
  #
  # The methods supported will be:
  # - #blank_push  (aliases blank, noop, send_blank_push)
  # - #device_lock (aliases lock, lock_device)
  # - #erase_device (aliases wipe)
  #
  # To send an MDM command without making an instance, use the class method {.send_mdm_command}
  #
  # Each returns true if the command as sent.
  #
  # ---
  # ===Other Methods
  #
  # - {#set_management_to} change the management acct and passwd for this computer, aliased to #make_managed
  #   - requires calling #update to push changes to the server
  # - {#make_unmanaged} an shortcut method for {#set_management_to}(nil)
  #   - requires calling #update to push changes to the server
  # - {#apps} a shortcut to {#software} [:applications]
  # - {#licensed_sw} a shortcut to {#software} [:licensed_software]
  # - {#computer_groups} a shortcut to {#groups_accounts} [:computer_group_memberships]
  # - {#local_accounts} a shortcut to {#groups_accounts} [:local_accounts]
  # - {#drives} a shortcut to {#hardware} [:storage]
  # - {#printers} a shortcut to {#hardware} [:mapped_printers]
  #
  # @see APIObject
  # @see Locatable
  # @see Purchasable
  # @see Matchable
  # @see FileUpload
  #
  class Computer < JSS::APIObject


    # MixIns
    #####################################

    include JSS::Updatable
    include JSS::Locatable
    include JSS::Purchasable
    include JSS::Uploadable
    include JSS::Extendable

    extend JSS::Matchable

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'computers'.freeze

    # The (temporary?) list-resource
    LIST_RSRC = "#{RSRC_BASE}/subset/basic".freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computers

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :computer

    # these keys, as well as :id and :name,  are present in valid API JSON data for this class
    #   DEPRECATED, with be removed in a future release.
    VALID_DATA_KEYS = [:sus, :distribution_point, :alt_mac_address].freeze

    # these keys,  as well as :id and :name, can be used to look up objects of this class in the JSS
    OTHER_LOOKUP_KEYS = {
      udid: { rsrc_key: :udid, list: :all_udids },
      serialnumber: { rsrc_key: :serialnumber, list: :all_serial_numbers },
      serial_number: { rsrc_key: :serialnumber, list: :all_serial_numbers },
      macaddress: { rsrc_key: :macaddress, list: :all_mac_addresses },
      mac_address: { rsrc_key: :macaddress, list: :all_mac_addresses }
    }.freeze

    # This class lets us seach for computers
    SEARCH_CLASS = JSS::AdvancedComputerSearch

    # This is the class for relevant Extension Attributes
    EXT_ATTRIB_CLASS = JSS::ComputerExtensionAttribute

    # Boot partitions are noted with the string "(Boot Partition)" at the end
    BOOT_FLAG = ' (Boot Partition)'.freeze

    # file uploads can send attachments to the JSS using :computers as the sub-resource.
    UPLOAD_TYPES = { attachment: :computers }.freeze

    # A mapping of Symbols available to the send_mdm_command class method, to
    # the String commands actuallly sent via the API.
    COMPUTER_MDM_COMMANDS = {
      blank_push: 'BlankPush',
      send_blank_push: 'BlankPush',
      blank: 'BlankPush',
      noop: 'BlankPush',
      device_lock: 'DeviceLock',
      lock: 'DeviceLock',
      lock_device: 'DeviceLock',
      erase_device: 'EraseDevice',
      erase: 'EraseDevice',
      wipe: 'EraseDevice',
      unmanage_device: 'UnmanageDevice',
      unmanage: 'UnmanageDevice'
    }.freeze

    # The API resource for app usage
    APPLICATION_USAGE_RSRC = 'computerapplicationusage'.freeze

    # The date format for retrieving usage data
    APPLICATION_USAGE_DATE_FMT = '%Y-%m-%d'.freeze

    # The classes that can be used with the date format
    APPLICATION_USAGE_DATE_CLASSES = [Time, DateTime, Date].freeze

    # The top-level hash key of the raw app usage data
    APPLICATION_USAGE_KEY = :computer_application_usage

    # The API resource for computer_management data
    MGMT_DATA_RSRC = 'computermanagement'.freeze

    # The top-level hash key of the computer_management data
    MGMT_DATA_KEY = :computer_management

    # Thes are both the subset names in the resrouce URLS (when
    # converted to strings) and the second-level hash key of the
    # returned subset data.
    MGMT_DATA_SUBSETS = %i(
      smart_groups
      static_groups
      mac_app_store_apps
      policies
      ebooks
      os_x_configuration_profiles
      restricted_software
      patch_reporting_software_titles
    ).freeze

    # The API Resource for the computer checkin settings
    CHECKIN_RSRC = 'computercheckin'.freeze

    # The top-level hash key for the checkin settings
    CHECKIN_KEY = :computer_check_in

    # The API Resource for the computer inventory collection settings
    INV_COLLECTION_RSRC = 'computerinventorycollection'.freeze

    # The top-level hash key for the inventory collection settings
    INV_COLLECTION_KEY = :computer_inventory_collection

    # The API Resource for the computer history data
    HISTORY_RSRC = 'computerhistory'.freeze

    # The top-level hash key for the history data
    HISTORY_KEY = :computer_history

    # The keys are both the subset names in the resrouce URLS (when
    # converted to strings) and the second-level hash key of the
    # returned subset data.
    #
    # The values are the key within each history item that contains the
    # 'epoch' timestamp, for conver
    HISTORY_SUBSETS = %i(
      computer_usage_logs
      audits
      policy_logs
      casper_remote_logs
      screen_sharing_logs
      casper_imaging_logs
      commands
      user_location
      mac_app_store_applications
    ).freeze

    # HISTORY_SUBSETS = %i(
    #   computer_usage_logs date_time_epoch
    #   audits
    #   policy_logs date_completed_epoch
    #   casper_remote_logs date_time_epoch
    #   screen_sharing_logs date_time_epoch
    #   casper_imaging_logs
    #   commands completed_epoch
    #   user_location
    #   mac_app_store_applications
    # ).freeze

    POLICY_STATUS_COMPLETED = 'Completed'.freeze

    POLICY_STATUS_FAILED = 'Failed'.freeze

    POLICY_STATUS_PENDING = 'Pending'.freeze

    # Class Variables
    #####################################

    @@all_computers = nil

    # Class Methods
    #####################################


    # Display the current Computer CheckIn settings in the JSS.
    # Currently this is read-only in ruby-jss, even tho the API
    # allows updating.
    #
    # @return [Hash] the Computer Checkin Settings from the
    #   currently connected JSS.
    #
    def self.checkin_settings
      JSS::API.get_rsrc(CHECKIN_RSRC)[CHECKIN_KEY]
    end

    # Display the current Computer Inventory Collection settings in the JSS.
    # Currently this is read-only in ruby-jss, even tho the API
    # allows updating.
    #
    # @return [Hash] the Computer Inventpry Collection Settings from the
    #   currently connected JSS.
    #
    def self.inventory_collection_settings
      JSS::API.get_rsrc(INV_COLLECTION_RSRC)[INV_COLLECTION_KEY]
    end

    # A larger set of info about the computers in the JSS.
    #
    # Casper 9.4 introduced the API Resource /computers/subset/basic
    # that returns an array of hashes with more data than just /computers/
    # (which was just :name and :id). Similar to /mobildevices/, this new
    # list includes :udid, :serial_number, and :mac_address, as well as :model,
    # :managed, :building, :department, :username, and :report_date
    #
    # Because this requires a different, unusual, resource path, we're completely re-defining
    # {APIObject.all} for JSS::Computer.  Hopefully some day the original /computers/
    # resource will be updated to return this data.
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @return [Array<Hash{:name=>String, :id=> Integer}>]
    #
    def self.all(refresh = false)
      @@all_computers = nil if refresh
      return @@all_computers if @@all_computers
      @@all_computers = JSS::API.get_rsrc(self::LIST_RSRC)[self::RSRC_LIST_KEY]
    end

    # @return [Array<String>] all computer serial numbers in the jss
    def self.all_serial_numbers(refresh = false)
      all(refresh).map { |i| i[:serial_number] }
    end

    # @return [Array<String>] all computer mac_addresses in the jss
    def self.all_mac_addresses(refresh = false)
      all(refresh).map { |i| i[:mac_address] }
    end

    # @return [Array<String>] all computer udids in the jss
    def self.all_udids(refresh = false)
      all(refresh).map { |i| i[:udid] }
    end

    # @return [Array<Hash>] all managed computers in the jss
    def self.all_managed(refresh = false)
      all(refresh).select { |d| d[:managed] }
    end

    # @return [Array<Hash>] all unmanaged computers in the jss
    def self.all_unmanaged(refresh = false)
      all(refresh).select { |d| !(d[:managed]) }
    end

    # @return [Array<Hash>] all laptop computers in the jss
    def self.all_laptops(refresh = false)
      all(refresh).select { |d| d[:model] =~ /book/i }
    end

    # @return [Array<Hash>] all macbooks in the jss
    def self.all_macbooks(refresh = false)
      all(refresh).select { |d| d[:model] =~ /^macbook\d/i }
    end

    # @return [Array<Hash>] all macbookpros in the jss
    def self.all_macbookpros(refresh = false)
      all(refresh).select { |d| d[:model] =~ /^macbookpro\d/i  }
    end

    # @return [Array<Hash>] all macbookairs in the jss
    def self.all_macbookairs(refresh = false)
      all(refresh).select { |d| d[:model] =~ /^macbookair\d/i  }
    end

    # @return [Array<Hash>] all xserves in the jss
    def self.all_xserves(refresh = false)
      all(refresh).select { |d| d[:model] =~ /serve/i }
    end

    # @return [Array<Hash>] all desktop macs in the jss
    def self.all_desktops(refresh = false)
      all(refresh).select { |d| d[:model] !~ /serve|book/i }
    end

    # @return [Array<Hash>] all imacs in the jss
    def self.all_imacs(refresh = false)
      all(refresh).select { |d| d[:model] =~ /^imac/i }
    end

    # @return [Array<Hash>] all mac minis in the jss
    def self.all_minis(refresh = false)
      all(refresh).select { |d| d[:model] =~ /^macmini/i }
    end

    # @return [Array<Hash>] all macpros in the jss
    def self.all_macpros(refresh = false)
      all(refresh).select { |d| d[:model] =~ /^macpro/i }
    end

    # Send an MDM command to a managed computer by id or name
    #
    # @param computer[String,Integer] the name or id of the computer to recieve the command
    # @param command[Symbol] the command to send, one of the keys of COMPUTER_MDM_COMMANDS
    #
    # @return [true] if the command was sent
    #

    # Not functional until I get more docs from JAMF
    #
    #     def self.send_mdm_command(computer,command)
    #
    #       raise JSS::NoSuchItemError, "Unknown command '#{command}'" unless COMPUTER_MDM_COMMANDS.keys.include? command
    #
    #       command_xml ="#{JSS::APIConnection::XML_HEADER}<computer><command>#{COMPUTER_MDM_COMMANDS[command]}</command></computer>"
    #       the_id = nil
    #
    #       if computer.to_s =~ /^\d+$/
    #         the_id = computer
    #       else
    #         the_id = self.map_all_ids_to(:name).invert[computer]
    #       end
    #
    #       if the_id
    #         response = JSS::API.put_rsrc("#{RSRC_BASE}/id/#{the_id}", command_xml)
    #         response =~ %r{<notification_sent>(.+)</notification_sent>}
    #         return ($1 and $1 == "true")
    #       end
    #       raise JSS::UnmanagedError, "Cannot send command to unknown/unmanaged computer '#{computer}'"
    #     end



    # Attributes
    #####################################

    # The values returned in the General, Location, and Purchasing subsets are stored as direct attributes
    # Location and Purchasing are defined in the Locatable and Purchasable mixin modules.
    # Here's General, in alphabetical order

    # @return [String] the secondary mac address
    attr_reader :alt_mac_address

    # @return [String] the asset tag
    attr_reader :asset_tag

    # @return [String] the barcodes
    attr_reader :barcode_1, :barcode_2

    # @return [String] The name of the distribution point for this computer
    attr_reader :distribution_point

    # @return [Time] when was it added to the JSS
    attr_reader :initial_entry_date

    # @return [IPAddr] the last known IP address
    attr_reader :ip_address

    # @return [String] the version of the jamf binary
    attr_reader :jamf_version

    # @return [Time] the last contact time
    attr_reader :last_contact_time

    # @return [String] the primary macaddress
    attr_reader :mac_address

    # @return [Boolean] is this machine "managed" by Casper?
    attr_reader :managed

    # @return [String] the name of the management account
    attr_reader :management_username

    # @return [Boolean] doesit support MDM?
    attr_reader :mdm_capable

    # @return [String] the name of the netboot server for this machine
    attr_reader :netboot_server

    # @return [String] what kind of computer?
    attr_reader :platform

    # @return [Time] the last recon time
    attr_reader :report_date

    # @return [String] the serial number
    attr_reader :serial_number

    # @return [Hash] the :name and :id of the site for this machine
    attr_reader :site

    # @return [String] the name of the Software Update Server assigned to this machine.
    attr_reader :sus

    # @return [String] the UDID of the computer
    attr_reader :udid

    # The remaining subsets each go into an attribute of their own.
    #

    # @return [Array<Hash>]
    #
    # A Hash for each ConfigurationProfile on the computer
    #
    # The Hash keys are:
    # * :id => the ConfigurationProfile id in the JSS
    # * :name => the username to whom this user-level profile has been applied (if it's a user-level profile)
    # * :uuid => the ConfigurationProfile uuid
    #
    attr_reader :configuration_profiles

    # @return [Hash]
    #
    # Info about the local accts and ComputerGroups to which this machine beloings
    #
    # The Hash keys are:
    # * :computer_group_memberships => An Array of names of ComputerGroups to which this computer belongs
    # * :local_accounts => An Array of Hashes for each local user acct on this computer. Each hash has these keys:
    #   *   :name => String, the login name of the acct
    #   *   :realname => the real name of the acct
    #   *   :uid => String, the uid of the acct
    #   *   :home => String, the path to the home folder
    #   *   :home_size => String,  the size of the homedir as a string like "53245MB"
    #   *   :home_size_mb => Integer,  the size of the homedir as an integer like 53245
    #   *   :administrator => Boolean
    #   *   :filevault_enabled => Boolean
    #
    attr_reader :groups_accounts

    # @return [Hash]
    #
    # A Hash with info about the hardware of this cmoputer.
    #
    # These are the keys & sample data
    # * :number_processors=>2,
    # * :processor_speed_mhz=>2530,
    # * :make=>"Apple",
    # * :cache_size=>3072,
    # * :processor_type=>"Intel Core i5",
    # * :total_ram_mb=>8192,
    # * :model=>"15-inch MacBook Pro (Mid 2010)",
    # * :available_ram_slots=>0,
    # * :processor_architecture=>"i386",
    # * :bus_speed_mhz=>0,
    # * :total_ram=>8192,
    # * :os_name=>"Mac OS X",
    # * :optical_drive=>"HL-DT-ST DVDRW  GS23N",
    # * :model_identifier=>"MacBookPro6,2",
    # * :cache_size_kb=>3072,
    # * :boot_rom=>"MBP61.0057.B0F",
    # * :os_version=>"10.9.3",
    # * :mapped_printers=> An Array of Hashes, one per printer, with these keys
    #   *  :name => the name of the printer
    #   *  :location => the location of the printer
    #   *  :type => the printer model
    #   *  :uri => the uri to reach the printer on the network
    # * :nic_speed=>"10/100/1000",
    # * :processor_speed=>2530,
    # * :active_directory_status=>"Not Bound",
    # * :bus_speed=>0,
    # * :os_build=>"13D65",
    # * :smc_version=>"1.58f17",
    # * :service_pack=>"",
    # * :battery_capacity=>87
    # * :storage=> An Array of Hashes, one per Drive, with these keys
    #   * :smart_status=>"Verified",
    #   * :connection_type=>"NO",
    #   * :model=>"M4-CT256M4SSD2",
    #   * :revision=>"040H",
    #   * :serial_number=>"00000000130709JH7GhhC",
    #   * :size=>262205,
    #   * :disk=>"disk0",
    #   * :drive_capacity_mb=>262205}],
    #   * :partition=> A Hash with these keys
    #     * :filevault2_status=>"Encrypted",
    #     * :type=>"boot",
    #     * :filevault2_percent=>100,
    #     * :partition_capacity_mb=>38014,
    #     * :lvgUUID=>"C4883AF5-3E58-4F76-A56C-094D4CEC7E9F",
    #     * :percentage_full=>61,
    #     * :lvUUID=>"745A262E-AEA6-4608-8A3A-6CDC225B4DE6",
    #     * :filevault_status=>"Encrypted",
    #     * :size=>38014,
    #     * :pvUUID=>"C38051CF-5066-442F-A442-1035060ED462",
    #     * :name=>"KimDrive40 (Boot Partition)",
    #     * :filevault_percent=>100
    #
    attr_reader :hardware

    # @return [Array<Hash>]
    #
    # A Hash per peripheral
    #
    # Each hash has these keys & sample data:
    # *  :id=>286,
    # *  :type=>"Display",
    # *  :field_0=>"HP",
    # *  :field_1=>"HP LP2480zx",
    # *  :field_2=>"DreamColor",
    # *  :field_3=>"3CM10800F4",
    # *  :field_4=>"",
    # *  :field_5=>""
    # *  :field_6=>"",
    # *  :bar_code_1=>"",
    # *  :bar_code_2=>"",
    # *  :purchasing=> A hash with these keys:
    #    * :warranty_expires_utc=>"",
    #    * :is_leased=>false,
    #    * :po_date=>"",
    #    * :lease_expires=>"",
    #    * :po_number=>"",
    #    * :po_date_epoch=>0,
    #    * :lease_expires_epoch=>0,
    #    * :vendor=>"",
    #    * :attachments=>[],
    #    * :po_date_utc=>"",
    #    * :lease_expires_utc=>"",
    #    * :applecare_id=>"",
    #    * :warranty_expires=>"",
    #    * :life_expectancy=>0,
    #    * :purchase_price=>"",
    #    * :warranty_expires_epoch=>0,
    #    * :is_purchased=>true,
    #    * :purchasing_contact=>"",
    #    * :purchasing_account=>""
    #
    attr_reader :peripherals

    # @return [Hash]
    #
    # A Hash of software data
    #
    # The Hash has these keys:
    # * :running_services => An Array of services running on the computer (if gathered) TODO - is each item a hash?
    # * :installed_by_casper => An Array of Package names unstalled on this computer by Casper
    # * :fonts => An Array of fonts on this computer (if gathered) TODO - is each item a hash?
    # * :installed_by_installer_swu => An Array of pkg IDs for pkgs installed by SoftwareUpdate or the Apple Installer
    # * :applications => An Array of Hashes, one per Application on the computer, with these keys:
    #   *   :path => String, the path to the app
    #   *   :name => String, the name of the app, including the .app suffix
    #   *   :version => String, the version of the app at that path.
    # * :cached_by_casper => An Array of Casper Package names cached on the machine, awaiting installation
    # * :available_software_updates => An Array of available SoftwareUpdate (if gathered) TODO - is each item a hash?
    # * :plugins => An Array of plugins installed on the machine (if gathered) TODO - is each item a hash?
    # * :available_updates => A Hash - Deprecated?
    # * :licensed_software => An Array, the names of Licenced Software (as defined in Casper) on this machine
    # * :unix_executables => DEPRECATED
    #
    attr_reader :software

    # Constructor
    #####################################

    # @param (see APIObject#initialize)
    #
    # As well as :id and :name, computers can be queried using :udid, :serialnumber, and :mac_address
    #
    def initialize(args = {})
      super args

      # now we have raw @init_data with something in it, so fill out the instance vars
      @alt_mac_address = @init_data[:general][:alt_mac_address]
      @asset_tag = @init_data[:general][:asset_tag]
      @barcode_1 = @init_data[:general][:barcode_1]
      @barcode_2 = @init_data[:general][:barcode_2]
      @distribution_point = @init_data[:general][:distribution_point]
      @initial_entry_date = JSS.epoch_to_time @init_data[:general][:initial_entry_date_epoch]
      @ip_address = @init_data[:general][:ip_address]
      @jamf_version = @init_data[:general][:jamf_version]
      @last_contact_time = JSS.epoch_to_time @init_data[:general][:last_contact_time_epoch]
      @mac_address = @init_data[:general][:mac_address]
      @managed = @init_data[:general][:remote_management][:managed]
      @management_username = @init_data[:general][:remote_management][:management_username]
      @mdm_capable = @init_data[:general][:mdm_capable]
      @netboot_server = @init_data[:general][:netboot_server]
      @platform = @init_data[:general][:platform]
      @report_date = JSS.epoch_to_time @init_data[:general][:report_date_epoch]
      @serial_number = @init_data[:general][:serial_number]
      @site = JSS::APIObject.get_name(@init_data[:general][:site])
      @sus = @init_data[:general][:sus]
      @udid = @init_data[:general][:udid]

      @configuration_profiles = @init_data[:configuration_profiles]
      @extension_attributes = @init_data[:extension_attributes]
      @groups_accounts = @init_data[:groups_accounts]
      @hardware = @init_data[:hardware]
      @peripherals = @init_data[:peripherals]
      @software = @init_data[:software]

      @management_password = nil
    end # initialize

    # @return [Array] the JSS groups to which thismachine belongs (smart and static)
    #
    def computer_groups
      @groups_accounts[:computer_group_memberships]
    end

    # @return [Array<Hash>] all the local accts on the machine.
    #
    # Each item has keys :name, :realname, :uid, :home, :home_size, :administrator, :filevault_enabled
    #
    def local_accounts
      @groups_accounts[:local_accounts]
    end

    # @return [Boolean] is FileVault2 enabled?
    #
    def filevault2_enabled?
      boot_drive[:partition][:filevault2_status] != 'Not Encrypted'
    end

    # @return [Array<Hash>] The local_accounts Array that have Legacy FV enabled
    #
    def filevault1_accounts
      return [] if filevault2_enabled?
      local_accounts.select { |a| a[:filevault_enabled] }
    end

    # @return [Array<Hash>]  each storage device
    #
    def drives
      @hardware[:storage]
    end

    # @return [Hash, nil] The hardware[:storage] hash of the boot drive
    #
    def boot_drive
      drives.each { |d| return d if d[:partition][:type] == 'boot' }
      nil
    end

    # @return [Array<Hash>]  each printer on this computer
    #   Keys are :name, :uri, :type, :location
    #
    def printers
      @hardware[:mapped_printers]
    end

    # @return [Array<Hash>]  all apps installed on this machine.
    #   Hash keys are :name, :path, and :version
    #
    def apps
      @software[:applications]
    end

    # @return [Array<String>] the JSS-defined "licensed software" titles
    #   installed on this machine.
    #
    def licensed_sw
      @software[:licensed_software]
    end

    # Get application usage data for this computer
    # for a given date range.
    #
    # @param start_date [String,Date,DateTime,Time]
    #
    # @param end_date [String,Date,DateTime,Time] Defaults to start_date
    #
    # @return [Hash{Date=>Array<Hash>}] For each day in the range, an Array
    #   with one Hash per application used. The hash keys are:
    #   :name => String, the name of the app
    #   :version => String ,the version of the app
    #   :foreground => Integer, the minutes it was in the foreground
    #   :open => Integer, the minutes it was running.
    #
    def application_usage(start_date, end_date = nil)
      end_date ||= start_date
      start_date = Time.parse start_date if start_date.is_a? String
      end_date = Time.parse end_date if end_date.is_a? String
      unless ([start_date.class, end_date.class] - APPLICATION_USAGE_DATE_CLASSES).empty?
        raise JSS::InvalidDataError, 'Invalid Start or End Date'
      end
      start_date = start_date.strftime APPLICATION_USAGE_DATE_FMT
      end_date = end_date.strftime APPLICATION_USAGE_DATE_FMT
      data = JSS::API.get_rsrc(APPLICATION_USAGE_RSRC + "/id/#{@id}/#{start_date}_#{end_date}")
      parsed_data = {}
      data[APPLICATION_USAGE_KEY].each do |day_hash|
        date = Date.parse day_hash[:date]
        parsed_data[date] = day_hash[:apps]
      end
      parsed_data
    end # app usage

    # The 'computer management' data for this computer, looked up on the fly.
    #
    # Without specifying a subset:, the entire dataset is returned as a hash of
    # arrays, one per  subset
    # If a subset is given then only that array is returned, and it contains
    # hashes with data about each item (usually :name and :id)
    # If the only: param is provided with a subset, it is used as a hash-key to
    # map the array to just those values, so subset: :smart_groups, only: :name
    # will return an array of names of smartgroups that contain this computer.
    #
    # @param subset[Symbol] Fetch only a subset of data, as an array.
    #    must be one of the symbols in MGMT_DATA_SUBSETS
    #
    # @param only[Symbol] When fetching a subset, only return one value
    #   per item in the array. meaningless without a subset.
    #
    # @return [Hash] Without a subset:, a hash of all subsets, each of which is
    #   an Array
    # @return [Array] With a subset:, an array of items in that subset.
    #
    def management_data(subset: nil, only: nil)
      if subset
        raise "Subset must be one of :#{MGMT_DATA_SUBSETS.join ', :'}" unless MGMT_DATA_SUBSETS.include? subset
        mgmt_rsrc = MGMT_DATA_RSRC + "/id/#{@id}/subset/#{subset}"
      else
        mgmt_rsrc = MGMT_DATA_RSRC + "/id/#{@id}"
      end

      data = JSS::API.get_rsrc(mgmt_rsrc)[MGMT_DATA_KEY]
      return data unless subset

      data = data[subset]
      return data.map! { |d| d[only] } if only
      data
    end

    # A shortcut for 'management_data subset: :smart_groups'
    #
    def smart_groups(only: nil)
      management_data subset: :smart_groups, only: only
    end

    # A shortcut for 'management_data subset: :static_groups'
    #
    def static_groups(only: nil)
      management_data subset: :static_groups, only: only
    end

    # A shortcut for 'management_data subset: :policies'
    #
    def policies(only: nil)
      management_data subset: :policies, only: only
    end

    # A shortcut for 'management_data subset: :os_x_configuration_profiles'
    #
    def configuration_profiles(only: nil)
      management_data subset: :os_x_configuration_profiles, only: only
    end

    # A shortcut for 'management_data subset: :ebooks'
    #
    def ebooks(only: nil)
      management_data subset: :ebooks, only: only
    end

    # A shortcut for 'management_data subset: :mac_app_store_apps'
    #
    def app_store_apps(only: nil)
      management_data subset: :mac_app_store_apps, only: only
    end

    # A shortcut for 'management_data subset: :restricted_software'
    #
    def restricted_software(only: nil)
      management_data subset: :restricted_software, only: only
    end

    # A shortcut for 'management_data subset: :patch_reporting_software_titles'
    #
    def patch_titles(only: nil)
      management_data subset: :patch_reporting_software_titles, only: only
    end


    # Return this computer's history.
    # WARNING! Its huge, better to use a subset a
    # nd one of the shortcut methods.
    #
    # @param subset[Type] describe_subset
    #
    # @return [Type] description_of_returned_object
    #
    def history(subset = nil)
      if subset
        raise "Subset must be one of :#{HISTORY_SUBSETS.join ', :'}" unless HISTORY_SUBSETS.include? subset
        history_rsrc = HISTORY_RSRC + "/id/#{@id}/subset/#{subset}"
      else
        history_rsrc = HISTORY_RSRC + "/id/#{@id}"
      end
      data = JSS::API.get_rsrc(history_rsrc)[HISTORY_KEY]
      subset ? data[subset] : data
    end

    # Shortcut for history(:computer_usage_logs)
    def usage_logs
      history(:computer_usage_logs)
    end

    # Shortcut for history(:audits)
    def audits
      history(:audits)
    end

    # Shortcut for history(:policy_logs)
    def policy_logs
      history(:policy_logs)
    end

    # Shortcut for history(:policy_logs), but just the completed policies
    def completed_policies
      policy_logs.select { |pl| pl[:status] == POLICY_STATUS_COMPLETED }
    end

    # Shortcut for history(:policy_logs), but just the failes policies
    def failed_policies
      policy_logs.select { |pl| pl[:status] == POLICY_STATUS_FAILED }
    end

    # Shortcut for history(:casper_remote_logs)
    def casper_remote_logs
      history(:casper_remote_logs)
    end

    # Shortcut for history(:screen_sharing_logs)
    def screen_sharing_logs
      history(:screen_sharing_logs)
    end

    # Shortcut for history(:casper_imaging_logs)
    def casper_imaging_logs
      history(:casper_imaging_logs)
    end

    # Shortcut for history(:commands)
    def commands
      history(:commands)
    end

    # Shortcut for history(:user_location)
    def user_location_history
      history(:user_location)
    end

    # Shortcut for history(:mac_app_store_applications)
    def app_store_app_history
      history(:mac_app_store_applications)
    end

    # Set or unset management acct and password for this computer
    #
    # @param name[String] the name of the management acct.
    #
    # @param password[String] the password of the management acct
    #
    # @return [void]
    #
    # The changes will need to be pushed to the server with #update
    # before they take effect.
    #
    # CAUTION: this does nothing to confirm the name and password
    # will work on the machine!
    #
    def set_management_to(name, password)
      password = nil unless name
      @management_username = name
      @management_password = password
      @managed = name ? true : false
      @need_to_update = true
    end

    # Make the machine unmanaged.
    #
    # The same as
    #   #set_management_to nil, nil
    # followed by
    #   JSS::Computer.send_mdm_command @id, :unmanage_device
    # which currently isn't working
    #
    # @return [void]
    #
    def make_unmanaged
      return nil unless managed?
      set_management_to(nil, nil)
      begin
        self.class.send_mdm_command(@id, :unmanage_device)
      rescue
      end
    end

    #
    def asset_tag=(new_val)
      return nil if @asset_tag == new_val
      new_val.strip!
      @asset_tag = new_val
      @need_to_update = true
    end

    #
    def barcode_1=(new_val)
      return nil if @barcode_1 == new_val
      new_val.strip!
      @barcode_1 = new_val
      @need_to_update = true
    end

    #
    def barcode_2=(new_val)
      return nil if @barcode_2 == new_val
      new_val.strip!
      @barcode_2 = new_val
      @need_to_update = true
    end

    #
    def ip_address=(new_val)
      return nil if @ip_address == new_val
      new_val.strip!
      # this raises an error if its an invalid IP address
      IPAddr.new new_val
      @ip_address = new_val
      @need_to_update = true
    end

    # Send changes to the API
    #
    # @return [void]
    #
    def update
      id = super
      @management_password = nil
      id
    end

    # Delete this computer from the JSS
    #
    # @return [void]
    #
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
    end # delete

    # Not Functional until I get more docs from JAMF
    #
    #     #
    #     # Send a blank_push MDM command
    #     #
    #     def blank_push
    #       self.class.send_mdm_command @id, :blank_push
    #     end
    #     alias noop blank_push
    #     alias send_blank_push blank_push
    #
    #     #
    #     # Send a device_lock MDM command
    #     #
    #     def device_lock
    #       self.class.send_mdm_command @id, :device_lock
    #     end
    #     alias lock device_lock
    #     alias lock_device device_lock
    #
    #     #
    #     # Send an erase_device MDM command
    #     #
    #     def erase_device
    #       self.class.send_mdm_command @id, :erase_device
    #     end
    #     alias erase erase_device
    #     alias wipe erase_device

    # aliases
    alias alt_macaddress alt_mac_address
    alias bar_code_1 barcode_1
    alias bar_code_2 barcode_2
    alias managed? managed
    alias mdm? mdm_capable
    alias last_recon report_date
    alias sn serial_number
    alias serialnumber serial_number
    alias accounts local_accounts
    alias accts local_accounts
    alias make_managed set_management_to

    # private methods
    ##############################
    private

    # Return a String with the XML Resource
    # for submitting  changes to the JSS via
    # the API
    #
    # For Computers, only some items can be changed via the API
    # In particular, any data gatherd by a Recon cannot be changed
    #
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

      computer << ext_attr_xml

      computer << location_xml if has_location?

      computer << purchasing_xml if has_purchasing?

      doc.to_s
    end

  end # class Computer

end # module
