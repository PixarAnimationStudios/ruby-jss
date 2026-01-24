# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # This class represents a Computer in the JSS.
  #
  # === Adding Computers to the JSS
  #
  # At the moment, this class cannot be used to add new Computers to the JSS.
  # Please use other methods (like the Recon App or QuickAdd package)
  #
  # === Editing values
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
  # * mac_address & alt_mac_address
  # * serial_number
  #   Note: Even tho the webUI doesn't allow editing the serial_number,
  #   the API does, and it can be useful for dealing with duplicates
  #   that arise when a logic-board swap causes a new computer record.
  #   to be created.
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
  # === MDM Commands
  #
  # See the {Jamf::MDM} mixin module for Class and Instance methods for
  # sending MDM commands to computers.
  #
  # To send MDM commands without fetching Computer instances, use the class
  # methods, which can take multiple computer identifiers at once.
  #
  # NOTE: the poorly named 'UnmanageDevice' mdm command is implemented
  # as {#remove_mdm_profile} (which is its name in the webUI) as well as
  # {#unmanage_device}.
  # Calling that method will NOT fully unmanage a computer from the JSS's point
  # of view, it will just remove the mdm management profile from the machine
  # and all configuration profiles that were installed via the JSS. Those
  # profiles may be re-installed automatically later if the computer is still in
  # scope for them
  #
  # To properly unmanage a computer, use the {#make_unmanaged} Instance method
  # which removes the mdm profile, but also makes the machine unmanged by the
  # JSS, setting the management acct to nil, and requring re-enrollment.
  #
  # === Management History & Logs
  #
  # Computer Management History and logs can now be retrieved both from a
  # Computer instance, and directly via class methods without fetching an
  # instance. This is handled by the mixed-in {Jamf::ManagementHistory} module,
  # Q.V. for details.
  #
  # === Appication Usage History
  #
  # Computer Instances now have access to their Application Usage history
  # via the {#application_usage} method.
  # Call the method with a start-date value (either a String or a Time object)
  # and an optional end-date value. If you omite the end-date, the start-date
  # is used and you'll see usage for just that day.
  #
  # See {#application_usage} for details about the data returned.
  #
  # NOTE: your JSS must be gathering Appication Usage data in order
  # for any data to be returned, and the usage history will only go back as
  # far as your setting for flushing of Application Usage Logs.
  #
  # === Management Data
  #
  # The computers 'manamgement data', as presented on the 'Management' tab of
  # the computer's detail page in the JSS web UI, is available from the
  # {#management_data} method. That method may return a large dataset,
  # unless a subset is requested.
  #
  # Subsets of management data have their own methods, which are faster and
  # only retrieve the subset requested. See {#smart_groups}, {#static_groups},
  # {#policies}, {#configuration_profiles}, {#ebooks}, {#app_store_apps},
  # {#restricted_software}, and {#patch_titles}
  #
  # The subset methods can take an 'only:' parameter, which is a symbol specifying
  # the value you care to see. For example {#smart_groups} returns an array
  # of hashes, one for each smart_group the computer is in. Those hashes
  # have two keys, :name, and :id. However if you only want an array of
  # names, you can call `smart_groups only: :name`
  #
  # When any of the manamgement data methods are used the first time, the data
  # is read from the API and cached internally, the cache is then
  # used for all future calls. To re-read the data from the API and re-cache it,
  # provide `refresh: true` to any of the manamgement data methods.
  #
  # === Other Methods
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
  class Computer < Jamf::APIObject

    # MixIns
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
    include Jamf::MacOSManagedUpdates
    include Jamf::MacOSRedeployMgmtFramework
    include Jamf::FileVault
    include Jamf::ComputerRecoveryLock

    extend Jamf::Matchable

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

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

    # these keys,  as well as :id and :name, can be used to look up objects
    # of this class in the JSS
    #
    OTHER_LOOKUP_KEYS = {
      udid: {
        aliases: %i[uuid guid],
        fetch_rsrc_key: :udid
      },
      serial_number: {
        aliases: %i[serialnumber sn],
        fetch_rsrc_key: :serialnumber
      },
      mac_address: {
        aliases: %i[
          mac_address
          macaddress
          macaddr
        ],
        fetch_rsrc_key: :macaddress
      }

    }.freeze

    NON_UNIQUE_NAMES = true

    # This class lets us seach for computers
    SEARCH_CLASS = Jamf::AdvancedComputerSearch

    # This is the class for relevant Extension Attributes
    EXT_ATTRIB_CLASS = Jamf::ComputerExtensionAttribute

    # Boot partitions are noted with the string "(Boot Partition)" at the end
    BOOT_FLAG = ' (Boot Partition)'.freeze

    # file uploads can send attachments to the JSS using :computers as the sub-resource.
    UPLOAD_TYPES = { attachment: :computers }.freeze

    # Tell the MDM module what kind of MDM commands we use.
    MDM_COMMAND_TARGET = :computers

    # The API resource for app usage
    APPLICATION_USAGE_RSRC = 'computerapplicationusage'.freeze

    # The date format for retrieving usage data
    APPLICATION_USAGE_DATE_FMT = '%Y-%m-%d'.freeze

    # The top-level hash key of the raw app usage data
    APPLICATION_USAGE_KEY = :computer_application_usage

    # The API resource for computer_management data
    MGMT_DATA_RSRC = 'computermanagement'.freeze

    # The top-level hash key of the computer_management data
    MGMT_DATA_KEY = :computer_management

    # Thes are both the subset names in the resrouce URLS (when
    # converted to strings) and the second-level hash key of the
    # returned subset data.
    MGMT_DATA_SUBSETS = %i[
      smart_groups
      static_groups
      mac_app_store_apps
      policies
      ebooks
      os_x_configuration_profiles
      restricted_software
      patch_reporting_software_titles
    ].freeze

    # The API Resource for the computer checkin settings
    CHECKIN_RSRC = 'computercheckin'.freeze

    # The top-level hash key for the checkin settings
    CHECKIN_KEY = :computer_check_in

    # The API Resource for the computer inventory collection settings
    INV_COLLECTION_RSRC = 'computerinventorycollection'.freeze

    # The top-level hash key for the inventory collection settings
    INV_COLLECTION_KEY = :computer_inventory_collection

    COMPUTER_APPLICATIONS_RSRC = 'computerapplications/application'.freeze

    # The base resource for computer data in the JPAPI
    JPAPI_INVENTORY_RSRC = 'v1/computers-inventory'

    # The resource for getting all inventory data for a computer at once
    JPAPI_INVENTORY_DETAIL_RSRC = 'v1/computers-inventory-detail'

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 1

    # Class Methods
    #####################################

    # Display the current Computer CheckIn settings in the JSS.
    # Currently this is read-only in ruby-jss, even tho the API
    # allows updating.
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash] the Computer Checkin Settings from the
    #   currently connected JSS.
    #
    def self.checkin_settings(api: nil, cnx: Jamf.cnx)
      cnx = api if api
      cnx.c_get(CHECKIN_RSRC)[CHECKIN_KEY]
    end

    # Display the current Computer Inventory Collection settings in the JSS.
    # Currently this is read-only in ruby-jss, even tho the API
    # allows updating.
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash] the Computer Inventpry Collection Settings from the
    #   currently connected JSS.
    #
    def self.inventory_collection_settings(api: nil, cnx: Jamf.cnx)
      cnx = api if api
      cnx.c_get(INV_COLLECTION_RSRC)[INV_COLLECTION_KEY]
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
    # {APIObject.all} for Jamf::Computer.  Hopefully some day the original /computers/
    # resource will be updated to return this data.
    #
    # @param refresh[Boolean] should the data be re-queried from the API?
    #
    # @param cnx[Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Array<Hash{:name=>String, :id=> Integer}>]
    #
    def self.all(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      cache = cnx.c_object_list_cache
      cache_key = self::RSRC_LIST_KEY
      cache[cache_key] = nil if refresh
      return cache[cache_key] if cache[cache_key]

      cache[cache_key] = cnx.c_get(self::LIST_RSRC)[cache_key]
    end

    # @return [Array<Hash>] all managed computers in the jss
    def self.all_managed(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:managed] }
    end

    # @return [Array<Hash>] all unmanaged computers in the jss
    def self.all_unmanaged(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).reject { |d| d[:managed] }
    end

    # @return [Array<Hash>] all laptop computers in the jss
    def self.all_laptops(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /book/i }
    end

    # @return [Array<Hash>] all macbooks in the jss
    def self.all_macbooks(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /^macbook\d/i }
    end

    # @return [Array<Hash>] all macbookpros in the jss
    def self.all_macbookpros(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /^macbookpro\d/i }
    end

    # @return [Array<Hash>] all macbookairs in the jss
    def self.all_macbookairs(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /^macbookair\d/i }
    end

    # @return [Array<Hash>] all xserves in the jss
    def self.all_xserves(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /serve/i }
    end

    # @return [Array<Hash>] all desktop macs in the jss
    def self.all_desktops(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).reject { |d| d[:model] =~ /serve|book/i }
    end

    # @return [Array<Hash>] all imacs in the jss
    def self.all_imacs(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /^imac/i }
    end

    # @return [Array<Hash>] all mac minis in the jss
    def self.all_minis(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /^macmini/i }
    end

    # @return [Array<Hash>] all macpros in the jss
    def self.all_macpros(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |d| d[:model] =~ /^macpro/i }
    end

    # Retrieve Application Usage data for a computer by id, without
    # instantiation.
    #
    # @param ident [Integer,String] An identifier (id, name, serialnumber,
    #   macadress or udid) of the computer for which to retrieve Application Usage
    #
    # @param start_date [Time,Date,DateTime,String] The earliest date to retrieve
    #
    # @param end_date [String,Date,DateTime,Time] Defaults to start_date
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash{Date=>Array<Hash>}] A Hash with keys (Date instances) for
    #   each day in the range.
    #
    #   Each hash value contains an Array of apps used
    #   on that day.
    #
    #   Each item in the array is a hash of data about the app.
    #   Those hash keys are:
    #     :name => String, the name of the app
    #     :version => String ,the version of the app
    #     :foreground => Integer, the minutes it was in the foreground
    #     :open => Integer, the minutes it was running.
    #
    def self.application_usage(ident, start_date, end_date = nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      id = valid_id ident, cnx: cnx
      raise Jamf::NoSuchItemError, "No computer matches identifier: #{ident}" unless id

      end_date ||= start_date
      start_date = Jamf.parse_time start_date
      end_date = Jamf.parse_time end_date

      start_date = start_date.strftime APPLICATION_USAGE_DATE_FMT
      end_date = end_date.strftime APPLICATION_USAGE_DATE_FMT

      data = cnx.c_get(APPLICATION_USAGE_RSRC + "/id/#{id}/#{start_date}_#{end_date}")

      parsed_data = {}

      data[APPLICATION_USAGE_KEY].each do |day_hash|
        date = Date.parse day_hash[:date]
        parsed_data[date] = day_hash[:apps]
      end

      parsed_data
    end # app usage

    # Query the JSS for computers with some app installed. An app name is required
    # as the first parameter.
    #
    # If no other parameters are given, returns a Hash, one key per version of the
    # app. For each version there is an array of Hashes, one Hash for each
    # computer with that version. The sub hashes contain keys for the computer's
    # identifiers, i.e. :name, :id, :udid, :serial_number, :mac_address.
    #
    # If one or more inventory fields are provided in the 'fields' parameter,
    # each computer's hash also has keys and values for those fields if they
    # exist in the JSS. These fields are those available in the display options
    # for Advanced Computer Searches (including extention attribute names) and
    # their names are case-sensitive, so 'Username', not 'username'
    #
    # If a specific version is provided in the 'version' parameter, only computers
    # containing that version of the app are returned as an Array of Hashes.
    #
    # If the ids_only parameter is truthy, an Array of JSS id numbers for
    # computers with this app is returned. In this case the 'fields' parameter
    # is ignored, however the 'version' parameters is still valid and will
    # restrict the list to those computer ids with that version installed.
    #
    # This method implements the 'computerapplications' API endpoint.
    #
    # NOTE: To see all the apps installed on a specific computer, fetch the
    # Jamf::Computer instance and call its {Jamf::Computer#apps} method.
    #
    # @param appname [String] The name of the app to look for, e.g. 'Transmogrifier.app'
    #
    # @param fields [String,Array<String>] Additional 'inventory fields' to return
    #    with each computer's data
    #
    # @param version [String] Limit search to a specific version of the app
    #
    # @param ids_only [Boolean] Just return an array of the id's of computers
    #  found with this query. Defaults to false
    #
    # @param cnx [Jamf::Connection] The API connection to use for the query.
    #   default: Jamf.cnx
    #
    # @return [Array<Integer>] When ids_only == true, the ids of computers with
    #   the app installed (possibly limited to version)
    #
    # @return [Array<Hash>] When version is provided, An Array of Hashes, one
    #   for each computer, with keys for identifiers plus any requested fields.
    #
    # @return [Hash{String => Array<Hash>}] When no version is provided, a Hash
    #   with keys for each version, pointing to an array of Hashes, one for
    #   each computer with that version. Each computer's Hash has keys for
    #   identifiers plus any requested fields.
    #
    #
    def self.application_installs(appname, fields: [], version: nil, ids_only: false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      fields = [fields] unless fields.is_a? Array

      rsrc = "#{COMPUTER_APPLICATIONS_RSRC}/#{CGI.escape appname.to_s}"
      rsrc << "/version/#{CGI.escape version.to_s}" if version
      rsrc << "/inventory/#{CGI.escape fields.join(',')}" unless ids_only || fields.empty?

      result = cnx.c_get(rsrc)[:computer_applications]

      return result[:unique_computers].map { |c| c[:id] } if ids_only

      if version.nil?
        hash_by_version = {}
        result[:versions].each { |v| hash_by_version[v[:number]] = v[:computers] }
        return hash_by_version
      end

      result[:versions].first[:computers]
    end # self.application_installs

    # The 'computer management' data for a given computer by id,
    # looked up on the fly.
    #
    # Without specifying a subset:, the entire dataset is returned as a hash of
    # arrays, one per  subset
    #
    # If a subset is given then only that array is returned, and it contains
    # hashes with data about each item (usually :name and :id)
    #
    # If the only: param is provided with a subset, it is used as a hash-key to
    # map the array to just those values, so subset: :smart_groups, only: :name
    # will return an array of names of smartgroups that contain the computer.
    #
    # @param ident [Integer,String] An identifier (id, name, serialnumber,
    #   macadress or udid) of the computer for which to retrieve Application Usage
    #
    # @param subset[Symbol] Fetch only a subset of data, as an array.
    #    must be one of the symbols in MGMT_DATA_SUBSETS
    #
    # @param only[Symbol] When fetching a subset, only return one value
    #   per item in the array. meaningless without a subset.
    #
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash] Without a subset:, a hash of all subsets, each of which is
    #   an Array
    #
    # @return [Array] With a subset:, an array of items in that subset, possibly
    #   limited to just certain values with only:
    #
    def self.management_data(ident, subset: nil, only: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      id = valid_id ident, cnx: cnx
      raise "No computer matches identifier: #{ident}" unless id

      if subset
        management_data_subset id, subset: subset, only: only, cnx: cnx
      else
        full_management_data id, cnx: cnx
      end
    end

    # The full set of management data for a given computer.
    # This private method is called by self.management_data, q.v.
    #
    def self.full_management_data(id, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      mgmt_rsrc = MGMT_DATA_RSRC + "/id/#{id}"
      cnx.c_get(mgmt_rsrc)[MGMT_DATA_KEY]
    end
    private_class_method :full_management_data

    # A subset of management data for a given computer.
    # This private method is called by self.management_data, q.v.
    #
    def self.management_data_subset(id, subset: nil, only: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      raise "Subset must be one of :#{MGMT_DATA_SUBSETS.join ', :'}" unless MGMT_DATA_SUBSETS.include? subset

      subset_rsrc = MGMT_DATA_RSRC + "/id/#{id}/subset/#{subset}"
      subset_data = cnx.c_get(subset_rsrc)[MGMT_DATA_KEY]
      return subset_data[subset] unless only

      subset_data[subset].map { |d| d[only] }
    end
    private_class_method :management_data_subset

    # Get the MDM Management ID for a computer by identifer
    # @param ident [Integer,String] An identifier (id, name, serialnumber, macaddr)
    #   of the computer for which to retrieve the Management ID
    # @param cnx [Jamf::Connection] an API connection to use for the query.
    #
    # @return [String, nil] the management ID, or nil if the computer is not MDM managed
    ##########################################
    def self.management_id(ident, cnx: Jamf.cnx)
      jid = valid_id ident, cnx: cnx
      raise Jamf::NoSuchItemError, "No Computer with identifier '#{ident}'" unless jid

      cnx.jp_get("v2/computers-inventory/#{jid}").dig :general, :managementId
    end

    # Attributes
    #####################################

    # identifiers
    ################

    # @return [String] the secondary mac address
    attr_reader :alt_mac_address

    # @return [String] the asset tag
    attr_reader :asset_tag

    # @return [String] the barcodes
    attr_reader :barcode1, :barcode2

    # @return [String] The name of the distribution point for this computer
    attr_reader :distribution_point

    # @return [Time] when was it added to the JSS
    attr_reader :initial_entry_date

    # @return [IPAddr] the last known IP address from the server's perspective
    attr_reader :ip_address

    # @return [IPAddr] the last known IP address from the client's perspecive
    attr_reader :reported_ip_address

    # @return [Boolean]
    attr_reader :itunes_store_account_is_active

    # @return [String] the version of the jamf binary
    attr_reader :jamf_version

    # @return [Time] the last contact time
    attr_reader :last_contact_time

    # @return [Time] the last time this machine was enrolled
    attr_reader :last_enrolled

    # @return [Boolean] was the last enrollment via ADE/DEP
    attr_reader :enrolled_via_dep
    alias enrolled_via_dep? enrolled_via_dep
    alias enrolled_via_ade enrolled_via_dep
    alias enrolled_via_ade? enrolled_via_dep

    # @return [String] the primary macaddress
    attr_reader :mac_address

    # @return [Boolean] is this machine "managed" by Casper?
    attr_reader :managed

    # @return [String] the name of the management account
    attr_reader :management_username

    # @return [Boolean] doesit support MDM?
    attr_reader :mdm_capable
    alias mdm_capable? mdm_capable

    # @return [Boolean] Is it supervised?
    attr_reader :supervised
    alias supervised? supervised

    # @return [Boolean] was enrollment user-approved
    attr_reader :user_approved_enrollment
    alias user_approved_enrollment? user_approved_enrollment

    # @return [Boolean] was MDM user-approved (meaning the User authorized the MDM profile)
    attr_reader :user_approved_mdm
    alias user_approved_mdm? user_approved_mdm

    # @return [Time] when does the mdm profile expire
    attr_reader :mdm_profile_expiration

    # @return [Hash] some MDM status details in general
    attr_reader :management_status

    # @return [Array] user accts that support MDM?
    #  NOTE: This suffers from the JSON-Hash-treated-like_XML-Array-loses-data
    #  bug and only shows the last listed user, cuz it comes from the API
    #  as a hash, not an array.
    #
    attr_reader :mdm_capable_users

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

    # @return [Hash] The security settings for this Computer
    #   Keys are:
    #   activation_lock:  Boolean
    #   recovery_lock_enabled: Boolean
    #   secure_boot_level: String
    #   external_boot_level: String
    #   firewall_enabled: Boolean
    attr_reader :security

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

    # @return [Array<Hash>]
    #
    # A Hash for each Certificate on the computer
    #
    # The Hash keys are:
    # * :common_name [String] the name of the cert
    # * :identity [Boolean] Is this an identiry cert?
    # * :expires [Time] the certificate expiration time
    # * :name[String] Display name for the certificate, if any
    #
    attr_reader :certificates

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
    # # When creating new records with .make,
    # these can be provided in the arg, or after instantiation via
    # setter methods:
    #   serial_number:, udid:, asset_tag:, mac_address:
    #   alt_mac_address:, barcode_1:, barcode_2:
    #
    #
    def initialize(**args)
      super
      if @in_jss

        # mutable stuff
        @alt_mac_address = @init_data[:general][:alt_mac_address]
        @asset_tag = @init_data[:general][:asset_tag]
        @barcode1 = @init_data[:general][:barcode_1]
        @barcode2 = @init_data[:general][:barcode_2]
        @mac_address = @init_data[:general][:mac_address]
        @managed = @init_data[:general][:remote_management][:managed]
        @management_username = @init_data[:general][:remote_management][:management_username]
        @serial_number = @init_data[:general][:serial_number]
        @udid = @init_data[:general][:udid]

        # immutable single-values
        @distribution_point = @init_data[:general][:distribution_point]
        @initial_entry_date = JSS.epoch_to_time @init_data[:general][:initial_entry_date_epoch]
        @last_enrolled = JSS.epoch_to_time @init_data[:general][:last_enrolled_date_epoch]

        @management_status = @init_data[:general][:management_status]
        if @management_status
          @enrolled_via_dep = @management_status[:enrolled_via_dep]
          @user_approved_enrollment = @management_status[:user_approved_enrollment]
          @user_approved_mdm = @management_status[:user_approved_mdm]
        end

        @ip_address = @init_data[:general][:ip_address]
        @reported_ip_address = @init_data[:general][:last_reported_ip]
        @itunes_store_account_is_active = @init_data[:general][:itunes_store_account_is_active]
        @jamf_version = @init_data[:general][:jamf_version]
        @last_contact_time = JSS.epoch_to_time @init_data[:general][:last_contact_time_epoch]

        @mdm_capable = @init_data[:general][:mdm_capable]
        @mdm_capable_users = @init_data[:general][:mdm_capable_users].values
        @supervised = @init_data[:general][:supervised]
        @mdm_profile_expiration = JSS.epoch_to_time @init_data[:general][:mdm_profile_expiration_epoch]

        @netboot_server = @init_data[:general][:netboot_server]
        @platform = @init_data[:general][:platform]
        @report_date = JSS.epoch_to_time @init_data[:general][:report_date_epoch]
        @sus = @init_data[:general][:sus]

        @security = @init_data[:security] || {}

        @configuration_profiles = @init_data[:configuration_profiles]

        @groups_accounts = @init_data[:groups_accounts]
        @hardware = @init_data[:hardware]
        @peripherals = @init_data[:peripherals]
        @software = @init_data[:software]
        @certificates = @init_data[:certificates].map do |cert|
          {
            expires: JSS.epoch_to_time(cert[:expires_epoch]),
            common_name: cert[:common_name],
            identity: cert[:identity],
            name: cert[:name]
          }
        end # map do cert

        # Freeze immutable things.
        # These are updated via recon, and aren't sent
        # with #update, so changing them here is meaningless anyway.
        @configuration_profiles.freeze
        @certificates.freeze
        @groups_accounts.freeze
        @hardware.freeze
        @peripherals.freeze
        @software.freeze

        @management_password = nil

      # not in jss
      else
        @udid = args[:udid]
        @serial_number = args[:serial_number]
        @asset_tag = args[:asset_tag]
        @mac_address = args[:mac_address]
        @alt_mac_address = args[:alt_mac_address]
        @barcode1 = args[:barcode_1]
        @barcode2 = args[:barcode_2]
      end # if in jss
    end # initialize

    # Make all the keys of the @hardware hash available as top-level methods
    # on the Computer instance.
    #
    # This is done by catching method_missing and seeing if the method exists
    # as key of @hardware, and if so, retuning that value, if not, passing on
    # the method_missing call.
    # So:
    #    comp.processor_type
    # is now the same as:
    #    comp.hardware[:processor_type]
    #
    # The reason for using `method_missing` rather than looping through the
    # @hardware hash during initialization and doing `define_method` is
    # speed. When instantiating lots of computers, defining the methods
    # for each one, when those methods may not be needed, just slows things
    # down. This way, they're only used when needed.
    #
    # This method may be expanded in the future to handle other ad-hoc,
    # top-level methods.
    #
    def method_missing(method, *args, &block)
      if @hardware.key? method
        @hardware[method]
      else
        super
      end # if
    end # def

    # Companion to method_missing, allows for easier debugging in backtraces
    # that involve missing methods.
    def respond_to_missing?(method, *)
      @hardware.key?(method) || super
    end

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
      drives.select { |d| d[:partition] && d[:partition][:type] == 'boot' }.first
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
    # See {Jamf::Computer.application_usage} for details
    #
    def application_usage(start_date, end_date = nil)
      Jamf::Computer.application_usage @id, start_date, end_date, cnx: @cnx
    end # app usage

    # The management id for this computer
    # @return [String, nil] the management ID, or nil if the computer is not MDM managed
    def management_id
      @management_id ||= self.class.management_id @id, cnx: @cnx
    end

    # The 'computer management' data for this computer
    #
    # NOTE: the data isn't cached locally, and the API is queried every time
    #
    # @see {Jamf::Computer.management_data} for details
    #
    def management_data(subset: nil, only: nil)
      raise Jamf::NoSuchItemError, 'Computer not yet saved in the JSS' unless @in_jss

      Jamf::Computer.management_data @id, subset: subset, only: only, cnx: @cnx
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
      management_data subset: :ebooks, only: only, refresh: refresh
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

    # Set or unset management acct and password for this computer
    #
    # @param name[String] the name of the management acct.
    #
    # @param password[String] the password of the management acct
    #
    # @return [void]
    #
    # The changes will need to be pushed to the server with {#update}
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
    #   Jamf::Computer.send_mdm_command @id, :unmanage_device
    # which currently isn't working
    #
    # @return [void]
    #
    def make_unmanaged
      return nil unless managed?

      set_management_to(nil, nil)
      @unmange_at_update = true
    end

    def asset_tag=(new_val)
      new_val =  new_val.to_s.strip
      return nil if @asset_tag.to_s == new_val

      @asset_tag = new_val
      @need_to_update = true
    end

    # Flush all policy logs for this computer older than a given time period.
    #
    # IMPORTANT: from the Jamf Developer Site:
    #   The ability to flush logs is currently only supported for flushing all logs
    #   for a given policy or all logs for a given computer. There is no support for
    #   flushing logs for a given policy and computer combination.
    #
    # With no parameters, will flush all logs for the computer
    #
    # NOTE: Currently the API doesn't have a way to flush only failed policies.
    #
    # @param older_than[Integer] 0, 1, 2, 3, or 6
    #
    # @param period[Symbol] :days, :weeks, :months, or :years
    #
    # @see Jamf::Policy.flush_logs_for_computers
    #
    def flush_policy_logs(older_than: 0, period: :days)
      Jamf::Policy.flush_logs_for_computers(
        [@id],
        older_than: older_than,
        period: period,
        cnx: @cnx
      )
    end

    def barcode1=(new_val)
      new_val = new_val.strip
      return nil if @barcode1 == new_val

      @barcode1 = new_val
      @need_to_update = true
    end

    def barcode2=(new_val)
      new_val = new_val.strip
      return nil if @barcode2 == new_val

      @barcode2 = new_val
      @need_to_update = true
    end

    def ip_address=(new_val)
      return nil if @ip_address == new_val

      @ip_address = new_val.empty? ? new_val : Jamf::Validate.ip_address(new_val)
      @need_to_update = true
    end

    def mac_address=(new_val)
      return nil if new_val == @mac_address

      @mac_address =  new_val.empty? ? new_val : Jamf::Validate.mac_address(new_val)
      @need_to_update = true
    end

    def alt_mac_address=(new_val)
      return nil if new_val == @alt_mac_address

      @alt_mac_address = new_val.empty? ? new_val : Jamf::Validate.mac_address(new_val)
      @need_to_update = true
    end

    def serial_number=(new_val)
      return nil if new_val == @serial_number

      @serial_number =  new_val.empty? ? new_val : Jamf::Validate.doesnt_already_exist(Jamf::Computer, :serial_number, new_val, cnx: cnx)
      @need_to_update = true
    end

    def udid=(new_val)
      return nil if new_val == @udid

      @udid = new_val.empty? ? new_val : Jamf::Validate.doesnt_already_exist(Jamf::Computer, :udid, new_val, cnx: cnx)
      @need_to_update = true
    end

    # Send changes to the API
    #
    # @return [void]
    #
    def update
      remove_mdm_profile if mdm_capable && @unmange_at_update
      @unmange_at_update = false
      super
    end

    # Delete this computer from the JSS
    #
    # @return [void]
    #
    def delete
      super
      @alt_mac_address = nil
      @asset_tag = nil
      @barcode1 = nil
      @barcode2 = nil
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

    # aliases
    alias alt_macaddress alt_mac_address
    alias bar_code_1 barcode1
    alias bar_code_2 barcode2
    alias barcode_1 barcode1
    alias barcode_2 barcode2
    alias bar_code_1= barcode1=
    alias bar_code_2= barcode2=
    alias barcode_1= barcode1=
    alias barcode_2= barcode2=
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
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      doc.root.name = self.class::RSRC_OBJECT_KEY.to_s
      computer = doc.root

      general = computer.add_element('general')
      general.add_element('name').text = @name
      general.add_element('alt_mac_address').text = @alt_mac_address
      general.add_element('asset_tag').text = @asset_tag
      general.add_element('barcode_1').text = @barcode1
      general.add_element('barcode_2').text = @barcode2
      general.add_element('ip_address').text = @ip_address
      general.add_element('mac_address').text = @mac_address
      general.add_element('udid').text = @udid
      general.add_element('serial_number').text = @serial_number

      rmgmt = general.add_element('remote_management')
      rmgmt.add_element('managed').text = @managed
      rmgmt.add_element('management_username').text = @management_username
      rmgmt.add_element('management_password').text = @management_password if @management_password

      computer << ext_attr_xml if unsaved_eas?

      computer << location_xml if has_location?

      computer << purchasing_xml if has_purchasing?

      add_site_to_xml(doc)

      doc.to_s
    end # rest_xml

  end # class Computer

end # module
