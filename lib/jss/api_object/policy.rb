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
  ### A class implementing a JSS Policy
  ###
  ### Policy instances are partially read-only.
  ### - new policies cannot be created via the Policy class, please use the WebApp.
  ### - Only a few attributes can be changed and updated via the Policy class:
  ###      - name
  ###      - enabled
  ###      - category
  ###      - triggers 
  ###      - scope, see JSS::Scopable::Scope
  ###      - files and processes
  ### All other values and sections must be edited via the Web App.
  ###
  ### Policies may be deleted via this class
  ###
  ### See also JSS::APIObject
  ###
  class Policy < JSS::APIObject
    
    #####################################
    ### Mix-Ins
    #####################################
    
    include JSS::Updatable
    include JSS::Scopable
    include JSS::FileUpload
    
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
    ### and correspond to the general section of the Edit Policy windoe in 
    ### the JSS. They are general settings for this policy.
    
    attr_reader :name # policy name
    attr_reader :id # policy JSS id
    attr_reader :category # policy category name, a string
    attr_reader :frequency # how often to run the policy on each computer
    attr_reader :target_drive # which drive should the policy target
    attr_reader :offline # should be policy be available offline
    attr_reader :enabled # is the polich enabled
    attr_reader :site # a string with the site name
    attr_reader :override_default_settings # a hash like 
    ### {:distribution_point=>"", :force_afp_smb=>false, :netboot_server=>"current", :target_drive=>"default", :sus=>"default"}
    
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
    ###   :activation - DateTime
    ###   :expiration - DateTime
    ###   :no_execute_on - An array of short day names as symbols, e.g. [:sun, :mon, :wed, :thu]
    ###   :no_execute_start - Time
    ###   :no_execute_end - Time
    ### but in the UI, those are set in the Server Side Limitiations and Client Side Limitiations.
    ### areas, so we'll store them in matching hashes below.
    ###     attr_reader :date_time_limitations
    
    ### This is a hash of two items, :activateion and :expiration, both DateTimes.
    ### the data comes from the API in the date_time_limitations hash of the general 
    ### section, but the UI shows them in the Server Side Limitations area.
    ### This attribute is just for convience and consistency, and just 
    ### refers to the data in their API locations
    attr_reader :server_side_limitations
    
    ### This is a hash of four items,
    ###   :no_execute_on - An array of short day names as strings, e.g. ["Sun", "Mon", "Tue"]
    ###   :no_execute_start - Time
    ###   :no_execute_end - Time
    ###   :network_connection - String
    ### The data for the first three comes from the API in the date_time_limitations 
    ### hash of the general section
    ### The fourth comes from the network_requirements of the general section of the API
    ### but the UI shows them in the Client Side Limitations area
    ### This attribute is just for convience and consistency, and just 
    ### refers to the data in their API locations
    attr_reader :client_side_limitations
    
    ### This contains either EVENT or USER_INITIATED
    ### if EVENT, then one or more of the members @trigger_events is true.
    attr_reader :trigger
    
    ### This is a hash with the following keys. Each comes from the API
    ### as a key in the :general hash, but they make more sense separated out
    ### like this.
    ### These define when the policy should be triggered on applicable machines
    ###
    ###  :trigger_startup  => Bool
    ###  :trigger_login  => Bool
    ###  :trigger_logout  => Bool
    ###  :trigger_checkin  => Bool
    ###  :trigger_network_state_changed  => Bool
    ###  :trigger_enrollment_complete  => Bool
    ###  :trigger_other => the String that causes a custom trigger
    ###
    ### To edit a value, call #set_trigger_event(type, new_val)
    ### where type is one of the keys in TRIGGER_EVENTS and new val is the new value (usually boolean)
    ###
    attr_reader :trigger_events
   
    ##### client machine maintenence 
    ### These are the computer maint. tasks
    ### that might be performed by this policy
    ### All are boolean
    attr_reader :verify_startup_disk
    attr_reader :permissions_repair
    attr_reader :recon
    attr_reader :fix_byhost
    attr_reader :reset_name
    attr_reader :flush_system_cache
    attr_reader :install_cached_pkgs
    attr_reader :flush_user_cache
    ### attr_reader :heal # deprecated
    ### attr_reader :prebinding # deprecated
    
    ##### client account maint 
    ### acct related maintenence performed by this policy
    
    attr_reader :directory_bindings # array of hashes of bindings. each hash like: {:name=>"LDAP", :id=>4}
    attr_reader :open_firmware_efi_password # an array of the OFpw (3 ways) and the OF mode {:of_password, :of_password_md, :of_password_sha256, :of_mode }
    
    ### things to do to the mgmt acct. A hash like this
    ### :action see MGMT_ACCOUNT_ACTIONS
    ### :managed_password  
    ### :managed_password_md5 
    ### :managed_password_sha256 
    ### :managed_password_length  # for random generated pws
    ### 
    attr_reader :management_account 
    
    ### accounts - an array of hashes for accts acted-upon by this policy
    ### each item looks like:
    ###   {:hint=>"foo  bar",
    ###         :picture=>"/path/to/pic.tif",
    ###         :admin=>true,
    ###         :home=>"/Users/chrisltest",
    ###         :realname=>"ChrisTest Lasell",
    ###         :filevault_enabled=>true,
    ###         :username=>"chrisltest",
    ###         :password_md5=>"3858f62230ac3c915f300c664312c63f",
    ###         :password=>"foobar",
    ###         :password_sha256=>
    ###          "c3ab8ff13720e8ad9047dd39466b3c8974e592c2fa383d4a3960714caef0c4f2",
    ###         :action=>"Create"}
    attr_reader :accounts
    
    ##### packages
    ### an array of hashes for the pkgs handled by this policy
    ### each item looks like:
    ###   {:fut=>false,
    ###    :update_autorun=>false,
    ###    :feu=>false,
    ###    :name=>"rbgem-json-1.6.5-4.pkg",
    ###    :id=>1073,
    ###    :action=>"Install"}
    attr_reader :packages
    alias pkgs packages
    
    ###### scripts
    ### an array of hashes for each script run by this policy
    ### each item looks like:
    ###     {:parameter7=>"",
    ###     :parameter8=>"",
    ###     :parameter9=>"",
    ###     :parameter4=>"",
    ###     :parameter10=>"",
    ###     :parameter5=>"",
    ###     :parameter11=>"",
    ###     :name=>"chromegetter.sh",
    ###     :parameter6=>"",
    ###     :id=>1428,
    ###     :priority=>"After"}
    attr_reader :scripts
    
    ##### self service
    ### a hash  like this:
    ###      :self_service_icon => {:uri=>"https://casper.pixar.com:8443//iconservlet/?id=11",:id=>11, :filename=>"DockSwapperIcon.png"}
    ###      :use_for_self_service=>true,
    ###      :install_button_text=>"Install",
    ###      :self_service_description=>"Descriptive text",
    ###      :force_users_to_view_description=>false
    ### Note: we'll add a convenience method below "self_service?"  
    ###   which returns the :use_for_self_service key.
    attr_reader :self_service
    
    #### user interaction
    ### These are extracted from the :user_interaction hash 
    ### in the JSON output, which looks like this:
    ### {:message_start=>"",
    ### :allow_users_to_defer=>false,
    ### :allow_deferral_until_utc=>"",
    ### :message_finish=>""}
    ###
    attr_reader :user_may_defer # Bool
    attr_reader :user_may_defer_until # DateTime
    attr_reader :user_message_start # String
    attr_reader :user_message_finish # String
    
    #### reboot options
    ### A hash llike this
    ###     {:user_logged_in=>"Do not restart",
    ###      :minutes_until_reboot=>5,
    ###      :message=>
    ###       "This computer will restart in 5 minutes. Please save anything you are working on and log out by choosing Log Out from the bottom of the Apple menu.",
    ###      :startup_disk=>"Current Startup Disk",
    ###      :specify_startup=>"",
    ###      :no_user_logged_in=>"Do not restart"}
    ###      
    attr_reader :reboot_options
    
    ##### files & processes
    ### a hash like this:
    ### {:spotlight_search=>"Spotlight This",
    ###  :search_for_process=>"SafariProcess",
    ###  :search_by_path=>"/this/is/a/path",
    ###  :kill_process=>true,
    ###  :delete_file=>true,
    ###  :run_command=>"/usr/local/pixar/sbin/force-fde-logout  --setup",
    ###  :locate_file=>"this-is-a-filename",
    ###  :update_locate_database=>true}
    ###
    ### NOTE, since these itemds are editable, they have custom getters/setters
    ### so that the hasn isn't directly changable without 
    ### setting @need_to_update.
    ### attr_reader :files_processes

    
    ###dock items - an array of hashes, one for each dock item handled by this policy
    ### each item looks like: {:name=>"Mail", :id=>14, :action=>"Add To Beginning"}
    attr_reader :dock_items
    
    ### disk encryption - a hash, {:disk_encryption_configuration_id=>3, :action=>"apply"}
    attr_reader :disk_encryption
    
    ### printers - an array of hashes, one for each printer handled by this policy
    ### each item looks like: {:make_default=>false, :name=>"torlan", :id=>3, :action=>"install"}
    attr_reader :printers
    
    ### the rest resource path for this policy
    attr_reader :rest_rsrc
    
    ### do we have unsaved changes?
    attr_reader :need_to_update
    
    ### in the jss? will be until deleted
    attr_reader :in_jss
    
    #####################################
    ### Public Instance Methods
    #####################################
    
    ###
    ### Initialization takes a hash requiring at least a :name or an :id or :data
    ### If :data it provided, it's assumed to be the JSON output from the API for a single policy, 
    ### otherwise, :name or :id are required, and will be looked up in the JSS
    ### 
    ### 
    def initialize(args = {})
      
      super
      
    
      gen =  @init_data[:general]
      @category = gen[:category][:name]
      @frequency = gen[:frequency]
      @target_drive = gen[:target_drive]
      @offline = gen[:offline]
      @enabled = gen[:enabled]
      @site = gen[:site][:name]
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
        :activation => JSS.parse_datetime(dtl[:activation_date_epoch]), 
        :expiration => JSS.parse_datetime(dtl[:expiration_date_epoch])
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
    ### Change the enabled of this item
    ###
    def enabled= (new_val)
      return nil if @enabled == new_val
      raise JSS::InvalidDataError, "New value must be true or false" unless JSS::TRUE_FALSE.include? new_val
      @enabled = new_val
      @need_to_update = true
    end 
    
    ###
    ### Change the category of this item, arg is a category name
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
    
    ### The unix shell command to run on ths client.
    def run_command ; @files_processes[:run_command] ; end
    alias command_to_run run_command
    
    ### Set the unix shell command to run on the client.
    def run_command= (command)
      raise JSS::InvalidDataError, "Command to run must be a String" unless command.is_a? String
      @files_processes[:run_command] = command
      @need_to_update = true
    end
    
    ### Should we update the databse used by the locate command?
    def update_locate_database? ; @files_processes[:update_locate_database] ; end
    
    ### Set whether or not to update the database used by the locate command.
    def update_locate_database= (tf)
      @files_processes[:update_locate_database] = tf ? true : false
      @need_to_update = true
    end
    
    ### The process name to search for
    def search_for_process ; @files_processes[:search_for_process] ; end
    
    ### Should the process be killed if found.
    def kill_process? ; @files_processes[:kill_process] ; end

    ### Set the process name to search for, and should it be killed if found.
    def search_for_process= (proc, kill = false)
      raise JSS::InvalidDataError, "Process to search for must be a String" unless proc.is_a? String
      @files_processes[:search_for_process] = proc
      @files_processes[:kill_process] = kill ? true : false
      @need_to_update = true
    end
    
    ### The path to search for, Pathname
    def search_by_path ; Pathname.new @files_processes[:search_by_path] ; end
    
    ### Should the searched path be deleted if found?
    def delete_file? ; @files_processes[:delete_file] ; end
    alias delete_path? delete_file?
    
    ### Set the path to search for, a String or Pathname, and whether or not to delete it if found.
    def search_by_path= (path, delete = false)
      raise JSS::InvalidDataError, "Path to search for must be a String or a Pathname" unless path.is_a? String or path.is_a? Pathname
      @files_processes[:search_by_path] = path.to_s
      @files_processes[:delete_file] = delete ? true : false
      @need_to_update = true
    end

    ### The term to seach for using spotlight
    def spotlight_search ; @files_processes[:spotlight_search] ; end
    
    ### Set the term to seach for using spotlight
    def spotlight_search= (term)
      raise JSS::InvalidDataError, "Spotlight search term must be a String" unless term.is_a? String
      @files_processes[:spotlight_search] = term
      @need_to_update = true
    end
    
    ### The term to seach for using the locate command
    def locate_file ; @files_processes[:locate_file] ; end
    
    ### Set the term to seach for using the locate command
    def locate_file= (term)
      raise JSS::InvalidDataError, "Term to locate must be a String" unless term.is_a? String
      @files_processes[:locate_file] = term
      @need_to_update = true
    end
    
    
    def package_ids; @packages.map{|p| p[:id]} ; end
    def package_names; @packages.map{|p| p[:name]} ; end
    
    def script_ids; @scripts.map{|p| p[:id]} ; end
    def script_names; @scripts.map{|p| p[:name]} ; end
    
    def directory_binding_ids; @directory_bindings.map{|p| p[:id]} ; end
    def directory_binding_names; @directory_bindings.map{|p| p[:name]} ; end
    
    def dock_item_ids; @dock_items.map{|p| p[:id]} ; end
    def dock_item_names; @dock_items.map{|p| p[:name]} ; end
    
    def printer_ids; @printers.map{|p| p[:id]} ; end
    def printer_names; @printers.map{|p| p[:name]} ; end
    
    def self_service?; @self_service[:use_for_self_service] ; end
    
    #####################################
    ### Private Instance Methods
    #####################################
    ###private
    
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s
      
      general = obj.add_element "general"
      general.add_element('name').text = @name
      general.add_element('enabled').text = @enabled
      general.add_element('category').add_element('name').text = @category
      JSS.hash_to_rexml_array(@trigger_events).each{|t| general << t}
      
      obj << @scope.scope_xml
      
      files_processes = obj.add_element "files_processes"
      JSS.hash_to_rexml_array(@files_processes).each{|f| files_processes << f}
      
      return doc.to_s
    end
    
  end # class policy
  
end # module

