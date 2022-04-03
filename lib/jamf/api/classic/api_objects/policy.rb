# Copyright 2020 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

module Jamf

  # Module Constants
  ######################

  # Module Variables
  ######################

  # Module Methods
  ######################

  # Classes
  #####################################

  # A class implementing a JSS Policy.
  #
  # Like many API objects, the data comes from the API in sections, and
  # the items in the :general section are mapped to direct attributes
  # of this Class.
  #
  #
  # Policy instances are partially read-only:
  # - Due to limitations in the API implementation of policies, as well as the complexity
  #   of policy objects, only these attributes can be set and updated via the Policy class:
  # - - name
  # - - frequency
  # - - target_drive
  # - - offline
  # - - enabled
  # - - category
  # - - triggers
  # - - client maintenance tasks
  # - - scope, see {Jamf::Scopable} and {Jamf::Scopable::Scope}
  # - - files and processes
  # - - packages, see {#add_package} and {#remove_package}
  # - - scripts see {#add_script} and {#remove_script}
  # - - self service, see {Jamf::SelfServable}
  # - - reboot options
  #
  # All other values and sections must be edited via the Web App.
  #
  # Policies may be deleted via this class
  #
  class Policy < Jamf::APIObject

    # Mix-Ins
    #####################################

    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Scopable
    include Jamf::Uploadable
    include Jamf::SelfServable
    include Jamf::Categorizable
    include Jamf::Sitable

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'policies'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :policies

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :policy

    # subsets available for fetching
    # TODO: FilesProcesses and Maintenance don't seem to work
    SUBSETS = %i[
      general
      scope
      selfservice
      self_service
      packages
      scripts
      printers
      dockitems
      dock_items
      reboot
      userinteraction
      user_interaction
      disk_encryption
      diskencryption
      accountmaintenance
      account_maintenance
    ].freeze

    # policies can take uploaded icons
    UPLOAD_TYPES = { icon: :policies }.freeze

    # policies are available in macOS self Serviec
    SELF_SERVICE_TARGET = :macos

    # policies via self services are still polcies
    SELF_SERVICE_PAYLOAD = :policy

    SECTIONS = %i[
      general
      maintenance
      account_maintenance
      scripts
      self_service
      package_configuration
      scope
      user_interaction
      reboot
      files_processes
      dock_items
      disk_encryption
      printers
    ].freeze

    FREQUENCIES = {
      ongoing: 'Ongoing',
      once_per_computer: 'Once per computer',
      once_per_user: 'Once per user',
      once_per_user_per_computer: 'Once per user per computer',
      daily: 'Once every day',
      weekly: 'Once every week',
      monthly: 'Once every month'
    }.freeze

    RETRY_EVENTS = {
      none: 'none',
      checkin: 'check-in',
      trigger: 'trigger'
    }.freeze

    RESTART_WHEN = {
      if_pkg_requires: 'Restart if a package or update requires it',
      now: 'Restart immediately',
      delayed: 'Restart',
      dont: 'Do not restart'
    }.freeze

    RESTART_DISKS = {
      current: 'Current Startup Disk',
      selected: 'Currently Selected Startup Disk (No Bless)',
      netboot: 'NetBoot',
      os_installer: 'inPlaceOSUpgradeDirectory'
    }.freeze # Note: any other value in :specify_startup is a path to some other drive to boot from, e.g. /Volumes/Foo

    ACCOUNT_ACTIONS = {
      create: 'Create',
      change_pw: 'Reset',
      delete: 'Delete',
      disable_fv2: 'DisableFileVault'
    }.freeze

    MGMT_ACCOUNT_ACTIONS = {
      no_change: 'doNotChange',
      change_pw: 'specified',
      generate_pw: 'random',
      enable_fv2: 'fileVaultEnable',
      disable_fv2: 'fileVaultDisable',
      reset_random: 'resetRandom',
      reset_pw: 'reset'
    }.freeze

    PACKAGE_ACTIONS = {
      install: 'Install',
      remove: 'Uninstall',
      cache: 'Cache',
      install_cache: 'Install Cached'
    }.freeze

    SCRIPT_PRIORITIES = {
      pre: 'Before',
      before: 'Before',
      post: 'After',
      after: 'After'
    }.freeze

    DISK_ENCRYPTION_ACTIONS = {
      apply: "apply",
      remediate: "remediate",
      none: "none"
    }

    PRINTER_ACTIONS = {
      map: 'install',
      unmap: 'uninstall'
    }.freeze

    DOCK_ITEM_ACTIONS = {
      add_start: 'Add To Beginning',
      add_end: 'Add To End', remove: 'Remove'
    }.freeze

    NETWORK_REQUIREMENTS = {
      any: 'Any',
      ethernet: 'EtherNet'
    }.freeze

    TRIGGER_TYPES = {
      event: 'EVENT',
      user: 'USER_INITIATED'
    }.freeze

    TRIGGER_EVENTS = {
      startup: :trigger_startup,
      login: :trigger_login,
      logout: :trigger_logout,
      checkin: :trigger_checkin,
      network_state: :trigger_network_state_changed,
      enrollment: :trigger_enrollment_complete,
      custom: :trigger_other
    }.freeze

    NO_USER_LOGGED_IN = [
      'Do not restart',
      'Restart immediately',
      'Restart if a package or update requires it'
    ].freeze

    USER_LOGGED_IN = [
      'Do not restart',
      'Restart',
      'Restart if a package or update requires it',
      'Restart immediately'
    ].freeze

    SCOPE_TARGET_KEY = :computers

    # Log Flushing

    LOG_FLUSH_RSRC = 'logflush'.freeze

    LOG_FLUSH_INTERVAL_INTEGERS = {
      0 => 'Zero',
      1 => 'One',
      2 => 'Two',
      3 => 'Three',
      6 => 'Six'
    }.freeze

    LOG_FLUSH_INTERVAL_PERIODS = {
      day: 'Days',
      days: 'Days',
      week: 'Weeks',
      weeks: 'Weeks',
      month: 'Months',
      months: 'Months',
      year: 'Years',
      years: 'Years'
    }.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 3

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :general

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = Hash

    # All valid script parameters
    SCRIPT_PARAMETERS_AVAILABLE = %i[parameter4 parameter5 parameter6 parameter7 parameter8 parameter9 parameter10 parameter11].freeze

    # Class Methods
    ######################

    # Flush logs for a given policy older than some number of days, weeks,
    # months or years, possibly limited to one or more computers.
    #
    # With no parameters, flushes all logs for the policy for all computers.
    #
    # NOTE: Currently the API doesn't have a way to flush only failed policies.
    #
    # WARNING: Log flushing can take a long time, and the API call doesnt return
    # until its finished. The connection timeout will be temporarily raised to
    # 30 minutes, unless it's already higher.
    #
    # @param policy[Integer,String] The id or name of the policy to flush
    #
    # @param older_than[Integer] 0, 1, 2, 3, or 6
    #
    # @param period[Symbol] :days, :weeks, :months, or :years
    #
    # @param computers[Array<Integer,String>] Identifiers of the target computers
    #   either ids, names, SNs, macaddrs, or UDIDs. If omitted, flushes logs for
    #   all computers
    #
    # @param api [Jamf::Connection] the API  connection to use.
    #
    # @return [void]
    #
    def self.flush_logs(policy, older_than: 0, period: :days, computers: [], api: Jamf.cnx)
      orig_timeout = api.cnx.options.timeout
      pol_id = valid_id policy
      raise Jamf::NoSuchItemError, "No Policy identified by '#{policy}'." unless pol_id

      older_than = LOG_FLUSH_INTERVAL_INTEGERS[older_than]
      raise Jamf::InvalidDataError, "older_than must be one of these integers: #{LOG_FLUSH_INTERVAL_INTEGERS.keys.join ', '}" unless older_than

      period = LOG_FLUSH_INTERVAL_PERIODS[period]
      raise Jamf::InvalidDataError, "period must be one of these symbols: :#{LOG_FLUSH_INTERVAL_PERIODS.keys.join ', :'}" unless period

      computers = [computers] unless computers.is_a? Array

      # log flushes can be really slow
      api.timeout = 1800 unless orig_timeout && orig_timeout > 1800

      return api.c_delete "#{LOG_FLUSH_RSRC}/policy/id/#{pol_id}/interval/#{older_than}+#{period}" if computers.empty?

      flush_logs_for_specific_computers pol_id, older_than, period, computers, api
    ensure
      api.timeout = orig_timeout
    end

    # use an XML body in a DELETE request to flush logs for
    # a list of computers - used by the flush_logs class method
    def self.flush_logs_for_specific_computers(pol_id, older_than, period, computers, api)
      # build the xml body for a DELETE request
      xml_doc = REXML::Document.new Jamf::Connection::XML_HEADER
      lf = xml_doc.add_element 'logflush'
      lf.add_element('log').text = 'policy'
      lf.add_element('log_id').text = pol_id.to_s
      lf.add_element('interval').text = "#{older_than} #{period}"
      comps_elem = lf.add_element 'computers'
      computers.each do |c|
        id = Jamf::Computer.valid_id c
        next unless id

        ce = comps_elem.add_element 'computer'
        ce.add_element('id').text = id.to_s
      end

      # Do a DELETE request with a body.
      api.cnx.delete(LOG_FLUSH_RSRC) do |req|
        req.headers[Jamf::Connection::HTTP_CONTENT_TYPE_HEADER] = Jamf::Connection::MIME_XML
        req.body = xml_doc.to_s
      end
    end
    private_class_method :flush_logs_for_specific_computers

    # Attributes
    ######################

    ##### General
    # This data comes from the :general hash in the raw JSON data
    # and correspond to the general section of the Edit Policy window in
    # the JSS WebApp. They are general settings for this policy.
    # We'll map it to direct attributes.

    # @return [String] how often to run the policy on each computer
    attr_reader :frequency

    # @return [String] which drive should the policy target
    attr_reader :target_drive

    # @return [Boolean] should be policy be available offline
    attr_reader :offline

    # @return [Boolean] is the policy enabled?
    attr_reader :enabled
    alias enabled? enabled

    # @return [String] a string with the site name
    attr_reader :site

    # @return [Hash]
    #
    # Overrides for various defaults
    #
    # NOTE: There's an API bug in both XML and JSON with the
    #   :distribution_point and :target_drive values.
    #   First off, it's not clear what the :target_drive value here
    #   is overriding, since there's a :target_drive value in the
    #   main General hash.
    #   Second off - when you set a non-default dist.point in the
    #   packages section of the UI, that value shows up in both
    #   this :target_drive and the general one, but the :distribution_point
    #   value here stays empty.
    #
    # The hash looks like:
    # :distribution_point => "",
    # :force_afp_smb => false,
    # :netboot_server => "current",
    # :target_drive => "default",
    # :sus => "default"
    #
    attr_reader :override_default_settings

    # The API has a :network_requirements key in the general section, but
    # in the UI its in a subsection called Client Side Limitiations.
    # so we'll store it in a hash called client_side_limitations,
    # defined below.

    # the network_limitations hash of the general section seems to be redundant.
    # it contains minimum_network_connection ("Ethernet" or "No Minimum")
    #    which is also reflected in the general[:network_requirements] ("Ethernet" or "Any")
    # it contains network_segments, which are also listed
    #    in the limitations hash of the scope section
    # it contains any_ip_address, which is true or false based on there being
    #     any network_segment limitations.
    # Therefore, we'll ignore it, and use the other places for that data

    # The API has a general key ":date_time_limitations" which has this
    # this data:
    #   :activation - Time
    #   :expiration - Time
    #   :no_execute_on - An array of short day names as symbols, e.g. [:sun, :mon, :wed, :thu]
    #   :no_execute_start - Time
    #   :no_execute_end - Time
    # but in the UI, those are set in the Server Side Limitiations and Client Side Limitiations.
    # areas, so we'll store them in matching hashes below.
    #     attr_reader :date_time_limitations

    # @return [Hash]
    #
    # The server-side limitations of this policy.
    #
    # The keys are :activation and :expiration, both are Times.
    #
    # the data comes from the API in the date_time_limitations hash of the general
    # section, but the UI shows them in the Server Side Limitations area.
    # This attribute is just for convience and consistency, and just
    # refers to the data in their API locations
    attr_reader :server_side_limitations

    # @return [Hash]
    #
    # The client-side limitations of this policy.
    #
    # The keys are:
    # - :no_execute_on - An array of short day names as strings, e.g. ["Sun", "Mon", "Tue"]
    # - :no_execute_start - Time
    # - :no_execute_end - Time
    # - :network_connection - String
    # The data for the first three comes from the API in the date_time_limitations
    # hash of the general section.
    # The fourth comes from the network_requirements of the general section of the API,
    # but the UI shows them in the Client Side Limitations area.
    #
    # This attribute is just for convience and consistency, and just
    # refers to the data in their API locations
    attr_reader :client_side_limitations

    # @return [String]
    #
    # Either EVENT or USER_INITIATED
    #
    # If it's EVENT, then one or more of the members @trigger_events must true.
    attr_reader :trigger

    # @return [Hash]
    #
    # The triggers that cause this policy to execute on a client when the @trigger is "EVENT"
    #
    # This is a hash with the following keys. Each comes from the API
    # as a key in the :general hash, but they make more sense separated out
    # like this.
    # - :trigger_startup  => Bool
    # - :trigger_login  => Bool
    # - :trigger_logout  => Bool
    # - :trigger_checkin  => Bool
    # - :trigger_network_state_changed  => Bool
    # - :trigger_enrollment_complete  => Bool
    # - :trigger_other => the String that causes a custom trigger
    #
    # To edit a value, call
    #   set_trigger_event(type, new_val)
    # where type is one of the keys in TRIGGER_EVENTS and new val is the new value (usually boolean)
    #
    attr_reader :trigger_events

    ###### client machine maintenence
    # These are the computer maint. tasks
    # that might be performed by this policy
    # All are boolean

    # Should this policy verify the startup disk?
    # @return [Boolean] client maintenance task
    attr_reader :verify_startup_disk

    # Should this policy run a permission repair?
    # @return [Boolean] client maintenance task
    attr_reader :permissions_repair

    # Should this policy run a recon?
    # @return [Boolean] client maintenance task
    attr_reader :recon
    alias update_inventory recon

    # Should this policy fix the ByHost prefs?
    # @return [Boolean] client maintenance task
    attr_reader :fix_byhost

    # Should this policy reset the local hostname?
    # @return [Boolean] client maintenance task
    attr_reader :reset_name

    # Should this policy flush the system cache?
    # @return [Boolean] client maintenance task
    attr_reader :flush_system_cache

    # Should this policy install any cached JSS packages?
    # @return [Boolean] client maintenance task
    attr_reader :install_cached_pkgs

    # Should this policy flush the user cache?
    # @return [Boolean] client maintenance task
    attr_reader :flush_user_cache

    # @return [Array<Hash>]
    #
    # The directory bindings applied
    #
    # each hash is like: !{:name => "LDAP", :id => 4}
    # TODO: handle as for packages & scripts
    attr_reader :directory_bindings

    # @return [Hash] the open firmware mode and password
    attr_reader :open_firmware_efi_password

    # @return [Hash]
    #
    # The management accout changes applied by the policy
    #
    # The keys are:
    # - :action see MGMT_ACCOUNT_ACTIONS
    # - :managed_password
    # - :managed_password_md5
    # - :managed_password_sha256
    # - :managed_password_length  # for random generating pws
    #
    # TODO: make individial getters/setters as for @files_processes
    attr_reader :management_account

    # @return [Array<Hash>]
    #
    # Local accts acted-upon by this policy
    #
    # Keys are:
    # - :action => "Create",
    # - :hint => "foo  bar",
    # - :picture => "/path/to/pic.tif",
    # - :admin => true,
    # - :home => "/Users/chrisltest",
    # - :realname => "ChrisTest Lasell",
    # - :filevault_enabled => true,
    # - :username => "chrisltest",
    # - :password_md5 => "3858f62230ac3c915f300c664312c63f",
    # - :password => "foobar",
    # - :password_sha256=> "c3ab8ff13720e8ad9047dd39466b3c8974e592c2fa383d4a3960714caef0c4f2"
    #
    # TODO: make individial getters/setters as for @files_processes
    attr_reader :accounts

    # @return [Array<Hash>]
    #
    # The pkgs handled by this policy
    #
    # Hash keys are:
    # - :action => "Install"
    # - :update_autorun => false,
    # - :feu => false,
    # - :name => "rbgem-json-1.6.5-4.pkg",
    # - :id => 1073
    #
    attr_reader :packages
    alias pkgs packages

    # @return [Array<Hash>]
    #
    # The scripts run by this policy
    #
    # Hash keys are:
    # - :name => "chromegetter.sh",
    # - :parameter4 => "",
    # - :parameter5 => "",
    # - :parameter6 => "",
    # - :parameter7 => "",
    # - :parameter8 => "",
    # - :parameter9 => "",
    # - :parameter10 => "",
    # - :parameter11 => "",
    # - :id => 1428,
    # - :priority => "After"
    #
    attr_reader :scripts

    ###### user interaction
    # These are extracted from the :user_interaction hash
    # in the JSON output, which looks like this:
    #   :message_start => "",
    #   :allow_users_to_defer => false,
    #   :allow_deferral_until_utc => "",
    #   :message_finish => ""
    #
    # TODO: make individial getters/setters as for @files_processes

    # @return [Boolean] can the user defer the policy?
    attr_reader :user_may_defer

    # @return [Time] when is the user no longer allowed to defer?
    attr_reader :user_may_defer_until

    # @return [String] the message shown the user at policy start
    attr_reader :user_message_start

    # @return [String] the message shown the user at policy end
    attr_reader :user_message_finish
    alias user_message_end user_message_finish

    # @return [Hash]
    #
    # Reboot options for the policy
    #
    # The hash keys are:
    # - :user_logged_in => "Do not restart",
    # - :minutes_until_reboot => 5,
    # - :message=> "This computer will restart in 5 minutes. yaddayadda.",
    # - :startup_disk => "Current Startup Disk",
    # - :specify_startup => "",
    # - :no_user_logged_in => "Do not restart"
    # - :file_vault_2_reboot => false
    #
    attr_reader :reboot_options

    ##### files & processes
    # a hash like this:
    # {:spotlight_search => "Spotlight This",
    #  :search_for_process => "SafariProcess",
    #  :search_by_path => "/this/is/a/path",
    #  :kill_process => true,
    #  :delete_file => true,
    #  :run_command => "/usr/local/pixar/sbin/force-fde-logout  --setup",
    #  :locate_file => "this-is-a-filename",
    #  :update_locate_database => true}
    #
    # NOTE, since these items are editable, they have custom getters/setters
    # so that the hash isn't directly changable without @need_to_update.
    # attr_reader :files_processes

    # @return [Array<Hash>]
    #
    # The dock items handled by this policy
    #
    # each item hash looks like: !{:name => "Mail", :id => 14, :action => "Add To Beginning"}
    attr_reader :dock_items

    # @return [Hash]
    #
    # Disk encryption options for this policy
    #
    # The hash looks like !{:disk_encryption_configuration_id => 3, :action => "apply"}
    attr_reader :disk_encryption

    # @return [Array<Hash>]
    #
    # The printers handled by this policy
    #
    # Each Hash looks like: !{:make_default => false, :name => "torlan", :id => 3, :action => "install"}
    attr_reader :printers

    #####################################
    # Public Instance Methods
    #####################################

    # @see APIObject#initialize
    #
    def initialize(args = {})
      super

      if @in_jss
        gen = @init_data[:general]
        @target_drive = gen[:target_drive]
        @offline = gen[:offline]
        @enabled = gen[:enabled]
        @site = Jamf::APIObject.get_name(gen[:site][:name])
        @override_default_settings = gen[:override_default_settings]
        @trigger = gen[:trigger]
        @trigger_events = {
          trigger_startup: gen[:trigger_startup],
          trigger_login: gen[:trigger_login],
          trigger_logout: gen[:trigger_logout],
          trigger_checkin: gen[:trigger_checkin],
          trigger_network_state_changed: gen[:trigger_network_state_changed],
          trigger_enrollment_complete: gen[:trigger_enrollment_complete],
          trigger_other: gen[:trigger_other]
        }
        @frequency = gen[:frequency]
        @retry_event = gen[:retry_event]
        @retry_attempts = gen[:retry_attempts]
        @notify_failed_retries = gen[:notify_on_each_failed_retry]

        dtl = gen[:date_time_limitations]

        @server_side_limitations = {
          activation: JSS.epoch_to_time(dtl[:activation_date_epoch]),
          expiration: JSS.epoch_to_time(dtl[:expiration_date_epoch])
        }

        @client_side_limitations = {
          no_execute_on: dtl[:no_execute_on], # NOTE- there's a bug in the JSON output, it's been reported to JAMF.
          no_execute_start: dtl[:no_execute_start], # String like "1:01 AM"
          no_execute_end: dtl[:no_execute_end], # String like "2:02 PM"
          network_requirements: gen[:network_requirements]
        }

        maint = @init_data[:maintenance]
        @verify_startup_disk = maint[:verify]
        @permissions_repair = maint[:permissions]
        @recon = maint[:recon]
        @fix_byhost = maint[:byhost]
        @reset_name = maint[:reset_name]
        @flush_system_cache = maint[:system_cache]
        @install_cached_pkgs = maint[:install_all_cached_packages]
        @flush_user_cache = maint[:user_cache]

        amaint = @init_data[:account_maintenance]
        @directory_bindings = amaint[:directory_bindings]
        @open_firmware_efi_password = amaint[:open_firmware_efi_password]
        @management_account = amaint[:management_account]
        @accounts = amaint[:accounts]

        @packages = @init_data[:package_configuration][:packages] ? @init_data[:package_configuration][:packages] : []

        @scripts = @init_data[:scripts]

        uint = @init_data[:user_interaction]
        @user_may_defer = uint[:allow_users_to_defer]
        @user_may_defer_until = JSS.parse_datetime uint[:allow_deferral_until_utc]
        @user_message_start =  uint[:message_start]
        @user_message_finish = uint[:message_finish]

        @reboot_options = @init_data[:reboot]

        @files_processes = @init_data[:files_processes]

        @dock_items = @init_data[:dock_items]

        @disk_encryption = @init_data[:disk_encryption]

        @printers = @init_data[:printers]
        @printers.shift

        # Not in jss yet
      end

      # set non-nil defaults
      @enabled ||= false
      @frequency ||= 'Once per computer'
      @target_drive ||= '/'
      @offline ||= false
      @override_default_settings ||= {}
      @scripts ||= []
      @server_side_limitations ||= {}
      @client_side_limitiations ||= {}
      @trigger_events ||= {}
      @directory_bindings ||= []
      @open_firmware_efi_password ||= {}
      @management_account ||= {}
      @accounts  ||= []
      @packages  ||= []
      @scripts ||= []
      @self_service ||= {}
      @dock_items ||= []
      @disk_encryption ||= {}
      @printers ||= []
      @files_processes ||= {}
      unless @reboot_options
        @reboot_options = {}
        @reboot_options[:user_logged_in] = 'Do not restart'
        @reboot_options[:no_user_logged_in] = 'Do not restart'
      end

      @scope ||= Jamf::Scopable::Scope.new(:computers, all_computers: false)
    end # init

    ###### General

    # Change the enabled state of this item
    #
    # @param new_val[Boolean]  the new state.
    #
    # @return [void]
    #
    def enabled=(new_val)
      return if @enabled == new_val
      @enabled = Jamf::Validate.boolean new_val
      @need_to_update = true
    end

    # Shortcut for enabled = true
    def enable
      self.enabled = true
    end

    # Shortcut for endabled = false
    def disable
      self.enabled = false
    end

    # Set a new frequency for this policy.
    #
    # @param freq[Symbol] the desired frequency, must be one of the keys of {FREQUENCIES}
    #
    # @return [void]
    #
    def frequency=(freq)
      raise Jamf::InvalidDataError, "New frequency must be one of :#{FREQUENCIES.keys.join ', :'}" unless FREQUENCIES.key?(freq) || FREQUENCIES.value?(freq)

      freq = freq.is_a?(Symbol) ? FREQUENCIES[freq] : freq
      return if freq == @frequency

      @frequency = freq
      @need_to_update = true
    end

    # @return [String] The event that causes a policy retry
    def retry_event
      return RETRY_EVENTS[:none] unless FREQUENCIES[:once_per_computer] == @frequency

      @retry_event
    end

    # Set the event that causes a retry if the policy fails.
    # One of the ways to turn off policy retry is to set this to :none
    # The other is to set the retry_attempts to 0
    #
    # @param [Symbol, String] A key or value from RETRY_EVENTS
    # @return [void]
    #
    def retry_event=(evt)
      validate_retry_opt
      raise Jamf::InvalidDataError, "Retry event must be one of :#{RETRY_EVENTS.keys.join ', :'}" unless RETRY_EVENTS.key?(evt) || RETRY_EVENTS.value?(evt)

      evt = evt.is_a?(Symbol) ? RETRY_EVENTS[evt] : evt
      return if evt == @retry_event

      # if the event is not 'none' and attempts is <= 0,
      # set events to 1, or the API won't accept it
      unless evt == RETRY_EVENTS[:none]
        @retry_attempts = 1 unless @retry_attempts.positive?
      end

      @retry_event = evt
      @need_to_update = true
    end

    # @return [Integer] How many times wil the policy be retried if it fails.
    #   -1 means no retries,  otherwise, an integer from 1 to 10
    def retry_attempts
      return 0 unless FREQUENCIES[:once_per_computer] == @frequency

      @retry_attempts
    end

    # Set the number of times to retry if the policy fails.
    # One of the ways to turn off policy retry is to set this to 0 or -1
    # The other is to set retry_event to :none
    #
    # @param [Integer] From -1 to 10
    # @return [void]
    #
    def retry_attempts=(int)
      validate_retry_opt
      raise Jamf::InvalidDataError, 'Retry attempts must be an integer from 0-10' unless int.is_a?(Integer) && (-1..10).include?(int)

      # if zero or -1, turn off retries
      if int <= 0
        @retry_event = RETRY_EVENTS[:none]
        int = -1
      end
      return if @retry_attempts == int

      @retry_attempts = int
      @need_to_update = true
    end

    # @return [Boolean] Should admins be notified of failed retry attempts
    def notify_failed_retries?
      return false unless FREQUENCIES[:once_per_computer] == @frequency

      @notify_failed_retries
    end
    alias notify_failed_retries notify_failed_retries?
    alias notify_on_each_failed_retry notify_failed_retries?

    # @param bool[Boolean] Should admins be notified of failed retry attempts
    # @return [void]
    def notify_failed_retries=(bool)
      validate_retry_opt
      bool = Jamf::Validate.boolean bool
      return if @notify_failed_retries == bool

      @notify_failed_retries = bool
      @need_to_update = true
    end

    # Set a new target drive for this policy.
    #
    # @param path_to_drive[String,Pathname] the full path to the target drive, must start with a '/'
    #
    # @return [void]
    #
    def target_drive=(path_to_drive)
      raise Jamf::InvalidDataError, 'Path to target drive must be absolute' unless path_to_drive.to_s.start_with? '/'
      @target_drive = path_to_drive.to_s
      @need_to_update = true
    end

    # Set whether this policy is available offline.
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def offline=(new_val)
      raise Jamf::InvalidDataError, 'New value must be boolean true or false' unless Jamf::TRUE_FALSE.include? new_val
      @offline = new_val
      @need_to_update = true
    end

    # Change a trigger event
    #
    # @param type[Symbol] the type of trigger, one of the keys of {TRIGGER_EVENTS}
    #
    # @param new_val[Boolean] whether the type of trigger is active or not.
    #
    # @return [void]
    #
    def set_trigger_event(type, new_val)
      raise Jamf::InvalidDataError, "Trigger type must be one of #{TRIGGER_EVENTS.keys.join(', ')}" unless TRIGGER_EVENTS.key?(type)
      if type == :custom
        raise Jamf::InvalidDataError, 'Custom triggers must be Strings' unless new_val.is_a? String
      else
        raise Jamf::InvalidDataError, 'Non-custom triggers must be true or false' unless Jamf::TRUE_FALSE.include? new_val
      end
      @trigger_events[TRIGGER_EVENTS[type]] = new_val
      @need_to_update = true
    end

    # Set Server Side Activation
    #
    # @param activation[Time] Activation date and time
    #
    # @return [void]
    #
    def server_side_activation=(activation)
      raise Jamf::InvalidDataError, 'Activation must be a Time' unless activation.is_a? Time
      @server_side_limitations[:activation] = activation
      @need_to_update = true
    end

    # Set Server Side Expiration
    #
    # @param expiration[Time] Expiration date and time
    #
    # @return [void]
    #
    def server_side_expiration=(expiration)
      raise Jamf::InvalidDataError, 'Expiration must be a Time' unless expiration.is_a? Time
      @server_side_limitations[:expiration] = expiration
      @need_to_update = true
    end

    # Maintenance tasks

    # see attr_reader :verify_startup_disk
    #
    def verify_startup_disk=(bool)
      return if @verify_startup_disk == bool
      @verify_startup_disk = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # see attr_reader :permissions_repair
    #
    def permissions_repair=(bool)
      return if @permissions_repair == bool
      @permissions_repair = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # see attr_reader :recon
    #
    def recon=(bool)
      return if @recon == bool
      @recon = Jamf::Validate.boolean bool
      @need_to_update = true
    end
    alias update_inventory= recon=

    # see attr_reader :fix_byhost
    #
    def fix_byhost=(bool)
      return if @fix_byhost == bool
      @fix_byhost = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # see attr_reader :reset_name
    #
    def reset_name=(bool)
      return if @reset_name == bool
      @reset_name = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # see attr_reader :flush_system_cache
    #
    def flush_system_cache=(bool)
      return if @flush_system_cache == bool
      @flush_system_cache = Jamf::Validate.boolean bool
      @need_to_update = true
    end # see attr_reader :recon

    # see attr_reader :install_cached_pkgs
    #
    def install_cached_pkgs=(bool)
      return if @install_cached_pkgs == bool
      @install_cached_pkgs = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # see attr_reader :flush_user_cache
    #
    def flush_user_cache=(bool)
      return if @flush_user_cache == bool
      @flush_user_cache = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # Reboot Options
    #######

    # What to do at reboot when No User Logged In
    #
    # @param no_user_option[String] Any one of the Strings from NO_USER_LOGGED_IN
    #
    # @return [void]
    #
    def no_user_logged_in=(no_user_option)
      raise Jamf::InvalidDataError, "no_user_logged_in options: #{NO_USER_LOGGED_IN.join(', ')}" unless NO_USER_LOGGED_IN.include? no_user_option
      @reboot_options[:no_user_logged_in] = no_user_option
      @need_to_update = true
    end

    # What to do at reboot when there is a User Logged In
    #
    # @param logged_in_option[String] Any one of the Strings from USER_LOGGED_IN
    #
    # @return [void]
    #
    def user_logged_in=(logged_in_option)
      raise Jamf::InvalidDataError, "user_logged_in options: #{USER_LOGGED_IN.join(', ')}" unless USER_LOGGED_IN.include? logged_in_option
      @reboot_options[:user_logged_in] = logged_in_option
      @need_to_update = true
    end

    # Set Reboot Message
    #
    # @param reboot_message[String] Text of Reboot Message
    #
    # @return [void] description of returned object
    #
    def reboot_message=(message)
      raise Jamf::InvalidDataError, 'Reboot message must be a String' unless message.is_a? String
      @reboot_options[:message] = message
      @need_to_update = true
    end
    alias message= reboot_message=

    # Set User Start Message
    #
    # @param user_message[String] Text of User Message
    #
    # @return [void] description of returned object
    def user_message_start=(message)
      raise Jamf::InvalidDataError, 'User message must be a String' unless message.is_a? String
      @user_message_start = message
      @need_to_update = true
    end

    # Set User Finish Message
    #
    # @param user_message[String] Text of User Message
    #
    # @return [void] description of returned object
    def user_message_end=(message)
      raise Jamf::InvalidDataError, 'User message must be a String' unless message.is_a? String
      @user_message_finish = message
      @need_to_update = true
    end

    alias user_message_finish= user_message_end=

    # Set Startup Disk
    # Only Supports 'Specify Local Startup Disk' at the moment
    #
    # @param startup_disk_option[String]
    #
    # @return [void]
    #
    def startup_disk=(startup_disk_option)
      raise Jamf::InvalidDataError, "#{startup_disk_option} is not a valid Startup Disk" unless startup_disk_option.is_a? String
      @reboot_options[:startup_disk] = 'Specify Local Startup Disk'
      self.specify_startup = startup_disk_option
      @need_to_update = true
    end

    # Specify Startup Volume
    # Only Supports "Specify Local Startup Disk"
    #
    # @param startup_volume[String] a Volume to reboot to
    #
    # @return [void]
    #
    def specify_startup=(startup_volume)
      raise Jamf::InvalidDataError, "#{startup_volume} is not a valid Startup Disk" unless startup_volume.is_a? String
      @reboot_options[:specify_startup] = startup_volume
      @need_to_update = true
    end

    # Reboot Options
    # Do Not Reboot
    # Shortcut method to suppress Reboot Options
    #
    # @return [void]
    #
    def do_not_reboot
      @reboot_options[:user_logged_in] = 'Do not restart'
      @reboot_options[:no_user_logged_in] = 'Do not restart'
      @need_to_update = true
    end

    # Reboot Options
    # Minutes Until Reboot
    #
    # @param minutes[String] The number of minutes to delay prior to reboot
    #
    # @return [void]
    #
    def minutes_until_reboot=(minutes)
      raise Jamf::InvalidDataError, 'Minutes until reboot must be an Integer' unless minutes.is_a? Integer
      @reboot_options[:minutes_until_reboot] = minutes
      @need_to_update = true
    end

    # Reboot Options
    # FileVault Authenticated Reboot
    #
    # @param fv_bool[Boolean] true or false
    #
    # @return [void]
    #
    def file_vault_2_reboot=(fv_bool)
      raise Jamf::InvalidDataError, 'FileVault 2 Reboot must be a Boolean' unless fv_bool.jss_boolean?
      @reboot_options[:file_vault_2_reboot] = fv_bool
      @need_to_update = true
    end

    ###### Files & Processes

    # @return [String] The unix shell command to run on ths client.
    #
    def run_command
      @files_processes[:run_command]
    end
    alias command_to_run run_command

    # Set the unix shell command to be run on the client
    #
    # @param command[String] the unix shell command to be run on the client
    #
    # @return [void]
    #
    def run_command=(command)
      raise Jamf::InvalidDataError, 'Command to run must be a String' unless command.is_a? String
      @files_processes[:run_command] = command
      @need_to_update = true
    end
    alias command_to_run= run_command=

    # @return [Boolean] Should we update the database used by the locate command?
    #
    def update_locate_database?
      @files_processes[:update_locate_database]
    end

    # Set whether or not to update the database used by the locate command.
    #
    # @param bool [Boolean] whether or not to update the database used by the locate command.
    #
    # @return [void]
    #
    def update_locate_database=(bool)
      @files_processes[:update_locate_database] = Jamf::Validate.boolean bool
      @need_to_update = true
    end

    # @return [String] The process name to search for on the client
    #
    def search_for_process
      @files_processes[:search_for_process]
    end

    # @return [Boolean] Should the searched-for process be killed if found.
    #
    def kill_process?
      @files_processes[:kill_process]
    end

    # Set the process name to search for, and if it should be killed if found.
    #
    # Setter methods (which end with =) can't easily take
    # multiple arguments, so we instead name them "set_blah_blah"
    # rather than "blah_blah="
    #
    # @param process[String] the process name to search for
    #
    # @param kill[Boolean] should be process be killed if found
    #
    # @return [void]
    #
    def set_search_for_process(process, kill = false)
      @files_processes[:search_for_process] = process.to_s
      @files_processes[:kill_process] = kill ? true : false
      @need_to_update = true
    end

    # @return [Pathname] The path to search for
    #
    def search_by_path
      if @files_processes[:search_by_path].nil?
        return nil
      else
        Pathname.new @files_processes[:search_by_path]
      end
    end

    # @return [Boolean] Should the searched-for path be deleted if found?
    #
    def delete_file?
      @files_processes[:delete_file]
    end
    alias delete_path? delete_file?

    # Set the path to search for, a String or Pathname, and whether or not to delete it if found.
    #
    # Setter methods (which end with =) can't easily take
    # multiple arguments, so we instead name them "set_blah_blah"
    # rather than "blah_blah="
    #
    # @param path[String,Pathname] the path to search for
    #
    # @param delete[Boolean] should the path be deleted if found
    #
    # @return [void]
    #
    def set_search_by_path(path, delete = false)
      raise Jamf::InvalidDataError, 'Path to search for must be a String or a Pathname' unless path.is_a?(String) || path.is_a?(Pathname)
      @files_processes[:search_by_path] = path.to_s
      @files_processes[:delete_file] = delete ? true : false
      @need_to_update = true
    end

    # @return [String] The term to search for using spotlight
    #
    def spotlight_search
      @files_processes[:spotlight_search]
    end

    # Set the term to seach for using spotlight
    #
    # @param term[String] the term to seach for using spotlight
    #
    # @return [void]
    #
    def spotlight_search=(term)
      raise Jamf::InvalidDataError, 'Spotlight search term must be a String' unless term.is_a? String
      @files_processes[:spotlight_search] = term
      @need_to_update = true
    end

    # @return [String] The term to seach for using the locate command
    #
    def locate_file
      @files_processes[:locate_file]
    end

    # Set the term to seach for using the locate command
    #
    # @param term[String] the term to seach for using the locate command
    #
    # @return [void]
    #
    def locate_file=(term)
      raise Jamf::InvalidDataError, 'Term to locate must be a String' unless term.is_a? String
      @files_processes[:locate_file] = term
      @need_to_update = true
    end

    ###### Client maintenance

    # Set the

    ###### Packages

    # @return [Array] the id's of the packages handled by the policy
    def package_ids
      @packages.map { |p| p[:id] }
    end

    # @return [Array] the names of the packages handled by the policy
    def package_names
      @packages.map { |p| p[:name] }
    end

    # Add a package to the list of pkgs handled by this policy.
    # If the pkg already exists in the policy, nil is returned and
    # no changes are made.
    #
    # @param [String,Integer] identifier the name or id of the package to add to this policy
    #
    # @param position [Symbol, Integer] where to add this pkg among the list of
    #   pkgs. Zero-based, :start and 0 are the same, as are :end and -1.
    #   Defaults to :end
    #
    # @param action [String] One of the values of PACKAGE_ACTIONS
    #
    # @param feu [Boolean]  Overrides the setting for the pkg itself Defaults to false
    #
    # @param fut [Boolean] Overrides the setting for the pkg itself Defaults to false
    #
    # @param update_autorun [Boolean] Defaults to false
    #
    # @return [Array, nil]  the new @packages array, nil if pkg was already in the policy
    #
    def add_package(identifier, **opts)
      id = validate_package_opts(identifier, opts)

      return nil if @packages.map { |p| p[:id] }.include? id

      name = Jamf::Package.map_all_ids_to(:name, api: @api)[id]

      pkg_data = {
        id: id,
        name: name,
        action: PACKAGE_ACTIONS[opts[:action]],
        feu: opts[:feu],
        fut: opts[:feu],
        update_autorun: opts[:update_autorun]
      }

      @packages.insert opts[:position], pkg_data

      @need_to_update = true
      @packages
    end

    # Remove a package from this policy by name or id
    #
    # @param identifier [String,Integer] the name or id of the package to remove
    #
    # @return [Array, nil] the new packages array or nil if no change
    #
    def remove_package(identifier)
      removed = @packages.delete_if { |p| p[:id] == identifier || p[:name] == identifier }
      @need_to_update = true if removed
      removed
    end

    ###### Scripts

    # @return [Array] the id's of the scripts handled by the policy
    def script_ids
      @scripts.map { |p| p[:id] }
    end

    # @return [Array] the names of the scripts handled by the policy
    def script_names
      @scripts.map { |p| p[:name] }
    end

    # Add a script to the list of SCRIPT_PRIORITIESipts run by this policy.
    # If the script already exists in the policy, nil is returned and
    # no changes are made.
    #
    # @param [String,Integer] identifier the name or id of the script to add to this policy
    #
    # @param [Hash] opts the options for this script
    #
    # @option [Symbol, Integer] position: where to add this script among the list of
    #   scripts. Zero-based, :start and 0 are the same, as are :end and -1. Defaults to :end
    #
    # @option [Symbol] priority: either :before or :after
    #
    # @option [String] parameter4: the value of the 4th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter5: the value of the 5th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter6: the value of the 6th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter7: the value of the 7th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter8: the value of the 8th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter9: the value of the 9th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter10: the value of the 10th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter11: the value of the 11th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @return [Array, nil]  the new @scripts array, nil if script was already in the policy
    #
    def add_script(identifier, **opts)
      id = validate_script_opts(identifier, opts)

      return nil if @scripts.map { |s| s[:id] }.include? id

      name = Jamf::Script.map_all_ids_to(:name, api: @api)[id]

      script_data = {
        id: id,
        name: name,
        priority: SCRIPT_PRIORITIES[opts[:priority]],
        parameter4: opts[:parameter4],
        parameter5: opts[:parameter5],
        parameter6: opts[:parameter6],
        parameter7: opts[:parameter7],
        parameter8: opts[:parameter8],
        parameter9: opts[:parameter9],
        parameter10: opts[:parameter10],
        parameter11: opts[:parameter11]
      }

      @scripts.insert opts[:position], script_data

      @need_to_update = true
      @scripts
    end

    # Remove a script from this policy by name or id
    #
    # @param identifier [String,Integer] the name or id of the script to remove
    #
    # @return [Array, nil] the new scripts array or nil if no change
    #
    def remove_script(identifier)
      removed = @scripts.delete_if { |s| s[:id] == identifier || s[:name] == identifier }
      @need_to_update = true if removed
      removed
    end

    # Set a script parameter
    #
    # @param identifier [Integer,String] identifier the id or name of a script in this policy
    #
    # @param opts [Hash] opts the options to alter for this script
    #
    # @option [String] parameter4: the value of the 4th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter5: the value of the 5th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter6: the value of the 6th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter7: the value of the 7th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter8: the value of the 8th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter9: the value of the 9th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter10: the value of the 10th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @option [String] parameter11: the value of the 11th parameter passed to the script. this
    #   overrides the same parameter in the script object itself.
    #
    # @return [Array] the scripts array
    #
    def set_script_parameters(identifier, **opts)
      id = Jamf::Script.valid_id identifier, api: @api
      raise Jamf::NoSuchItemError, "No script matches '#{identifier}'" unless id

      script_data = @scripts.select { |s| s[:id] == id }[0]
      raise Jamf::InvalidDataError, "Script #{id} is not configured. Use add_script method." unless script_data

      opts.each do |parameter, value|
        script_data[parameter] = value if SCRIPT_PARAMETERS_AVAILABLE.include? parameter
      end

      @need_to_update = true
      @scripts
    end # end set_script_parameter

    ###### Directory Bindings

    # @return [Array] the id's of the directory_bindings handled by the policy
    def directory_binding_ids
      @directory_bindings.map { |p| p[:id] }
    end

    # @return [Array] the names of the directory_bindings handled by the policy
    def directory_binding_names
      @directory_bindings.map { |p| p[:name] }
    end

    # Add a Directory Bidning to the list of directory_bindings handled by this policy.
    # If the directory binding already exists in the policy, nil is returned and
    # no changes are made.
    #
    # @param [String,Integer] identifier the name or id of the directory binding to add to this policy
    #
    # @param position [Symbol, Integer] where to add this directory binding among the list of
    #   directory_bindings. Zero-based, :start and 0 are the same, as are :end and -1.
    #   Defaults to :end
    #
    # @return [Array, nil]  the new @directory_bindings array, nil if directory_binding was already in the policy
    #
    def add_directory_binding(identifier, **opts)
      id = validate_directory_binding_opts identifier, opts

      return nil if @directory_bindings.map { |s| s[:id] }.include? id

      name = Jamf::DirectoryBinding.map_all_ids_to(:name, api: @api)[id]

      directory_binding_data = {
        id: id,
        name: name
      }

      @directory_bindings.insert opts[:position], directory_binding_data

      @need_to_update = true
      @directory_bindings
    end


    # Remove a directory binding from this policy by name or id
    #
    # @param identifier [String,Integer] the name or id of the directory binding to remove
    #
    # @return [Array, nil] the new directory bindings array or nil if no change
    #
    def remove_directory_binding(identifier)
      removed = @directory_bindings.delete_if { |s| s[:id] == identifier || s[:name] == identifier }
      @need_to_update = true if removed
      removed
    end

    ###### Dock items

    # @return [Array] the id's of the dock_items handled by the policy
    def dock_item_ids
      @dock_items.map { |p| p[:id] }
    end

    # @return [Array] the names of the dock_items handled by the policy
    def dock_item_names
      @dock_items.map { |p| p[:name] }
    end


    ###### Printers

    # Add a specific printer object to the policy.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String,Integer] The name or the id of the printer to be added to this policy.
    #
    # @param position [Symbol, Integer] where to add this printer object among the list of printer
    #   objects. Zero-based, :start and 0 are the same, as are :end and -1.
    #   Defaults to :end
    #
    # @param action [Symbol] One of the PRINTER_ACTIONS symbols. What you want done with the printer object upon policy execution.
    #
    # @param make_default [TrueClass,FalseClass] Should this printer object be set to default.
    #   Defaults to false
    #
    # @return [String] The new printers array or nil if the printer was already in the policy
    def add_printer(identifier, **opts)
      id = validate_printer_opts identifier, opts

      return nil if @printers.map { |p| p[:id] }.include? id

      name = Jamf::Printer.map_all_ids_to(:name, api: @api)[id]

      printer_data = {
        id: id,
        name: name,
        action: PRINTER_ACTIONS[opts[:action]],
        make_default: opts[:make_default]
      }

      @printers.insert opts[:position], printer_data

      @need_to_update = true
      @printers
    end


    # Remove a specific printer object from the policy.
    #
    # @author Tyler Morgan
    #
    # @param identifier [String,Integer] The name or id of the printer to be removed.
    #
    # @return [Array, nil] The new printers array or nil if no change.
    def remove_printer(identifier)
      removed = @printers.delete_if { |p| p[:id] == identifier || p[:name] == identifier }

      @need_to_update = true
      removed
    end

    # Add a dock item to the policy
    def add_dock_item(identifier, action)
      id = Jamf::DockItem.valid_id identifier, api: @api

      raise Jamf::NoSuchItemError, "No Dock Item matches '#{identifier}'" unless id

      raise Jamf::InvalidDataError, "Action must be one of: :#{DOCK_ITEM_ACTIONS.keys.join ', :'}" unless DOCK_ITEM_ACTIONS.include? action

      return nil if @dock_items.map { |d| d[:id] }.include? id

      name = Jamf::DockItem.map_all_ids_to(:name, api: @api)[id]

      @dock_items << {id: id, name: name, action: DOCK_ITEM_ACTIONS[action]}

      @need_to_update = true
      @dock_items
    end

    # Remove a dock item from the policy
    def remove_dock_item(identifier)
      # TODO: Add validation against Jamf::DockItem
      removed = @dock_items.delete_if { |d| d[:id] == identifier || d[:name] == identifier }
      @need_to_update = true if removed
      removed
    end

    # @return [Array] the id's of the printers handled by the policy
    def printer_ids
        begin
            @printers.map { |p| p[:id] }
            rescue TypeError
            return []
        end
    end

    # @return [Array] the names of the printers handled by the policy
    def printer_names
        begin
            @printers.map { |p| p[:name] }
            rescue TypeError
            return []
        end
    end



    ###### Disk Encryption

    # Sets the Disk Encryption application to "Remediate" and sets the remediation key type to individual.
    #
    # @author Tyler Morgan
    #
    # @return [Void]
    #
    def reissue_key()
      if @disk_encryption[:action] != DISK_ENCRYPTION_ACTIONS[:remediate]
        # Setting New Action
        hash = {
          action: DISK_ENCRYPTION_ACTIONS[:remediate],
          remediate_key_type: "Individual"
        }

        @disk_encryption = hash
        @need_to_update = true

      else
        # Update
        return
      end

    end


    # Sets the Disk Encryption application to "Apply" and sets the correct disk encryption configuration ID using either the name or id.
    #
    # @author Tyler Morgan
    #
    # @return [Void]
    #
    def apply_encryption_configuration(identifier)

      id = Jamf::DiskEncryptionConfiguration.valid_id identifier

      return if id.nil?

      hash = {
        action: DISK_ENCRYPTION_ACTIONS[:apply],
        disk_encryption_configuration_id: id,
        auth_restart: false
      }

      @disk_encryption = hash
      @need_to_update = true
    end


    # Removes the Disk Encryption settings associated with this specific policy.
    #
    # @author Tyler Morgan
    #
    # @return [Void]
    #
    def remove_encryption_configuration()
      hash = {
        action: DISK_ENCRYPTION_ACTIONS[:none]
      }

      @disk_encryption = hash
      @need_to_update = true
    end

    # Interact with management account settings
    #
    # @param action [Key] one of the MGMT_ACCOUNT_ACTIONS keys
    #
    # @return The current specified management settings.
    #
    # Reference: https://developer.jamf.com/documentation#resources-with-passwords
    #
    def set_management_account(action, **opts)
      # TODO: Add proper error handling
      raise Jamf::InvalidDataError, "Action must be one of: :#{MGMT_ACCOUNT_ACTIONS.keys.join ', :'}" unless MGMT_ACCOUNT_ACTIONS.include? action

      management_data = {}

      if action == :change_pw || action == :reset_pw
        raise Jamf::MissingDataError, ":password must be provided when changing management account password" if opts[:password].nil?

        management_data = {
          action: MGMT_ACCOUNT_ACTIONS[action],
          managed_password: opts[:password]
        }
      elsif action == :reset_random || action == :generate_pw
        raise Jamf::MissingDataError, ":password_length must be provided when setting a random password" if opts[:password_length].nil?
        raise Jamf::InvalidDataError, ":password_length must be an Integer" unless opts[:password_length].is_a? Integer

        management_data = {
          action: MGMT_ACCOUNT_ACTIONS[action],
          managed_password_length: opts[:password_length]
        }
      else
        management_data = {
          action: MGMT_ACCOUNT_ACTIONS[action]
        }
      end

      @management_account = management_data

      @need_to_update = true

      @management_account

    end

    # Check if management password matches provided password
    #
    # @param password[String] the password that is SHA256'ed to compare to the one from the API.
    #
    # @return [Boolean] The result of the comparison of the management password and provided text.
    #
    def verify_management_password(password)
      raise Jamf::InvalidDataError, "Management password must be a string." unless password.is_a? String

      raise Jamf::UnsupportedError, "'#{@management_account[:action].to_s}' does not support management passwords." unless @management_account[:action] == MGMT_ACCOUNT_ACTIONS[:change_pw] || @management_account[:action] == MGMT_ACCOUNT_ACTIONS[:reset_pw]

      return Digest::SHA256.hexdigest(password).to_s == @management_account[:managed_password_sha256].to_s
    end

    ###### Actions

    # Try to execute this policy on this machine.
    #
    # @param show_output[Boolean] should the stdout and stderr of the
    #  'jamf policy' command be sent to stdout in realtime?
    #
    # @return [Boolean, nil] The success of the 'jamf policy' command, or nil
    #   if the policy couldn't be executed (out of scope, policy disabled, etc)
    #
    def run(show_output = false)
      return nil unless enabled?
      output = Jamf::Client.run_jamf('policy', "-id #{id}", show_output)
      return nil if output.include? 'No policies were found for the ID'
      $CHILD_STATUS.exitstatus.zero? ? true : false
    end
    alias execute run

    # Flush logs for this policy older than
    # some number of days, weeks, months or years, possibly limited to
    # one or more computers
    #
    # With no parameters, flushes all logs for all computers
    #
    # NOTE: Currently the API doesn't have a way to flush only failed policies.
    #
    # WARNING: Log flushing can take a long time, and the API call doesnt return
    # until its finished. The connection timeout will be temporarily raised to
    # 30 minutes, unless it's already higher.
    #
    # @param older_than[Integer] 0, 1, 2, 3, or 6
    #
    # @param period[Symbol] :days, :weeks, :months, or :years
    #
    # @param computers[Array<Integer,String>] Identifiers of the target computers
    #   either ids, names, SNs, macaddrs, or UDIDs
    #
    # @return [void]
    #
    def flush_logs(older_than: 0, period: :days, computers: [])
      raise Jamf::NoSuchItemError, "Policy doesn't exist in the JSS. Use #create first." unless @in_jss

      Jamf::Policy.flush_logs(
        @id,
        older_than: older_than,
        period: period,
        computers: computers,
        api: @api
      )
    end

    # Private Instance Methods
    #####################################

    private

    # raise an error if a trying to set retry options when
    # frequency is not 'once per comptuer'
    #
    # @return [void]
    #
    def validate_retry_opt
      return if FREQUENCIES[:once_per_computer] == @frequency

      raise Jamf::UnsupportedError, 'Policy retry is only available when frequency is set to :once_per_computer'
    end

    # raise an error if a package being added isn't valid
    #
    # @see #add_package
    #
    # @return [Integer, nil] the valid id for the package
    #
    def validate_package_opts(identifier, opts)
      opts[:position] ||= -1
      opts[:action] ||= :install
      opts[:feu] ||= false
      opts[:fut] ||= false
      opts[:update_autorun] ||= false

      opts[:position] =
        case opts[:position]
        when :start then 0
        when :end then -1
        else Jamf::Validate.integer(opts[:position])
        end

      # if the given position is past the end, set it to -1 (the end)
      opts[:position] = -1 if opts[:position] > @packages.size

      id = Jamf::Package.valid_id identifier, api: @api

      raise Jamf::NoSuchItemError, "No package matches '#{identifier}'" unless id

      raise Jamf::InvalidDataError, "action must be one of: :#{PACKAGE_ACTIONS.keys.join ', :'}" unless \
        PACKAGE_ACTIONS.include? opts[:action]

      opts[:feu] = Jamf::Validate.boolean opts[:feu]
      opts[:fut] = Jamf::Validate.boolean opts[:fut]
      opts[:update_autorun] = Jamf::Validate.boolean opts[:update_autorun]
      id
    end

    # raise an error if a script being added isn't valid
    #
    # @see #add_script
    #
    # @return [Integer, nil] the valid id for the package
    #
    def validate_script_opts(identifier, opts)
      opts[:position] ||= -1
      opts[:priority] ||= :after

      raise Jamf::InvalidDataError, "priority must be one of: :#{SCRIPT_PRIORITIES.keys.join ', :'}" unless \
        SCRIPT_PRIORITIES.include? opts[:priority]

      opts[:position] =
        case opts[:position]
        when :start then 0
        when :end then -1
        else Jamf::Validate.integer(opts[:position])
        end

      # if the given position is past the end, set it to -1 (the end)
      opts[:position] = -1 if opts[:position] > @packages.size

      id = Jamf::Script.valid_id identifier, api: @api
      raise Jamf::NoSuchItemError, "No script matches '#{identifier}'" unless id
      id
    end

    # raise an error if the directory binding being added isn't valid
    #
    # @see #add_directory_binding
    #
    # @return [Integer, nil] the valid id for the package
    #
    def validate_directory_binding_opts(identifier, opts)
      opts[:position] ||= -1

      opts[:position] =
        case opts[:position]
        when :start then 0
        when :end then -1
        else Jamf::Validate.integer(opts[:position])
        end

        # if the given position is past the end, set it to -1 (the end)
        opts[:position] = -1 if opts[:position] > @directory_bindings.size

        id = Jamf::DirectoryBinding.valid_id identifier, api: @api
        raise Jamf::NoSuchItemError, "No directory binding matches '#{identifier}'" unless id
        id
    end

    # Raises an error if the printer being added isn't valid, additionally checks the options and sets defaults where possible.
    #
    # @see #add_printer
    #
    # @return [Integer, nil] the valid id for the package
    #
    def validate_printer_opts(identifier, opts)
      opts[:position] ||= -1

      opts[:position] =
        case opts[:position]
        when :start then 0
        when :end then -1
        else Jamf::Validate.integer(opts[:position])
        end

      # If the given position is past the end, set it to -1 (the end)
      opts[:position] = -1 if opts[:position] > @printers.size

      # Checks if action to be done with the printer object is provided and valid.
      raise Jamf::MissingDataError, "action must be provided, must be one of :#{PRINTER_ACTIONS.keys.join(':,')}." if opts[:action].nil?
      raise Jamf::InvalidDataError, "action must be one of :#{PRINTER_ACTIONS.keys.join(',:')}." unless PRINTER_ACTIONS.keys.include? opts[:action]


      # Checks if the make_default option is valid, and sets the default if needed.
      raise Jamf::InvalidDataError, "make_default must be either true or false." unless opts[:make_default].is_a?(TrueClass) || opts[:make_default].is_a?(FalseClass) || opts[:make_default].nil?

      opts[:make_default] = false if opts[:make_default].nil?

      id = Jamf::Printer.valid_id identifier, api: @api
      raise Jamf::NoSuchItemError, "No printer matches '#{identifier}'" unless id
      id
    end

    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      general = obj.add_element 'general'
      general.add_element('name').text = @name
      general.add_element('enabled').text = @enabled
      general.add_element('frequency').text = @frequency
      general.add_element('retry_event').text = @retry_event
      general.add_element('retry_attempts').text = @retry_attempts.to_s
      general.add_element('notify_on_each_failed_retry').text = @notify_failed_retries.to_s

      general.add_element('target_drive').text = @target_drive
      general.add_element('offline').text = @offline

      add_category_to_xml(doc)

      JSS.hash_to_rexml_array(@trigger_events).each { |t| general << t }

      date_time_limitations = general.add_element 'date_time_limitations'
      exp = @server_side_limitations[:expiration]
      date_time_limitations.add_element('expiration_date_epoch').text = exp.to_jss_epoch if exp
      activation = @server_side_limitations[:activation]
      date_time_limitations.add_element('activation_date_epoch').text = activation.to_jss_epoch if activation

      obj << @scope.scope_xml

      reboot = obj.add_element 'reboot'
      JSS.hash_to_rexml_array(@reboot_options).each { |elem| reboot << elem }

      maint = obj.add_element 'maintenance'
      maint.add_element('recon').text = @recon.to_s
      maint.add_element('reset_name').text = @reset_name.to_s
      maint.add_element('install_all_cached_packages').text = @install_cached_pkgs.to_s
      maint.add_element('permissions').text = @permissions_repair.to_s
      maint.add_element('byhost').text = @fix_byhost.to_s
      maint.add_element('system_cache').text = @flush_system_cache.to_s
      maint.add_element('user_cache').text = @user_cache.to_s
      maint.add_element('verify').text = @verify_startup_disk.to_s

      acct_maint = obj.add_element 'account_maintenance'

      mgmt_acct = acct_maint.add_element 'management_account'
      JSS.hash_to_rexml_array(@management_account).each { |x| mgmt_acct << x }

      directory_bindings = acct_maint.add_element 'directory_bindings'
      @directory_bindings.each do |b|
        directory_binding = directory_bindings.add_element 'binding'
        dbdeets = JSS.hash_to_rexml_array b
        dbdeets.each { |d| directory_binding << d }
      end

      user_interaction = obj.add_element 'user_interaction'
      user_interaction.add_element('message_start').text = @user_message_start.to_s
      user_interaction.add_element('message_finish').text = @user_message_finish.to_s

      files_processes = obj.add_element 'files_processes'
      JSS.hash_to_rexml_array(@files_processes).each { |f| files_processes << f }

      pkg_conf = obj.add_element 'package_configuration'
      pkgs = pkg_conf.add_element 'packages'
      @packages.each do |p|
        pkg = pkgs.add_element 'package'
        pdeets = JSS.hash_to_rexml_array p
        pdeets.each { |d| pkg << d }
      end

      scripts = obj.add_element 'scripts'
      @scripts.each do |s|
        script = scripts.add_element 'script'
        sdeets = JSS.hash_to_rexml_array s
        sdeets.each { |d| script << d }
      end

      disk_encryption = obj.add_element 'disk_encryption'

      @disk_encryption.each do |k,v|
        disk_encryption.add_element(k.to_s).text = v.to_s
      end

      printers = obj.add_element 'printers'
      @printers.each do |pr|
        printer = printers.add_element 'printer'
        pdeets = JSS.hash_to_rexml_array pr
        pdeets.each { |d| printer << d }
      end

      dock_items = obj.add_element 'dock_items'
      @dock_items.each do |d|
        dock_item = dock_items.add_element 'dock_item'
        ddeets = JSS.hash_to_rexml_array d
        ddeets.each { |de| dock_item << de }
      end

      add_self_service_xml doc
      add_site_to_xml doc

      doc.to_s
    end

  end # class policy

end # module
