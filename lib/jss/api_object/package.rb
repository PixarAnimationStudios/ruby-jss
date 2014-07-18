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

  #####################################
  ### Classes
  #####################################

  ### 
  ### A Package in the JSS
  ###
  ### When instantiating a package, :data, :name or :id must be provided.
  ###
  ### If only :id or :filename are provided, all the rest of the data to be queried
  ### from the JSS. 
  ###
  ### If any other data is provided, it is assumed that ALL  the remaining data will be
  ### provided in the args. If that data didn't come from the server via some other
  ### query (which you can indicate by providing :data_came_from_server) the data
  ### is checked for consistency during initialization, and an error is raised if 
  ### inconsistent.
  ### 
  ### To create a package that doesn't yet exist in the JSS, provide :create => true,
  ### in which case a :filename is required, (but obviously not an :id)
  ### The :filename given must not already exist in the JSS packages table.
  ###
  ### If you want to upload a local file to the master dist. point, provide a path to it
  ### with :local_file in the args, and also provide the :rw_passwd for the dist point.
  ### The :local_file need not have the same :filename, it will be set correctly on the 
  ### server when uploaded.
  ###
  ### The #save method will then cause a new package be added to the JSS.
  ### If a :local_file was provided, it will be uploaded
  ### to the master dist. point using the :rw_passwd. If not, the admin is responsible for
  ### uploading the file some other way
  ###
  ###
  ### Also the API provides no access to the package's 
  ### file list (index), so indexing must be done separately (usually via Casper Admin)
  ###
  ### Here's the JSON data for a package.
  ### :allow_uninstalled=>true,
  ### :boot_volume_required=>false,
  ### :category=>"pkg-application",
  ### :filename=>"1keyboard-1.0-1.pkg"
  ### :fill_existing_users=>false,
  ### :fill_user_template=>false,
  ### :id=>1858,
  ### :info=>"",
  ### :install_if_reported_available=>"false",
  ### :name=>"1keyboard-1.0-1.pkg",
  ### :notes=>"Installer for 1Keyboard",
  ### :os_requirements=>"",
  ### :priority=>10,
  ### :reboot_required=>false,
  ### :reinstall_option=>"Do Not Reinstall",
  ### :required_processor=>"x86",
  ### :send_notification=>false,
  ### :switch_with_package=>"Do Not Install"
  ### :triggering_files=>{}  # DEPRECATED
  ###
  ### See also JSS::APIObject
  ###
  class Package  < JSS::APIObject
    
    #####################################
    ### Mix-Ins
    #####################################
    
    include JSS::Creatable
    include JSS::Updatable
    
    #####################################
    ### Class Methods
    #####################################
    
    #####################################
    ### Class Constants
    #####################################    
    
    ### The base for REST resources of this class
    RSRC_BASE = "packages"   
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :packages
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :package
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:fill_existing_users, :fill_user_template, :reboot_required ]
    
    
    
    ### The pkg storage folder on the distribution point
    DIST_POINT_PKGS_FOLDER = "Packages"
    
    ### The possible values for cpu_type (required_processor) in a JSS package
    CPU_TYPES = ["None", "x86", "ppc"]
    
    ### which is default?  there must be one to make a new pkg
    DEFAULT_REQ_CPU_TYPE = "None"
    
    ### the possible values for self-healing trigger-file comparisons
    SH_TRIGGER_FILE_COMPARISONS = ["Permissions", "File Exists", "Any Difference"]
    
    ### the array of trigger files is full of hashes, each of which must have these keys
    SH_TRIGGER_FILE_HASH_KEYS = [:compare, :name]
    
    ### the possible priorities
    PRIORITIES = (1..20)
    
    ### the default priority, since one is needed for making new pkgs
    DEFAULT_PRIORITY = 10
    
    ### The mapping of symbols used throughout this class (mostly as class attributes)
    ### to field names in the JSS packages table
    PKG_ATTRS_TO_JSS_FIELDS = {
              :id => 'package_id',
              :filename => 'file_name',
              :name => 'package_name',
              :feu => 'fill_existing_users',
              :fut => 'fill_user_template',
              :reboot => 'require_reboot',
              :oses => 'os_requirements',
              :cpu_type => 'required_processor',
              :removable => 'allow_uninstall',
              :info => 'info',
              :notes => 'notes',
              :cat_id => 'category_id',
              :priority => 'priority',
    }
    
    ### by default, no processor requirement
    DEFAULT_REQUIRED_PROCESSOR = "None"
    
    #####################################
    ### Class Variables
    #####################################  
    
    #####################################
    ### Class Methods
    #####################################  
    
    #####################################
    ### Attributes
    #####################################
    
    ### String - the filename of the .pkg, .mpkg, or .dmg on the Casper server
    attr_reader :filename
    
    ### Boolean - does this item 'Fill Existing Users' when jamf installs it?
    attr_reader :fill_existing_users
    alias feu fill_existing_users
    alias feu? fill_existing_users
    
    ### Boolean - does this pkg also get install in the OS user homedir template
    attr_reader :fill_user_template
    alias fut fill_user_template   
    alias fut? fill_user_template
    
    ### Boolean - does this item require a reboot after installation? If so, it'll be a puppy-install in d3
    attr_reader :reboot_required
    alias reboot reboot_required
    alias reboot? reboot_required
    
    ### Array of Strings - the OS versions this can be installed onto. For all minor versions, the format is 10.5.x
    attr_reader :os_requirements
    alias oses os_requirements
    
    ### String - the cpu type this item can be installed on: 'x86' or 'ppc'. The JSS stores "None" but this should be nil if so.
    attr_reader :required_processor
    alias cpu_type required_processor
  
    ### String - the name of a pkg to install when this pkg can't be installed due to cpu-type mismatch
    ### or the string "Do Not Install"
    attr_reader :switch_with_package
    
    ### Boolean - can this item be uninstalled? Some, e.g. OS Updates, can't
    attr_reader :allow_uninstalled
    alias removable allow_uninstalled
    alias removable? allow_uninstalled
    
    ### String - the category of this pkg, stored in the JSS as the id number from the categories table
    attr_reader :category
    
    ### String - the info field for this pkg - stores d3's basename & swupdate values
    attr_reader :info
    
    ### String - the notes field for this pkg
    attr_reader :notes
    
    ### Boolean - only install this pkg if it's available in the commandline softwareupdate.
    attr_reader :install_if_reported_available
    alias if_in_swupdate install_if_reported_available
    alias if_in_swupdate? install_if_reported_available
    
    ### Boolean - should this pkg be installed on the boot volume during imaging
    attr_reader :boot_volume_required
    alias boot boot_volume_required
    alias boot? boot
    
    ### Integer - Priority to use for deploying or uninstalling the package 
    ### (e.g. A package with a priority of "1" is deployed or uninstalled before other packages)
    attr_reader :priority
    
    ### Boolean - does this pkg cause a notification to be sent on self-heal?
    attr_reader :send_notification
    alias notify send_notification
    
    ###
    ### Initialization takes a hash requiring at least a :name, an :id, or :data
    ### To look up an existing pkg, use one of 
    ###    :name => the name of a pkg in the JSS. It will be looked up to create the Package object.
    ###    :id => the JSS id nuumber of a pkg in the JSS. It will be looked up to create the Package object.
    ###
    ### If you have the data from a previous API lookup:
    ###    :data => the parsed JSON output from the API (a hash) with the details of a single package.
    ###
    ### To create a new pkg in the JSS
    ###    :id => :new
    ###    :name => <newname>
    ### then be sure to call #create after setting the values with the setters
    ###
    def initialize (args = {})
      super
      
      ### now we have pkg_data with something in it, so fill out the instance vars
      @allow_uninstalled = @init_data[:allow_uninstalled]
      @boot_volume_required = @init_data[:boot_volume_required] 
      @category = @init_data[:category] 
      @cat_id = JSS::Category.map_all_ids_to(:name).invert[@category]
      @filename = @init_data[:filename] || @init_data[:name]
      @fill_existing_users = @init_data[:fill_existing_users] 
      @fill_user_template = @init_data[:fill_user_template] 
      @info = @init_data[:info]
      @install_if_reported_available = @init_data[:install_if_reported_available] 
      @notes = @init_data[:notes] 
      @os_requirements = @init_data[:os_requirements].split(/\s*,\s*/) if data[:os_requirements]
      @priority = @init_data[:priority] || DEFAULT_PRIORITY
      @reboot_required = @init_data[:reboot_required] 
      @required_processor = @init_data[:required_processor] || DEFAULT_REQ_CPU_TYPE
      @send_notification = @init_data[:send_notification] 
      @switch_with_package = @init_data[:switch_with_package]
      
    end # initialize    
    
    ###
    ### Change the package filename
    ### Setting it to nil will make it match the display name
    ###
    ### new_val = string
    ###
    def filename= (new_val)
      new_val = nil if new_val == ''
      raise JSS::MissingDataError, "Filename cannot be empty" unless new_val
      return nil if new_val == @filename
      @filename = new_val
      @need_to_update = true
    end #filename=
    
    ###
    ### Change the display name 
    ### new_val = string
    ###
    def name= (new_val)
      new_val = nil if new_val == ''
      raise JSS::MissingDataError, "Name cannot be empty" unless new_val
      raise JSS::AlreadyExistsError, "A #{RSRC_OBJECT_KEY} already exists with the name '#{new_val}'" if JSS.send(LIST_METHOD).values.include?
      return nil if new_val == @name
      @name = new_val
      @need_to_update = true
      @rest_rsrc = "#{RSRC_BASE}/name/#{URI.escape @name}" if @rest_rsrc.include? '/name/'
    end #name=
    
    ###
    ### Change the Fill Existing Users value
    ### new_val = boolean
    ###
    def fill_existing_users= (new_val)
      return nil if new_val == @fill_existing_users
      new_val = false if new_val.to_s.empty? 
      raise JSS::InvalidDataError, "fill_existing_users must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
      @need_to_update = true
      @fill_existing_users = new_val
    end #fill_existing_users=
    alias feu= fill_existing_users=
    
    ###
    ### Change the fill_user_template value
    ###
    ### new_val = boolean
    ###
    def fill_user_template= (new_val)
      return nil if new_val == @fill_user_template
      new_val = false if new_val.to_s.empty? 
      raise JSS::InvalidDataError, "fill_user_template must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
      @need_to_update = true
      @fill_user_template = new_val
    end #fut=
    alias fut= fill_user_template=
    
    ###
    ### Change the reboot-required field in the JSS
    ### new_val = boolean
    ###
    def reboot_required= (new_val)
      return nil if new_val == @reboot_required
      new_val = false if new_val.to_s.empty? 
      raise JSS::InvalidDataError, "reboot must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
      @need_to_update = true
      @reboot_required = new_val
    end #reboot_required=
    alias reboot= reboot_required=
    
    ###
    ### Change the os_requirements field in the JSS
    ### E.g. 10.5, 10.5.3, 10.6.x
    ### new_val =  comma-separated string, or array of os versions
    ### 
    ### Extra feature: Minumum OS's can now be specified as a 
    ### string using the notation ">=10.6.7". See the JSS.expand_min_os method 
    ###
    def os_requirements= (new_val)
      ### nil should be an empty array
      new_val = [] if new_val.to_s.empty?
      
      ### if any value starts with >=, expand it
      case new_val.class 
        when String 
          new_val = JSS.expand_min_os(new_val) if new_val =~ /^>=/
        when Array
          new_val.map!{|a|  a =~ /^>=/ ? JSS.expand_min_os(a) : a }
          new_val.flatten!
          new_val.uniq!
        else
          raise JSS::InvalidDataError, "os_requirements must be a String or an Array of strings" 
      end
      ### get the array version 
      @os_requirements = JSS.to_s_and_a(new_val)[:arrayform]
      @need_to_update = true
    end #os_requirements=
    alias oses= os_requirements=
    
    ###
    ### Change the required processor field in the JSS
    ###
    ### new_val = string, one of "None", "x86", or "PowerPC"
    ###
    def required_processor= (new_val)
      return nil if new_val == @required_processor
      new_val = validate_for_server(:required_processor => new_val)[:required_processor]
      
      new_val = DEFAULT_REQUIRED_PROCESSOR if new_val.to_s.empty?
      raise JSS::InvalidDataError, "Required_processor must be one of: #{CPU_TYPES.join ', '}" unless CPU_TYPES.include? new_val
          
      @need_to_update = true
      @required_processor = new_val
    end #info=
    alias cpu_type= required_processor=
    
    ###
    ### Change the switch_with_package field in the JSS
    ###
    ### new_val = string, the filename of an existing package
    ###
    def switch_with_package= (new_val)
      return nil if new_val == @switch_with_package
      new_val = nil if new_val.to_s.empty?
      raise JSS::NoSuchItemError, "No package named '#{new_val}' exists in the JSS" if new_val and not self.class.all_names.include? new_val
      @need_to_update = true
      @switch_with_package = new_val
    end #notes=
    
    ###
    ### Change the 'allow to be uninstalled' field in the JSS
    ### NOTE we have to be indexed before this works.  Right now, that means
    ### using CasperAdmin.app
    ### new_val = boolean
    ###
    def allow_uninstalled= (new_val)
      return nil if new_val == @allow_uninstalled

      ### removable? defaults to false
      ### even though we usually want to be able to ununstall things, it would be
      ### dangerous to do on things like OS updates, so it must be turned on explicitly.
      ### packages must be indexed with Casper Admin in order to be uninstalled.
      new_val = false if new_val.to_s.empty?
      raise JSS::InvalidDataError, "allow_uninstalled must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
          
      @need_to_update = true
      @allow_uninstalled= new_val
      
    end #removable=
    alias removable= allow_uninstalled=
    
    ###
    ### Change the category in the JSS
    ###
    ### new_val = string, must be one listed by 'JSS::Category.all_names'
    ###
    def category= (new_val)
      return nil if new_val == @category
      new_val = nil if new_val == ''
      new_val ||= JSS::Category::DEFAULT_CATEGORY
      raise JSS::InvalidDataError, "Category #{new_val} is not known to the JSS" unless JSS::Category.all_names.include? new_val
      @need_to_update = true
      @category = new_val
      @cat_id = JSS::Category.map_all_ids_to(:name).invert[@category]
    end #category=
    
    ###
    ### Change the info field in the JSS
    ### 
    ### new_val = string, line breaks should be \r, not \n    
    ###
    def info= (new_val)
      return nil if new_val == @info
      ### line breaks should be \r
      new_val = new_val.to_s.gsub(/\n/, "\r")
      @need_to_update = true
      @info = new_val
    end #info=
    
    ###
    ### Change the notes field in the JSS
    ###
    ### new_val = string, line breaks should be \r, not \n
    ###
    def notes= (new_val)
      return nil if new_val == @notes
      ### line breaks should be \r
      new_val = new_val.to_s.gsub(/\n/, "\r")
      @need_to_update = true
      @notes = new_val
    end #notes=

    ###
    ### Change the if_in_swupdate field in the JSS
    ###
    ### new_val = boolean
    ###
    def install_if_reported_available= (new_val)
      return nil if new_val == @install_if_reported_available
      new_val = false if new_val.to_s.empty?
      raise JSS::InvalidDataError, "install_if_reported_available must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
      @need_to_update = true
      @install_if_reported_available = new_val
    end #if_in_swupdate=
    alias if_in_swupdate= install_if_reported_available=
    
    ###
    ### Change the boot field in the JSS
    ###
    ### new_val = boolean
    ###
    def boot_volume_required= (new_val)
      return nil if new_val == @boot_volume_required
      new_val = false if new_val.to_s.empty?
      raise JSS::InvalidDataError, "install_if_reported_available must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
      @need_to_update = true
      @boot_volume_required = new_val
    end #boot=
    alias boot= boot_volume_required=
    
    ###
    ### Change the priority field in the JSS
    ###
    ### new_val = integer
    ###
    def priority= (new_val)
      return nil if new_val == @priority
      new_val = DEFAULT_PRIORITY if new_val.to_s.empty?
      raise JSS::InvalidDataError, ":priority must be an integer from 1-20" unless PRIORITIES.include? new_val
      @need_to_update = true
      @priority = new_val
    end #priority=
    
    ###
    ### Change the notify field in the JSS
    ###
    ### new_val = boolean
    ###
    def send_notification= (new_val)
      return nil if new_val == @send_notification
      new_val = false if new_val.to_s.empty?
      raise JSS::InvalidDataError, "send_notification must be boolean 'true' or 'false'" unless JSS::TRUE_FALSE.include? new_val
      @need_to_update = true
      @send_notification = new_val
    end #notify=
    alias notify= send_notification= 
    
    ###
    ### This causes the pkg to be installed in a JAMF-ish way, via the jamf command.
    ### the read-only passwd for the dist. point must be provided.
    ### valid args are: 
    ###  :verbose  - be verbose to stdout
    ###  :feu      - fill existing users, if the pkg supports it
    ###  :fut      - fill user template, if the pkg supports it
    ###  :unmount  - should we unmount the distribution point when finished (if we mounted it)
    ###               we don't by default, since often several pkgs are being installed.
    ### Returns 0 if both installer and jamf exit zero, otherwise 1
    ### NOTE: the jamf binary must be run as root to install pkgs.
    ###
    def install (ro_pw, *args)
      
      ### how do we access our dist. point?
      if JSS::DistributionPoint.my_distribution_point.http_downloads_enabled
        using_http = true
        src_path = JSS::DistributionPoint.my_distribution_point.http_url 
      else
        using_http = false
        src_path = JSS::DistributionPoint.my_distribution_point.mount
      end
      src_path += "/#{DIST_POINT_PKGS}"
      
      ### are we doing "fill existing users" or "fill user template"?
      do_feu = (args.include? :feu and self.feu?) ? "-feu" : ""
      do_fut = (args.include? :fut and self.fut?) ? "-fut" : ""
      
      ### use jamf binary to install the pkg
      command = "#{JSS::Client::JAMF_BINARY}  install -package '#{@filename}' -path '#{src_path}'  -target / #{do_feu} #{do_fut} -showProgress ; echo jamfexit $?"

      exit_code = args.include?(:verbose) ? install_verbosely(command) : install_silently(command)
      
      if (args.include? :unmount)
        JSS::DistributionPoint.my_distribution_point.unmount unless using_http 
      end
      
      return exit_code 
    end #run
    
    ###
    ### This causes the pkg to be uninstalled in a JAMF-ish way, via the jamf command.
    ### valid args are: 
    ###  :verbose  - be verbose to stdout
    ###  :feu      - fill existing users, if the pkg supports it
    ###  :fut      - fill user template, if the pkg supports it
    ###
    ### If verbose=true, stderr and stdout go to stdout, otherwise to devnull
    ###
    ### Returns the Process::Status of the finished 'jamf uninstall' command.
    ###
    ### NOTE: the jamf binary must be run as root to uninstall pkgs.
    ###
    def uninstall (*args)
      
      ### are we verbose?
      redirect = args.include?(:verbose) ? "2>&1" : "&> /dev/null"
      
      ### are we doing "fill existing users" or "fill user template"?
      do_feu = (args.include? :feu and self.feu?) ? "-feu" : ""
      do_fut = (args.include? :fut and self.fut?) ? "-fut" : ""
      
      ### use jamf binary to uninstall the pkg
      system "#{JSS::Client::JAMF_BINARY}  uninstall -target / -id '#{@id}' #{do_feu} #{do_fut} #{redirect}"
      
      return $?
    end #uninstall
    
    #################################
    ### Private Methods below here
    private
    
    ###
    ### Return the REST XML for this pkg, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      pkg = doc.add_element "package"
      pkg.add_element('allow_uninstalled').text = @allow_uninstalled
      pkg.add_element('boot_volume_required').text = @boot_volume_required
      pkg.add_element('category').text = @category
      pkg.add_element('filename').text = @filename
      pkg.add_element('fill_existing_users').text = @fill_existing_users
      pkg.add_element('fill_user_template').text = @fill_user_template
      pkg.add_element('id').text = @id
      pkg.add_element('info').text = @info
      pkg.add_element('install_if_reported_available').text = @install_if_reported_available
      pkg.add_element('name').text = @name
      pkg.add_element('notes').text = @notes
      pkg.add_element('os_requirements').text = JSS.to_s_and_a(@os_requirements)[:stringform]
      pkg.add_element('priority').text = @priority
      pkg.add_element('reboot_required').text = @reboot_required
      pkg.add_element('required_processor').text = @required_processor
      pkg.add_element('send_notification').text = @send_notification
      pkg.add_element('switch_with_package').text = @switch_with_package
      return doc.to_s
    end # rest xml
    
    ###
    ### The install method above uses this to do silent installs and return the correct status
    ### Returns 0 if both installer and jamf exit zero, otherwise 1
    ###
    def install_silently(cmd)
      output = `#{cmd}` 
      output =~ /<exitCode>(\d+)</
      installer_exit = $1 
      output =~ /jamfexit (\d+)/
      jamfexit = $1
      exit_code = (jamfexit == "0" && installer_exit == "0") ? 0 : 1
      return exit_code
    end
    
    ###
    ### The install method uses this to process/cleanup unbuffered stdout from the jamf install command in real time.
    ### Returns 0 if both installer and jamf exit zero, otherwise 1
    ###
    def install_verbosely(cmd)
        require 'pty'
        installer_exit = nil
        jamfexit = nil
        ### using pty spawn allows us to get unbuffered output from the command
        ### and process it before showing it to the user.
        PTY.spawn(cmd) do |sout,sin,pid|
          sout.each do |line| 
            case line
              when /^installer/ 
                puts $1 if line =~ /:PHASE:(.*)/
                puts $1 if line =~ /^installer: (.*)/
                puts "...#{$1}%" if line =~ /^installer:\%(\d+\.\d\d?)/
              when /<exitCode>(\d+)</
                installer_exit = $1
              when /jamfexit (\d+)/
                jamfexit = $1
              when /^</
                next
              else 
                puts line
            end # case
          end # sout.each
        end # PTY.spawn
        
        exit_code = (jamfexit == "0" && installer_exit == "0") ? 0 : 1
        return exit_code
    end
    
    ###
    ### Upload a locally-readable file to the master distribution point. 
    ### The first argument is the path (String or Pathname) to the local file.
    ### The local file can have any name, it will be renamed to @filename as it's moved.
    ### The second argument is the password for the read/write account on
    ### the master dist. point
    ### The third arg is boolean, whether or not to unmount the dist. point when finished,
    ### which defaults to true
    ###
    ### if the file is a directory (like a bundle .pk/.mpkg) it will be zipped before 
    ### uploading and the @filename will be adjusted accordingly
    ###
    def upload_master_file(local_file_path, rw_pw, unmount = true)
      local_path = Pathname.new local_file_path
      raise JSS::NoSuchItemError, "Local file '#{@local_file}' doesn't exist" unless local_path.exist?
      
      ### should we zip it?
      if local_path.directory?
        begin
          zipdir = Pathname.new "/tmp/jssgemtmp-#{Time.new.strftime "%Y%m%d%H%M%S"}-#{$$}"
          zipdir.mkpath
          zipdir.chmod 0700
          zipfile = zipdir + (local_path.basename.to_s + ".zip")
          
          ### go to the same dir as the local file
          wd = Dir.pwd
          Dir.chdir local_path.parent
          
          ### the contents of the zip file have to have the same  name as the zip file itself (minus the .zip)
          ### so temporarily rename the source
          local_path.rename(local_path.parent + @filename)
          raise "There was a problem zipping the pkg bundle" unless system "/usr/bin/zip -qr '#{zipfile}' '#{@filename}'"
          
        ensure
          ### rename the source to the original name
          (local_path.parent + @filename).rename local_path
          ### go back where we started
          Dir.chdir wd
        end # begin
        
        ### update our info
        local_path = zipfile
        
        self.filename = zipfile.basename.to_s
        self.update
      end # if directory
      
      destination = JSS::DistributionPoint.master_distribution_point.mount(rw_pw, :rw) +"#{DIST_POINT_PKGS_FOLDER}/#{@filename}"
      
      FileUtils.copy_entry local_path, destination
      
      JSS::DistributionPoint.master_distribution_point.unmount if unmount
    end # upload
    
    ###
    ### delete the filename from the master distribution point, if it exists.
    ### The first arg is the read/write password for the master dist. point.
    ### The second arg is boolean, whether or not to unmount the dist. point when finished,
    ### which defaults to true
    ### Returns true if deleted, false if not found
    ###
    def delete_master_file(rw_pw, unmount = true)
      file = JSS::DistributionPoint.master_distribution_point.mount(rw_pw, :rw) +"#{DIST_POINT_PKGS_FOLDER}/#{@filename}"
      if file.exist?
        file.delete
        did_it = true
      else
        did_it = false
      end # if exists
      JSS::DistributionPoint.master_distribution_point.unmount if unmount
      return did_it
    end # delete master file
    
  end # class Package
end # module
