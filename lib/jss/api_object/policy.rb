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

  ### Module Constants
  ######################

  ### Module Variables
  ######################

  ### Module Methods
  ######################

  ### Classes
  #####################################

  ### A class implementing a JSS Policy.
  ###
  ### Like many API objects, the data comes from the API in sections, and
  ### the items in the :general section are mapped to direct attributes
  ### of this Class.
  ###
  ###
  ### Policy instances are partially read-only:
  ### - Due to limitations in the API implementation of policies, as well as the complexity
  ###   of policy objects, only these attributes can be set and updated via the Policy class:
  ### - - name
  ### - - frequency
  ### - - target_drive
  ### - - offline
  ### - - enabled
  ### - - category
  ### - - triggers
  ### - - scope, see {JSS::Scopable} and {JSS::Scopable::Scope}
  ### - - files and processes
  ### - - packages, see {#add_package} and {#remove_package}
  ### - - scripts see {#add_script} and {#remove_script}
  ### - - self service, see {JSS::SelfServable}
  ###
  ### All other values and sections must be edited via the Web App.
  ###
  ### Policies may be deleted via this class
  ###
  class Policy < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    include JSS::Creatable
    include JSS::Updatable
    include JSS::Scopable
    include JSS::Uploadable
    include JSS::SelfServable
    include JSS::Categorizable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'policies'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :policies

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :policy

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:scope, :user_interaction, :files_processes].freeze

    ### policies can take uploaded icons
    UPLOAD_TYPES = { icon: :policies }.freeze

    ### policies are available in macOS self Serviec
    SELF_SERVICE_TARGET = :macos

    ### policies via self services are still polcies
    SELF_SERVICE_PAYLOAD = :policy

    SECTIONS = [
      :general,
      :maintenance,
      :account_maintenance,
      :scripts,
      :self_service,
      :package_configuration,
      :scope,
      :user_interaction,
      :reboot,
      :files_processes,
      :dock_items,
      :disk_encryption,
      :printers
    ].freeze

    FREQUENCIES = {
      ongoing: 'Ongoing',
      once_per_computer: 'Once per computer',
      once_per_user: 'Once per user',
      daily: 'Once every day',
      weekly: 'Once every week',
      monthly: 'Once every month'
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
      disable_fv2: 'fileVaultDisable'
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

    PRINTER_ACTIIONS = {
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
      day: 'Day',
      days: 'Day',
      week: 'Week',
      weeks: 'Week',
      month: 'Month',
      months: 'Month',
      year: 'Year',
      years: 'Year'
    }.freeze

    ######################
    ### Attributes
    ######################

    ##### General
    ### This data comes from the :general hash in the raw JSON data
    ### and correspond to the general section of the Edit Policy window in
    ### the JSS WebApp. They are general settings for this policy.
    ### We'll map it to direct attributes.

    ### @return [String] how often to run the policy on each computer
    attr_reader :frequency

    ### @return [String] which drive should the policy target
    attr_reader :target_drive

    ### @return [Boolean] should be policy be available offline
    attr_reader :offline

    ### @return [Boolean] is the policy enabled?
    attr_reader :enabled

    ### @return [String] a string with the site name
    attr_reader :site

    ### @return [Hash]
    ###
    ### Overrides for various defaults
    ###
    ### NOTE: There's an API bug in both XML and JSON with the
    ###   :distribution_point and :target_drive values.
    ###   First off, it's not clear what the :target_drive value here
    ###   is overriding, since there's a :target_drive value in the
    ###   main General hash.
    ###   Second off - when you set a non-default dist.point in the
    ###   packages section of the UI, that value shows up in both
    ###   this :target_drive and the general one, but the :distribution_point
    ###   value here stays empty.
    ###
    ### The hash looks like:
    ### :distribution_point => "",
    ### :force_afp_smb => false,
    ### :netboot_server => "current",
    ### :target_drive => "default",
    ### :sus => "default"
    ###
    attr_reader :override_default_settings

    ### The API has a :network_requirements key in the general section, but
    ### in the UI its in a subsection called Client Side Limitiations.
    ### so we'll store it in a hash called client_side_limitations,
    ### defined below.

    ### the network_limitations hash of the general section seems to be redundant.
    ### it contains minimum_network_connection ("Ethernet" or "No Minimum")
    ###    which is also reflected in the general[:network_requirements] ("Ethernet" or "Any")
    ### it contains network_segments, which are also listed
    ###    in the limitations hash of the scope section
    ### it contains any_ip_address, which is true or false based on there being
    ###     any network_segment limitations.
    ### Therefore, we'll ignore it, and use the other places for that data

    ### The API has a general key ":date_time_limitations" which has this
    ### this data:
    ###   :activation - Time
    ###   :expiration - Time
    ###   :no_execute_on - An array of short day names as symbols, e.g. [:sun, :mon, :wed, :thu]
    ###   :no_execute_start - Time
    ###   :no_execute_end - Time
    ### but in the UI, those are set in the Server Side Limitiations and Client Side Limitiations.
    ### areas, so we'll store them in matching hashes below.
    ###     attr_reader :date_time_limitations

    ### @return [Hash]
    ###
    ### The server-side limitations of this policy.
    ###
    ### The keys are :activation and :expiration, both are Times.
    ###
    ### the data comes from the API in the date_time_limitations hash of the general
    ### section, but the UI shows them in the Server Side Limitations area.
    ### This attribute is just for convience and consistency, and just
    ### refers to the data in their API locations
    attr_reader :server_side_limitations

    ### @return [Hash]
    ###
    ### The client-side limitations of this policy.
    ###
    ### The keys are:
    ### - :no_execute_on - An array of short day names as strings, e.g. ["Sun", "Mon", "Tue"]
    ### - :no_execute_start - Time
    ### - :no_execute_end - Time
    ### - :network_connection - String
    ### The data for the first three comes from the API in the date_time_limitations
    ### hash of the general section.
    ### The fourth comes from the network_requirements of the general section of the API,
    ### but the UI shows them in the Client Side Limitations area.
    ###
    ### This attribute is just for convience and consistency, and just
    ### refers to the data in their API locations
    attr_reader :client_side_limitations

    ### @return [String]
    ###
    ### Either EVENT or USER_INITIATED
    ###
    ### If it's EVENT, then one or more of the members @trigger_events must true.
    attr_reader :trigger

    ### @return [Hash]
    ###
    ### The triggers that cause this policy to execute on a client when the @trigger is "EVENT"
    ###
    ### This is a hash with the following keys. Each comes from the API
    ### as a key in the :general hash, but they make more sense separated out
    ### like this.
    ### - :trigger_startup  => Bool
    ### - :trigger_login  => Bool
    ### - :trigger_logout  => Bool
    ### - :trigger_checkin  => Bool
    ### - :trigger_network_state_changed  => Bool
    ### - :trigger_enrollment_complete  => Bool
    ### - :trigger_other => the String that causes a custom trigger
    ###
    ### To edit a value, call
    ###   set_trigger_event(type, new_val)
    ### where type is one of the keys in TRIGGER_EVENTS and new val is the new value (usually boolean)
    ###
    attr_reader :trigger_events

    ###### client machine maintenence
    ### These are the computer maint. tasks
    ### that might be performed by this policy
    ### All are boolean
    ### TODO: make individial getters/setters as for @files_processes

    ### @return [Boolean] client maintenance task
    attr_reader :verify_startup_disk

    ### @return [Boolean] client maintenance task
    attr_reader :permissions_repair

    ### @return [Boolean] client maintenance task
    attr_reader :recon

    ### @return [Boolean] client maintenance task
    attr_reader :fix_byhost

    ### @return [Boolean] client maintenance task
    attr_reader :reset_name

    ### @return [Boolean] client maintenance task
    attr_reader :flush_system_cache

    ### @return [Boolean] client maintenance task
    attr_reader :install_cached_pkgs

    ### @return [Boolean] client maintenance task
    attr_reader :flush_user_cache

    ### @return [Array<Hash>]
    ###
    ### The directory bindings applied
    ###
    ### each hash is like: !{:name => "LDAP", :id => 4}
    ### TODO: handle as for packages & scripts
    attr_reader :directory_bindings

    ### @return [Hash] the open firmware mode and password
    attr_reader :open_firmware_efi_password

    ### @return [Hash]
    ###
    ### The management accout changes applied by the policy
    ###
    ### The keys are:
    ### - :action see MGMT_ACCOUNT_ACTIONS
    ### - :managed_password
    ### - :managed_password_md5
    ### - :managed_password_sha256
    ### - :managed_password_length  # for random generating pws
    ###
    ### TODO: make individial getters/setters as for @files_processes
    attr_reader :management_account

    ### @return [Array<Hash>]
    ###
    ### Local accts acted-upon by this policy
    ###
    ### Keys are:
    ### - :action => "Create",
    ### - :hint => "foo  bar",
    ### - :picture => "/path/to/pic.tif",
    ### - :admin => true,
    ### - :home => "/Users/chrisltest",
    ### - :realname => "ChrisTest Lasell",
    ### - :filevault_enabled => true,
    ### - :username => "chrisltest",
    ### - :password_md5 => "3858f62230ac3c915f300c664312c63f",
    ### - :password => "foobar",
    ### - :password_sha256=> "c3ab8ff13720e8ad9047dd39466b3c8974e592c2fa383d4a3960714caef0c4f2"
    ###
    ### TODO: make individial getters/setters as for @files_processes
    attr_reader :accounts

    ### @return [Array<Hash>]
    ###
    ### The pkgs handled by this policy
    ###
    ### Hash keys are:
    ### - :action => "Install"
    ### - :update_autorun => false,
    ### - :feu => false,
    ### - :name => "rbgem-json-1.6.5-4.pkg",
    ### - :id => 1073
    ###
    attr_reader :packages

    ### @return [Array<Hash>]
    ###
    ### The scripts run by this policy
    ###
    ### Hash keys are:
    ### - :name => "chromegetter.sh",
    ### - :parameter4 => "",
    ### - :parameter5 => "",
    ### - :parameter6 => "",
    ### - :parameter7 => "",
    ### - :parameter8 => "",
    ### - :parameter9 => "",
    ### - :parameter10 => "",
    ### - :parameter11 => "",
    ### - :id => 1428,
    ### - :priority => "After"
    ###
    attr_reader :scripts

    ###### user interaction
    ### These are extracted from the :user_interaction hash
    ### in the JSON output, which looks like this:
    ###   :message_start => "",
    ###   :allow_users_to_defer => false,
    ###   :allow_deferral_until_utc => "",
    ###   :message_finish => ""
    ###
    ### TODO: make individial getters/setters as for @files_processes

    ### @return [Boolean] can the user defer the policy?
    attr_reader :user_may_defer

    ### @return [Time] when is the user no longer allowed to defer?
    attr_reader :user_may_defer_until

    ### @return [String] the message shown the user at policy start
    attr_reader :user_message_start

    ### @return [String] the message shown the user at policy end
    attr_reader :user_message_finish

    ### @return [Hash]
    ###
    ### Reboot options for the policy
    ###
    ### The hash keys are:
    ### - :user_logged_in => "Do not restart",
    ### - :minutes_until_reboot => 5,
    ### - :message=> "This computer will restart in 5 minutes. yaddayadda.",
    ### - :startup_disk => "Current Startup Disk",
    ### - :specify_startup => "",
    ### - :no_user_logged_in => "Do not restart"
    ### - :file_vault_2_reboot => false
    ###
    ### TODO: make individial getters/setters as for @files_processes
    attr_reader :reboot_options

    ##### files & processes
    ### a hash like this:
    ### {:spotlight_search => "Spotlight This",
    ###  :search_for_process => "SafariProcess",
    ###  :search_by_path => "/this/is/a/path",
    ###  :kill_process => true,
    ###  :delete_file => true,
    ###  :run_command => "/usr/local/pixar/sbin/force-fde-logout  --setup",
    ###  :locate_file => "this-is-a-filename",
    ###  :update_locate_database => true}
    ###
    ### NOTE, since these items are editable, they have custom getters/setters
    ### so that the hash isn't directly changable without @need_to_update.
    ### attr_reader :files_processes

    ### @return [Array<Hash>]
    ###
    ### The dock items handled by this policy
    ###
    ### each item hash looks like: !{:name => "Mail", :id => 14, :action => "Add To Beginning"}
    attr_reader :dock_items

    ### @return [Hash]
    ###
    ### Disk encryption options for this policy
    ###
    ### The hash looks like !{:disk_encryption_configuration_id => 3, :action => "apply"}
    attr_reader :disk_encryption

    ### @return [Array<Hash>]
    ###
    ### The printers handled by this policy
    ###
    ### Each Hash looks like: !{:make_default => false, :name => "torlan", :id => 3, :action => "install"}
    attr_reader :printers

    #####################################
    ### Public Instance Methods
    #####################################

    ### @see APIObject#initialize
    ###
    def initialize(args = {})
      super

      if @in_jss
        gen = @init_data[:general]
        @frequency = gen[:frequency]
        @target_drive = gen[:target_drive]
        @offline = gen[:offline]
        @enabled = gen[:enabled]
        @site = JSS::APIObject.get_name(gen[:site][:name])
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

        ### Not in jss yet
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

      @scope ||= JSS::Scopable::Scope.new(:computers, all_computers: false)
    end # init

    ###### General

    ### Change the enabled state of this item
    ###
    ### @param new_val[Boolean]  the new state.
    ###
    ### @return [void]
    ###
    def enabled=(new_val)
      return nil if @enabled == new_val
      raise JSS::InvalidDataError, 'New value must be true or false' unless JSS::TRUE_FALSE.include? new_val
      @enabled = new_val
      @need_to_update = true
    end

    ### Shortcut for enabled = true
    def enable
      self.enabled = true
    end

    ### Shortcut for endabled = false
    def disable
      self.enabled = false
    end

    ### Set a new frequency for this policy.
    ###
    ### @param freq[Symbol] the desired frequency, must be one of the keys of {FREQUENCIES}
    ###
    ### @return [void]
    ###
    def frequency=(freq)
      raise JSS::InvalidDataError, "New frequency must be one of :#{FREQUENCIES.keys.join ', :'}" unless FREQUENCIES.keys.include? freq
      @frequency = FREQUENCIES[freq]
      @need_to_update = true
    end

    ### Set a new target drive for this policy.
    ###
    ### @param path_to_drive[String,Pathname] the full path to the target drive, must start with a '/'
    ###
    ### @return [void]
    ###
    def target_drive=(path_to_drive)
      raise JSS::InvalidDataError, 'Path to target drive must be absolute' unless path_to_drive.to_s.start_with? '/'
      @target_drive = path_to_drive.to_s
      @need_to_update = true
    end

    ### Set whether this policy is available offline.
    ###
    ### @param new_val[Boolean]
    ###
    ### @return [void]
    ###
    def offline=(new_val)
      raise JSS::InvalidDataError, 'New value must be boolean true or false' unless JSS::TRUE_FALSE.include? new_val
      @offline = new_val
      @need_to_update = true
    end

    ### Change a trigger event
    ###
    ### @param type[Symbol] the type of trigger, one of the keys of {TRIGGER_EVENTS}
    ###
    ### @param new_val[Boolean] whether the type of trigger is active or not.
    ###
    ### @return [void]
    ###
    def set_trigger_event(type, new_val)
      raise JSS::InvalidDataError, "Trigger type must be one of #{TRIGGER_EVENTS.keys.join(', ')}" unless TRIGGER_EVENTS.keys.include? type
      if type == :custom
        raise JSS::InvalidDataError, 'Custom triggers must be Strings' unless new_val.is_a? String
      else
        raise JSS::InvalidDataError, 'Non-custom triggers must be true or false' unless JSS::TRUE_FALSE.include? new_val
      end
      @trigger_events[TRIGGER_EVENTS[type]] = new_val
      @need_to_update = true
    end

    ###### Files & Processes

    ### @return [String] The unix shell command to run on ths client.
    ###
    def run_command
      @files_processes[:run_command]
    end

    ### Set the unix shell command to be run on the client
    ###
    ### @param command[String] the unix shell command to be run on the client
    ###
    ### @return [void]
    ###
    def run_command=(command)
      raise JSS::InvalidDataError, 'Command to run must be a String' unless command.is_a? String
      @files_processes[:run_command] = command
      @need_to_update = true
    end

    ### @return [Boolean] Should we update the database used by the locate command?
    ###
    def update_locate_database?
      @files_processes[:update_locate_database]
    end

    ### Set whether or not to update the database used by the locate command.
    ###
    ### @param tf[Boolean] whether or not to update the database used by the locate command.
    ###
    ### @return [void]
    ###
    def update_locate_database=(tf)
      @files_processes[:update_locate_database] = tf ? true : false
      @need_to_update = true
    end

    ### @return [String] The process name to search for on the client
    ###
    def search_for_process
      @files_processes[:search_for_process]
    end

    ### @return [Boolean] Should the searched-for process be killed if found.
    ###
    def kill_process?
      @files_processes[:kill_process]
    end

    ### Set the process name to search for, and if it should be killed if found.
    ###
    ### Setter methods (which end with =) can't easily take
    ### multiple arguments, so we instead name them "set_blah_blah"
    ### rather than "blah_blah="
    ###
    ### @param process[String] the process name to search for
    ###
    ### @param kill[Boolean] should be process be killed if found
    ###
    ### @return [void]
    ###
    def set_search_for_process(process, kill = false)
      @files_processes[:search_for_process] = process.to_s
      @files_processes[:kill_process] = kill ? true : false
      @need_to_update = true
    end

    ### @return [Pathname] The path to search for
    ###
    def search_by_path
      Pathname.new @files_processes[:search_by_path]
    end

    ### @return [Boolean] Should the searched-for path be deleted if found?
    ###
    def delete_file?
      @files_processes[:delete_file]
    end

    ### Set the path to search for, a String or Pathname, and whether or not to delete it if found.
    ###
    ### Setter methods (which end with =) can't easily take
    ### multiple arguments, so we instead name them "set_blah_blah"
    ### rather than "blah_blah="
    ###
    ### @param path[String,Pathname] the path to search for
    ###
    ### @param delete[Boolean] should the path be deleted if found
    ###
    ### @return [void]
    ###
    def set_search_by_path(path, delete = false)
      raise JSS::InvalidDataError, 'Path to search for must be a String or a Pathname' unless path.is_a?(String) || path.is_a?(Pathname)
      @files_processes[:search_by_path] = path.to_s
      @files_processes[:delete_file] = delete ? true : false
      @need_to_update = true
    end

    ### @return [String] The term to search for using spotlight
    ###
    def spotlight_search
      @files_processes[:spotlight_search]
    end

    ### Set the term to seach for using spotlight
    ###
    ### @param term[String] the term to seach for using spotlight
    ###
    ### @return [void]
    ###
    def spotlight_search=(term)
      raise JSS::InvalidDataError, 'Spotlight search term must be a String' unless term.is_a? String
      @files_processes[:spotlight_search] = term
      @need_to_update = true
    end

    ### @return [String] The term to seach for using the locate command
    ###
    def locate_file
      @files_processes[:locate_file]
    end

    ### Set the term to seach for using the locate command
    ###
    ### @param term[String] the term to seach for using the locate command
    ###
    ### @return [void]
    ###
    def locate_file=(term)
      raise JSS::InvalidDataError, 'Term to locate must be a String' unless term.is_a? String
      @files_processes[:locate_file] = term
      @need_to_update = true
    end

    ###### Client maintenance

    ### Set the

    ###### Packages

    ### @return [Array] the id's of the packages handled by the policy
    def package_ids
      @packages.map { |p| p[:id] }
    end

    ### @return [Array] the names of the packages handled by the policy
    def package_names
      @packages.map { |p| p[:name] }
    end

    ### Add a package to the list of pkgs handled by this policy.
    ### If the pkg already exists in the policy, nil is returned and
    ### no changes are made.
    ###
    ### @param [String,Integer] identifier the name or id of the package to add to this policy
    ###
    ### @param [Hash] opts the options for this pkg
    ###
    ### @option [Symbol, Integer] position: :end where to add this pkg among the list of
    ###   pkgs. Zero-based, :start and 0 are the same, as are :end and -1. Defaults to :end
    ###
    ### @option [String] action: 'Install' One of the values of PACKAGE_ACTIONS
    ###
    ### @option [Boolean] feu: false Overrides the setting for the pkg itself
    ###
    ### @option [Boolean] fut: false Overrides the setting for the pkg itself
    ###
    ### @option [Boolean] update_autorun: false
    ###
    ### @return [Array, nil]  the new @packages array, nil if pkg was already in the policy
    ###
    def add_package(identifier, opts = {})
      opts[:position] ||= -1
      opts[:action] ||= :install
      opts[:feu] = false if opts[:feu].nil?
      opts[:fut] = false if opts[:fut].nil?
      opts[:update_autorun] = false if opts[:update_autorun].nil?

      id = JSS::Package.valid_id identifier
      raise JSS::NoSuchItemError, "No package matches '#{identifier}'" unless id

      return nil if @packages.map { |p| p[:id] }.include? id

      name = JSS::Package.map_all_ids_to(:name)[id]

      position = case opts[:position]
                 when :start then 0
                 when :end then -1
                 else opts[:position]
                 end

      raise JSS::InvalidDataError, "action must be one of: :#{PACKAGE_ACTIONS.keys.join ', :'}" unless \
        PACKAGE_ACTIONS.include? opts[:action]
      raise JSS::InvalidDataError, 'feu must be true or false' unless \
        JSS::TRUE_FALSE.include? opts[:feu]
      raise JSS::InvalidDataError, 'fut must be true or false' unless \
        JSS::TRUE_FALSE.include? opts[:fut]
      raise JSS::InvalidDataError, 'update_autorun must be true or false' unless \
        JSS::TRUE_FALSE.include? opts[:update_autorun]

      pkg_data = {
        id: id,
        name: name,
        action: PACKAGE_ACTIONS[opts[:action]],
        feu: opts[:feu],
        fut: opts[:feu],
        update_autorun: opts[:update_autorun]
      }

      @packages.insert position, pkg_data

      ### if the user gave a large number for position, it created nil entries in the array, they need
      ### to be removed.
      @packages.compact!

      @need_to_update = true
      @packages
    end

    ### Remove a package from this policy by name or id
    ###
    ### @param identfier [String,Integer] the name or id of the package to remove
    ###
    ### @return [Array, nil] the new packages array or nil if no change
    ###
    def remove_package(identifier)
      removed = @packages.delete_if { |p| p[:id] == identifier || p[:name] == identifier }
      @need_to_update = true if removed
      removed
    end

    ###### Scripts

    ### @return [Array] the id's of the scripts handled by the policy
    def script_ids
      @scripts.map { |p| p[:id] }
    end

    ### @return [Array] the names of the scripts handled by the policy
    def script_names
      @scripts.map { |p| p[:name] }
    end

    ### Add a script to the list of SCRIPT_PRIORITIESipts run by this policy.
    ### If the script already exists in the policy, nil is returned and
    ### no changes are made.
    ###
    ### @param [String,Integer] identifier the name or id of the script to add to this policy
    ###
    ### @param [Hash] opts the options for this script
    ###
    ### @option [Symbol, Integer] position: where to add this script among the list of
    ###   scripts. Zero-based, :start and 0 are the same, as are :end and -1. Defaults to :end
    ###
    ### @option [Symbol] priority: either :before or :after
    ###
    ### @option [String] parameter4: the value of the 4th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter5: the value of the 5th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter6: the value of the 6th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter7: the value of the 7th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter8: the value of the 8th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter9: the value of the 9th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter10: the value of the 10th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @option [String] parameter11: the value of the 11th parameter passed to the script. this
    ###   overrides the same parameter in the script object itself.
    ###
    ### @return [Array, nil]  the new @scripts array, nil if script was already in the policy
    ###
    def add_script(identifier, opts = {})
      opts[:position] ||= -1
      opts[:priority] ||= :after

      raise JSS::NoSuchItemError, "No script matches '#{identifier}'" unless (id = JSS::Script.valid_id(identifier))

      return nil if @scripts.map { |s| s[:id] }.include? id

      name = JSS::Script.map_all_ids_to(:name)[id]

      position = case opts[:position]
                 when :start then 0
                 when :end then -1
                 else opts[:position]
                 end

      raise JSS::InvalidDataError, "priority must be one of: :#{SCRIPT_PRIORITIES.keys.join ', :'}" unless \
        SCRIPT_PRIORITIES.include? opts[:priority]

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

      @scripts.insert position, script_data

      ### if the user gave a large number for position, it created nil entries in the array, they need
      ### to be removed.
      @scripts.compact!

      @need_to_update = true
      @scripts
    end

    ### Remove a script from this policy by name or id
    ###
    ### @param identfier [String,Integer] the name or id of the script to remove
    ###
    ### @return [Array, nil] the new scripts array or nil if no change
    ###
    def remove_script(identifier)
      removed = @scripts.delete_if { |s| s[:id] == identifier || s[:name] == identifier }
      @need_to_update = true if removed
      removed
    end

    ###### Directory Bindings

    ### @return [Array] the id's of the directory_bindings handled by the policy
    def directory_binding_ids
      @directory_bindings.map { |p| p[:id] }
    end

    ### @return [Array] the names of the directory_bindings handled by the policy
    def directory_binding_names
      @directory_bindings.map { |p| p[:name] }
    end

    ###### Dock items

    ### @return [Array] the id's of the dock_items handled by the policy
    def dock_item_ids
      @dock_items.map { |p| p[:id] }
    end

    ### @return [Array] the names of the dock_items handled by the policy
    def dock_item_names
      @dock_items.map { |p| p[:name] }
    end

    ###### Printers

    ### @return [Array] the id's of the printers handled by the policy
    def printer_ids
      @printers.map { |p| p[:id] }
    end

    ### @return [Array] the names of the printers handled by the policy
    def printer_names
      @printers.map { |p| p[:name] }
    end

    ###### Actions

    ### Try to execute this policy on this machine.
    ###
    ### @param show_output[Boolean] should the stdout and stderr of the
    ###  'jamf policy' command be sent to stdout in realtime?
    ###
    ### @return [Boolean, nil] The success of the 'jamf policy' command, or nil
    ###   if the policy couldn't be executed (out of scope, policy disabled, etc)
    ###
    def run(show_output = false)
      return nil unless enabled?
      output = JSS::Client.run_jamf('policy', "-id #{id}", show_output)
      return nil if output.include? 'No policies were found for the ID'
      $CHILD_STATUS.exitstatus.zero? ? true : false
    end

    # Flush all policy logs for this policy older than
    # some number of days, weeks, months or years.
    #
    # With no parameters, flushes all logs
    #
    # NOTE: Currently the API doesn't have a way to
    # flush only failed policies.
    #
    # @param older_than[Integer] 0, 1, 2, 3, or 6
    #
    # @param period[Symbol] :days, :weeks, :months, or :years
    #
    # @return [void]
    #
    def flush_logs(older_than: 0, period: :days)
      raise JSS::NoSuchItemError, "Policy doesn't exist in the JSS. Use #create first." \
        unless @in_jss
      raise JSS::InvalidDataError, "older_than must be one of: #{LOG_FLUSH_INTERVAL_INTEGERS.keys.join ', '}" \
        unless LOG_FLUSH_INTERVAL_INTEGERS.keys.include? older_than
      raise JSS::InvalidDataError, "period must be one of: :#{LOG_FLUSH_INTERVAL_PERIODS.keys.join ', :'}" \
        unless LOG_FLUSH_INTERVAL_PERIODS.keys.include? period

      interval = "#{LOG_FLUSH_INTERVAL_INTEGERS[older_than]}+#{LOG_FLUSH_INTERVAL_PERIODS[period]}"

      JSS::API.delete_rsrc "#{LOG_FLUSH_RSRC}/policy/id/#{@id}/interval/#{interval}"
    end

    ###### Aliases

    alias enabled? enabled
    alias pkgs packages
    alias command_to_run run_command
    alias delete_path? delete_file?
    alias execute run

    ### Private Instance Methods
    #####################################
    private

    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      general = obj.add_element 'general'
      general.add_element('name').text = @name
      general.add_element('enabled').text = @enabled
      general.add_element('frequency').text = @frequency
      general.add_element('target_drive').text = @target_drive
      general.add_element('offline').text = @offline

      add_category_to_xml(doc)

      JSS.hash_to_rexml_array(@trigger_events).each { |t| general << t }

      obj << @scope.scope_xml

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

      add_self_service_xml doc

      doc.to_s
    end

  end # class policy

end # module
