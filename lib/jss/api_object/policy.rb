module JSS

  ######################
  ### Module Constants
  ######################


  ######################
  ### Module Variables
  ######################

  ######################
  ### Module Methods
  ######################


  #####################################
  ### Classes
  #####################################

  ###
  ### A class implementing a JSS Policy.
  ###
  ### Like many API objects, the data comes from the API in sections, and
  ### the items in the :general section are mapped to direct attributes
  ### of this Class.
  ###
  ###
  ### Policy instances are partially read-only:
  ### - New policies cannot be created via this class, please use the WebApp.
  ### - Only a few attributes can be changed and updated via the Policy class:
  ### - - name
  ### - - frequency
  ### - - target_drive
  ### - - offline
  ### - - enabled
  ### - - category
  ### - - triggers
  ### - - scope, see {JSS::Scopable} and {JSS::Scopable::Scope}
  ### - - files and processes
  ### All other values and sections must be edited via the Web App.
  ###
  ### Policies may be deleted via this class
  ###
  ### @see JSS::APIObject
  ###
  class Policy < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    include JSS::Updatable
    include JSS::Scopable
    include JSS::Uploadable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################


    ### The base for REST resources of this class
    RSRC_BASE = "policies"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :policies

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :policy

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:scope, :user_interaction, :files_processes ]


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
    ]

    FREQUENCIES = {
      :ongoing => "Ongoing",
      :once_per_computer => "Once per computer",
      :once_per_user =>"Once per user",
      :daily => "Once every day",
      :weekly => "Once every week",
      :monthly => "Once every month"
    }

    RESTART_WHEN = {
      :if_pkg_requires => "Restart if a package or update requires it",
      :now => "Restart immediately",
      :delayed => "Restart",
      :dont => "Do not restart"
    }

    RESTART_DISKS = {
      :current => "Current Startup Disk",
      :selected => "Currently Selected Startup Disk (No Bless)",
      :netboot => "NetBoot",
      :os_installer => "inPlaceOSUpgradeDirectory"
    } # Note: any other value in :specify_startup is a path to some other drive to boot from, e.g. /Volumes/Foo

    ACCOUNT_ACTIONS = {
      :create => "Create",
      :change_pw => "Reset",
      :delete => "Delete",
      :disable_fv2 => "DisableFileVault"
    }

    MGMT_ACCOUNT_ACTIONS = {
      :no_change => "doNotChange",
      :change_pw => "specified",
      :generate_pw => "random",
      :enable_fv2 => "fileVaultEnable",
      :disable_fv2 => "fileVaultDisable"
    }

    PACKAGE_ACTIONS = {
      :install => "Install",
      :remove => "Uninstall",
      :cache =>"Cache",
      :install_cache => "Install Cached"
    }

    SCRIPT_PRIORITIES = {:pre => "Before", :post => "After"}

    PRINTER_ACTIIONS = {:map => "install", :unmap => "uninstall"}

    DOCK_ITEM_ACTIONS = {:add_start => "Add To Beginning", :add_end => "Add To End", :remove => "Remove"}

    NETWORK_REQUIREMENTS = {:any => "Any", :ethernet => "EtherNet"}

    TRIGGER_EVENTS = {
       :startup => :trigger_startup,
       :login => :trigger_login,
       :logout => :trigger_logout,
       :checkin => :trigger_checkin,
       :network_state => :trigger_network_state_changed ,
       :enrollment => :trigger_enrollment_complete ,
       :custom => :trigger_other
      }

    TRIGGER_TYPES = {:event => "EVENT", :user => "USER_INITIATED"}

    SCOPE_TARGET_KEY = :computers

    ######################
    ### Attributes
    ######################

    ##### General
    ### This data comes from the :general hash in the raw JSON data
    ### and correspond to the general section of the Edit Policy window in
    ### the JSS WebApp. They are general settings for this policy.
    ### We'll map it to direct attributes.

    ### @return [String] policy category name
    attr_reader :category

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
    ### The hash looks like: !{ :distribution_point => "", :force_afp_smb => false, :netboot_server => "current", :target_drive => "default", :sus => "default"}
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

    ##### client machine maintenence
    ### These are the computer maint. tasks
    ### that might be performed by this policy
    ### All are boolean

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

    ### attr_reader :heal # deprecated
    ### attr_reader :prebinding # deprecated

    ##### client account maint
    ### acct related maintenence performed by this policy

    ### @return [Array<Hash>]
    ###
    ### The directory bindings applied
    ###
    ### each hash is like: !{:name => "LDAP", :id => 4}
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
    ### - : password => "foobar",
    ### - :password_sha256=> "c3ab8ff13720e8ad9047dd39466b3c8974e592c2fa383d4a3960714caef0c4f2"
    ###
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


    ### @return [Hash]
    ###
    ### Self-service-related data for this policy
    ###
    ### The hash keys are:
    ### - :self_service_icon => !{:uri => String,:id => Integer, :filename => String}
    ### - :use_for_self_service => true,
    ### - :install_button_text => "Install",
    ### - :self_service_description => "Descriptive text",
    ### - :force_users_to_view_description => false
    ###
    ### Note: we'll add a ruby-std convenience method below "self_service?"
    ###   which returns the :use_for_self_service key.
    attr_reader :self_service

    #### user interaction
    ### These are extracted from the :user_interaction hash
    ### in the JSON output, which looks like this:
    ###   :message_start => "",
    ###   :allow_users_to_defer => false,
    ###   :allow_deferral_until_utc => "",
    ###   :message_finish => ""
    ###

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
    ### - :message=> "This computer will restart in 5 minutes. Please save anything you are working on and log out by choosing Log Out from the bottom of the Apple menu.",
    ### - :startup_disk => "Current Startup Disk",
    ### - :specify_startup => "",
    ### - :no_user_logged_in => "Do not restart"
    ###
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

    ###
    ### @see APIObject#initialize
    ###
    def initialize(args = {})

      super


      gen =  @init_data[:general]
      @category = JSS::APIObject.get_name(gen[:category])
      @frequency = gen[:frequency]
      @target_drive = gen[:target_drive]
      @offline = gen[:offline]
      @enabled = gen[:enabled]
      @site = JSS::APIObject.get_name(gen[:site][:name])
      @override_default_settings = gen[:override_default_settings]
      @trigger = gen[:trigger ]
      @trigger_events = {
       :trigger_startup => gen[:trigger_startup ],
       :trigger_login => gen[:trigger_login ],
       :trigger_logout => gen[:trigger_logout ],
       :trigger_checkin => gen[:trigger_checkin ],
       :trigger_network_state_changed => gen[:trigger_network_state_changed ],
       :trigger_enrollment_complete => gen[:trigger_enrollment_complete ],
       :trigger_other => gen[:trigger_other ]
      }

      dtl = gen[:date_time_limitations]

      @server_side_limitations = {
        :activation => JSS.epoch_to_time(dtl[:activation_date_epoch]),
        :expiration => JSS.epoch_to_time(dtl[:expiration_date_epoch])
      }

      @client_side_limitations = {
        :no_execute_on => dtl[:no_execute_on], # NOTE- there's a bug in the JSON output, it's been reported to JAMF.
        :no_execute_start => dtl[:no_execute_start], # String like "1:01 AM"
        :no_execute_end => dtl[:no_execute_end], # String like "2:02 PM"
        :network_requirements => gen[:network_requirements]
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

      @self_service = @init_data[:self_service]

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

      parse_scope

    end  # init

    ###
    ### Change the enabled state of this item
    ###
    ### @param new_val[Boolean]  the new state.
    ###
    ### @return [void]
    ###
    def enabled= (new_val)
      return nil if @enabled == new_val
      raise JSS::InvalidDataError, "New value must be true or false" unless JSS::TRUE_FALSE.include? new_val
      @enabled = new_val
      @need_to_update = true
    end

    ###
    ### Set a new frequency for this policy.
    ###
    ### @param freq[Symbol] the desired frequency, must be one of the keys of {FREQUENCIES}
    ###
    ### @return [void]
    ###
    def frequency= (freq)
      raise JSS::InvalidDataError, "New frequency must be one of :#{FREQUENCIES.keys.join ", :"}" unless FREQUENCIES.keys.include? freq
      @frequency = FREQUENCIES[freq]
      @need_to_update = true
    end

    ###
    ### Set a new target drive for this policy.
    ###
    ### @param path_to_drive[String,Pathname] the full path to the target drive, must start with a '/'
    ###
    ### @return [void]
    ###
    def target_drive= (path_to_drive)
      raise JSS::InvalidDataError, "Path to target drive must be absolute" unless path_to_drive.to_s.start_with? '/'
      @target_drive = path_to_drive.to_s
      @need_to_update = true
    end

    ###
    ### Set whether this policy is available offline.
    ###
    ### @param new_val[Boolean]
    ###
    ### @return [void]
    ###
    def offline= (new_val)
      raise JSS::InvalidDataError, "New value must be boolean true or false" unless JSS::TRUE_FALSE.include? new_val
      @offline = new_val
      @need_to_update = true
    end

    ###
    ### Change the category of this item, arg is a category name
    ###
    ### @param new_val[String] the name of the new category
    ###
    ### @return [void]
    ###
    def category= (new_val = JSS::Category::DEFAULT_CATEGORY)
      return nil if @category == new_val
      new_val = nil if new_val == ''
      new_val ||= JSS::Category::DEFAULT_CATEGORY
      raise JSS::NoSuchItemError, "No category '#{new_val}' in the JSS" unless JSS::Category.all_names(:refresh).include? new_val
      @category = new_val
      @need_to_update = true
    end

    ###
    ### Change a trigger event
    ###
    ### @param type[Symbol] the type of trigger, one of the keys of {TRIGGER_EVENTS}
    ###
    ### @param new_val[Boolean] whether the type of trigger is active or not.
    ###
    ### @return [void]
    ###
    def set_trigger_event (type, new_val)
      raise JSS::InvalidDataError, "Trigger type must be one of #{TRIGGER_EVENTS.keys.join(', ')}" unless TRIGGER_EVENTS.keys.include? type
      if type == :custom
        raise JSS::InvalidDataError, "Custom triggers must be Strings" unless new_val.kind_of? String
      else
        raise JSS::InvalidDataError, "Non-custom triggers must be true or false" unless JSS::TRUE_FALSE.include? new_val
      end
      @trigger_events[TRIGGER_EVENTS[type]] = new_val
      @need_to_update = true
    end

    ###
    ### @return [String] The unix shell command to run on ths client.
    ###
    def run_command ; @files_processes[:run_command] ; end

    ###
    ### Set the unix shell command to be run on the client
    ###
    ### @param command[String] the unix shell command to be run on the client
    ###
    ### @return [void]
    ###
    def run_command= (command)
      raise JSS::InvalidDataError, "Command to run must be a String" unless command.is_a? String
      @files_processes[:run_command] = command
      @need_to_update = true
    end

    ###
    ### @return [Boolean] Should we update the database used by the locate command?
    ###
    def update_locate_database? ; @files_processes[:update_locate_database] ; end

    ###
    ### Set whether or not to update the database used by the locate command.
    ###
    ### @param tf[Boolean] whether or not to update the database used by the locate command.
    ###
    ### @return [void]
    ###
    def update_locate_database= (tf)
      @files_processes[:update_locate_database] = tf ? true : false
      @need_to_update = true
    end

    ###
    ### @return [String] The process name to search for on the client
    ###
    def search_for_process
      @files_processes[:search_for_process]
    end

    ###
    ### @return [Boolean] Should the searched-for process be killed if found.
    ###
    def kill_process?
      @files_processes[:kill_process]
    end

    ###
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
    def set_search_for_process (process, kill = false)
      @files_processes[:search_for_process] = process.to_s
      @files_processes[:kill_process] = kill ? true : false
      @need_to_update = true
    end

    ###
    ### @return [Pathname] The path to search for
    ###
    def search_by_path ; Pathname.new @files_processes[:search_by_path] ; end

    ###
    ### @return [Boolean] Should the searched-for path be deleted if found?
    ###
    def delete_file? ; @files_processes[:delete_file] ; end

    ###
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
    def set_search_by_path (path, delete = false)
      raise JSS::InvalidDataError, "Path to search for must be a String or a Pathname" unless path.is_a? String or path.is_a? Pathname
      @files_processes[:search_by_path] = path.to_s
      @files_processes[:delete_file] = delete ? true : false
      @need_to_update = true
    end

    ###
    ### @return [String] The term to search for using spotlight
    ###
    def spotlight_search ; @files_processes[:spotlight_search] ; end

    ### Set the term to seach for using spotlight
    ###
    ### @param term[String] the term to seach for using spotlight
    ###
    ### @return [void]
    ###
    def spotlight_search= (term)
      raise JSS::InvalidDataError, "Spotlight search term must be a String" unless term.is_a? String
      @files_processes[:spotlight_search] = term
      @need_to_update = true
    end

    ###
    ### @return [String] The term to seach for using the locate command
    ###
    def locate_file ; @files_processes[:locate_file] ; end

    ### Set the term to seach for using the locate command
    ###
    ### @param term[String] the term to seach for using the locate command
    ###
    ### @return [void]
    ###
    def locate_file= (term)
      raise JSS::InvalidDataError, "Term to locate must be a String" unless term.is_a? String
      @files_processes[:locate_file] = term
      @need_to_update = true
    end

    ### @return [Array] the id's of the packages handled by the policy
    def package_ids; @packages.map{|p| p[:id]} ; end

    ### @return [Array] the names of the packages handled by the policy
    def package_names; @packages.map{|p| p[:name]} ; end

    ### @return [Array] the id's of the scripts handled by the policy
    def script_ids; @scripts.map{|p| p[:id]} ; end

    ### @return [Array] the names of the scripts handled by the policy
    def script_names; @scripts.map{|p| p[:name]} ; end

    ### @return [Array] the id's of the directory_bindings handled by the policy
    def directory_binding_ids; @directory_bindings.map{|p| p[:id]} ; end

    ### @return [Array] the names of the directory_bindings handled by the policy
    def directory_binding_names; @directory_bindings.map{|p| p[:name]} ; end

    ### @return [Array] the id's of the dock_items handled by the policy
    def dock_item_ids; @dock_items.map{|p| p[:id]} ; end

    ### @return [Array] the names of the dock_items handled by the policy
    def dock_item_names; @dock_items.map{|p| p[:name]} ; end

    ### @return [Array] the id's of the printers handled by the policy
    def printer_ids; @printers.map{|p| p[:id]} ; end

    ### @return [Array] the names of the printers handled by the policy
    def printer_names; @printers.map{|p| p[:name]} ; end

    ### @return [Boolean] is this policy available in SelfService?
    def self_service?; @self_service[:use_for_self_service] ; end
    
    ### Aliases
    alias enabled? enabled
    alias pkgs packages
    alias command_to_run run_command
    alias delete_path? delete_file?

    #####################################
    ### Private Instance Methods
    #####################################
    private

    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      general = obj.add_element "general"
      general.add_element('name').text = @name
      general.add_element('enabled').text = @enabled
      general.add_element('frequency').text = @frequency
      general.add_element('target_drive').text = @target_drive
      general.add_element('offline').text = @offline
      general.add_element('category').add_element('name').text = @category

      JSS.hash_to_rexml_array(@trigger_events).each{|t| general << t}

      obj << @scope.scope_xml

      files_processes = obj.add_element "files_processes"
      JSS.hash_to_rexml_array(@files_processes).each{|f| files_processes << f}

      return doc.to_s
    end

  end # class policy

end # module

