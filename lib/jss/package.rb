# = package.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A class representing a Package in the JSS. Access is via the REST API and/or
# direct SQL to the database, depending on the need.
#

module PixJSS
  
  #####################################
  # Constants
  #####################################
  
  ###
  ### Paths
  ###
  
  # The pkg storage folder on the CasperShare volume
  CSHARE_PKGS = CASPERSHARE_MNTPNT + "Packages"
  
  # The deleted pkg storage folder on the CasperShare volume
  CSHARE_DELETED_PKGS = CASPERSHARE_MNTPNT + "Casper Data/Deleted Packages"
  
  ###
  ### URLS
  ###
  
  # The URL for http downloading of packages from the Casper server
  HTTP_PKGS_URL="http://#{JSS_HOST}/#{CSHARE}/Packages"
  
  
  ###
  ### Mappings 
  ### the common symbols used throughout PixJSS mapped to
  ### the names they use in various database tables and REST resources
  ###
  
  # The mapping of standardized symbols used throughout this module
  # to field names in the JSS packages table
  PKG_ATTRS_TO_JSS_FIELDS = {
            :id => 'package_id',
            :filename => 'file_name',
            :name => 'package_name',
            :feu => 'fill_existing_users',
            :reboot => 'require_reboot',
            :oses => 'os_requirements',
            :cpu_type => 'required_processor',
            :removable => 'allow_uninstall',
            :info => 'info',
            :notes => 'notes',
            :stage => 'stage',
            :cat_id => 'group_id'
  }
  
  # A shorter but less descriptive name for the PKG_ATTRS_TO_JSS_FIELDS constant
  JMAP = PKG_ATTRS_TO_JSS_FIELDS 
  
  # The mapping of standardized symbols used throughout this module
  # to attribute names in the REST API for packages
  PKG_ATTRS_TO_REST_ATTRS = {
            :id => 'id',
            :filename => 'filename',
            :feu => 'fill_existing_users',
            :reboot => 'reboot_required',
            :oses => 'os_requirements',
            :cpu_type => 'required_processor',
            :removable => 'allow_uninstalled',
            :info => 'info',
            :notes => 'notes',
            :name => 'name',
            :stage => 'stage',
            :category => 'category'
  }
  
  # A shorter but less descriptive name for the PKG_ATTRS_TO_REST_ATTRS constant
  RMAP = PKG_ATTRS_TO_REST_ATTRS 
  
  # The packages table in the JSS
  PKGS_TABLE = "packages"
  
  # The packages contents table in the JSS
  PKG_CONTENTS_TABLE = "package_contents"
  
  #####################################
  # Module Variables
  #####################################
  
  # a hash of JSSPkg objects keyed by filename, for all pkgs in the JSS
  # populated by the jss_pkgs method, q.v.
  @@pkgs = nil
  
    # an array of pkg filenames (strings) for all pkgs in the JSS
  # populated by the filenames method, q.v.
  @@pkg_files = nil
  
  # an array of JSS pkg ids (integers) for all pkgs in the JSS
  # populated by the jss_pkgs_ids method, q.v.
  @@pkg_ids = nil
  
  # an array of JSS pkg ids (integers) for all pkgs
  # that are available via self-service
  # populated by the self_svc_pkgs_ids method, q.v.
  @@self_svc_pkg_ids = nil
  
  # An array of Pathname objects, for each item in the 
  # JSS Rcpts dir
  @@installed_rcpts = []
  
  #####################################
  # Module Methods
  #####################################
  
  ###
  ### Return an array of hashes with all the server data needed to 
  ### create one or more JSSPkg objects.
  ###
  ### If args contain :filename => somename or :id => someid, then one 
  ### pkg will be queried, otherwise all will be.
  ###
  def pkg_query (args ={})
    
    check_connection
    
    if args[:id] 
      where_clause = "AND #{JMAP[:id]} = '#{args[:id]}'"
    elsif args[:filename] 
      where_clause = "AND #{JMAP[:filename]}= '#{args[:filename]}'"
    else
      where_clause = ""
    end
    
    queried_pkgs = []
    
    the_query = <<-ENDQUERY
      SELECT
        #{JMAP[:id]},
        #{JMAP[:filename]},
        #{JMAP[:name]},
        #{JMAP[:feu]},
        #{JMAP[:reboot]},
        #{JMAP[:oses]},
        #{JMAP[:cpu_type]},
        #{JMAP[:removable]},
        #{JMAP[:info]},
        #{JMAP[:notes]},
        #{JMAP[:stage]},
        #{JMAP[:cat_id]}
      FROM #{PKGS_TABLE}
      WHERE #{JMAP[:stage]} != 'Deleted'
      #{where_clause}
    ENDQUERY
    
    # execute the query and loop through the resulting rows as hashes
    @@db_cnx.query(the_query).each_hash do |db_data|
      
      # clean up - mysql data is all strings :-(
      pkg_data = clean_jss_db_data(db_data, :pkg)
         
      # add the data end of the big array
      queried_pkgs.push({
        :data_came_from_server => true,
        :id => pkg_data[JMAP[:id]],
        :filename => pkg_data[JMAP[:filename]],
        :name => pkg_data[JMAP[:name]],
        :feu => pkg_data[JMAP[:feu]],
        :reboot => pkg_data[JMAP[:reboot]],
        :oses => pkg_data[JMAP[:oses]],
        :cpu_type => pkg_data[JMAP[:cpu_type]],
        :removable => pkg_data[JMAP[:removable]],
        :info => pkg_data[JMAP[:info]],
        :notes => pkg_data[JMAP[:notes]],
        :stage => pkg_data[JMAP[:stage]],
        :category => pkg_data[:category], # the cleanup method converts cat_ids to names
        })
        
    end # query.each hash    
    queried_pkgs
  end #jss pkg query


  ###
  ### Return a hash of JSSPkg objects 
  ### for all pkgs available on the server, keyed off their filenames
  ###
  ### If this list has been generated already in your script, it will not be regenerated
  ### at every call, so as to not bother the server with a new query every time.
  ### If you want to force a new query, just provide any argument
  ###
  def pkgs (refresh = nil)
    @@pkgs = nil if refresh
    return @@pkgs if @@pkgs
    
    # start empty
    @@pkgs = {}
    
    # calling pkg_query with no args returns all of them
    pkg_query.each { |pkg| @@pkgs[pkg[:filename]] = JSSPkg.new(pkg) }
    
    return @@pkgs
  end # jss_pkgs
  
  
  ###
  ### Return an array of the pkg filenames of all JSS pkgs. 
  ###
  def pkg_files (refresh = nil) 
    @@pkg_files = nil if refresh
    return @@pkg_files if @@pkg_files
    
    check_connection
    
    # start empty
    @@pkg_files = []
    theQuery = "SELECT #{JMAP[:filename]} FROM #{PKGS_TABLE} WHERE #{JMAP[:stage]} != 'Deleted'"
    # execute the query
    @@db_cnx.query(theQuery).each {|bn| @@pkg_files.push bn[0] }
    @@pkg_files
  end
  
  ###
  ### Return an array of the ids of all JSS pkgs. 
  ###
  def pkg_ids (refresh = nil)
    @@pkg_ids = nil if refresh
    return @@pkg_ids if @@pkg_ids
    
    check_connection
    
    # start empty
    @@pkg_ids = []
    theQuery = "SELECT #{JMAP[:id]} FROM #{PKGS_TABLE} WHERE #{JMAP[:stage]} != 'Deleted'"
    # execute the query
    @@db_cnx.query(theQuery).each {|id| @@pkg_ids.push id[0].to_i }
    @@pkg_ids
  end
  
  ###
  ### return an array of jss package id's for all pkgs 
  ### currently available in self-service
  ###
  def self_svc_pkg_ids (refresh = nil)
    @@self_svc_pkg_ids = nil if refresh
    return @@self_svc_pkg_ids if @@self_svc_pkg_ids
    
    check_connection
    
    @@self_svc_pkg_ids = []
    
    the_query = <<-ENDQUERY
      SELECT pp.package_id 
      FROM  policy_packages pp JOIN policies pol ON pp.policy_id = pol.policy_id
      WHERE pol.use_for_self_service = 1
    ENDQUERY
    @@db_cnx.query(the_query).each { |db_data| @@self_svc_pkg_ids << db_data[0].to_i }
    @@self_svc_pkg_ids
  end ### self_svc_pkg_ids
  
  
  ###
  ### installed_rcpts - return an array of all
  ### Pathnames for all items in the jamf receipts folder
  ###
  def installed_rcpts(refresh = false)
    @@installed_rcpts = [] if refresh
    return @@installed_rcpts  unless @@installed_rcpts.empty?
    
    JAMF_RCPTS_DIR.children.each { |f| @@installed_rcpts << f }
    @@installed_rcpts
  end
  
  
  #####################################
  # Classes
  #####################################

  
  ###
  ### 
  ### A Package in the JSS
  ### 
  ### This is the superclass of D3LivePkg and D3PilotPkg
  ### (D3InstalledPkg is a different animal)
  ###
  ### Reading data about packages is done via MySQL, for speed & flexibility
  ### Writing data to the JSS is done via the REST API, for data integrity
  ###
  ### When instantiating this object, a JSS pkg filename or id must be provided.
  ### Providing :lookup => true causes all the rest of the data to be queried
  ### from the JSS database.
  ###
  ### without :lookup => true, it is assumed that all the remaining data will be
  ### provided in the args. See the PixJSS::PKG_ATTRS_TO_JSS_FIELDS constant for the 
  ### applicable keynames. The description of each keyname can be found
  ### in the attributes of PixJSS::JSSPkg,
  ### 
  ### If :new => true is provided, a :filename is required as well as a :local_filepath 
  ### pointing at the pkg or dmg file to be uploaded
  ### The file will be uploaded, and  new script will be added to the JSS DB 
  ### when the 'save' method is called, as if you had dragged it into Casper Admin
  ### and chosen "Save"
  ### The :filename given must not (obviously) already exist in the JSS packages table.
  ### 
  class JSSPkg
    include PixJSS
    
    # Integer- the id number of the pkg in the JSS
    attr_reader :id
    
    # String - the filename of the .pkg, .mpkg, or .dmg on the Casper server
    attr_reader :filename
    
    # String - the display-name of the package
    attr_reader :name
    
    # String - the stage of this pkg (Deployable, testing, etc)
    attr_reader :stage
    
    # Boolean - does this item 'Fill Existing Users' when jamf installs it?
    attr_reader:feu
    alias feu? feu
    
    # Boolean - does this item require a reboot after installation? If so, it'll be a puppy-install in d3
    attr_reader :reboot
    alias reboot? reboot
    
    # Array of Strings - the OS versions this can be installed onto. For all minor versions, the format is 10.5.x
    attr_reader :oses
    
    # String - the cpu type this item can be installed on: 'x86' or 'ppc'. The JSS stores "None" but this should be nil if so.
    attr_reader :cpu_type
  
    # Boolean - can this item be uninstalled? Some, e.g. OS Updates, can't
    attr_reader :removable
    alias removable? removable
    
    # String - the category of this pkg, stored in the JSS as the id number from the categories table
    attr_reader :category
    
    # String - the info field for this pkg - stores d3's basename & swupdate values
    attr_reader :info
    
    # String - the notes field for this pkg
    attr_reader :notes
    
    # String - the local path to the installer pkg or dmg file for uploading to the server
    attr_accessor :local_filepath
    
    # Pathname - where this file is located on the mounted CasperShare volume
    attr_reader :svr_path
    
    
    ###
    ### See the PKG_ATTRS_TO_JSS_FIELDS constant for the symbols used as arg keys
    ### for instantiation
    ###
    def initialize (args = {})
      
      raise MissingDataError, "Missing :filename or :id" unless (args[:filename] or args[:id])
            
      if args[:lookup] then # we need to query for the data for one JSSPkg
        
        search_result = pkg_query(:id => args[:id], :filename => args[:filename])
        raise NoSuchItemError, "Not found: JSS package #{args[:filename] ? args[:filename] : args[:id]}" if search_result.count == 0
        pkg_data = search_result[0]
        
      else # we've been provided all the data, possibly to make a new pkg in the db
        
        # if the data we were handed didn't come directly from the server, 
        # clean it up and check for errors
        if args[:data_came_from_server]
          pkg_data =  args 
        else
          args[:init] = true # tells the validation method to check all the values needed for initialization
          pkg_data = validate_jss_pkg_for_server(args)
        end
        
        
        if args[:new] then
           raise AlreadyExistsError, "A JSSPkg already exists with installer file #{args[:filename]}" if args[:new] and pkg_files.include? args[:filename]
  
          # do some pkg-speific data checking first
          @local_filepath = args[:local_filepath]
          
          # new ones don't yet have an id
          pkg_data[:id] = nil
          
        end # if :new
        
         
      end # if :lookup
      
      # if we're here and there's no filename or id, its been deleted from the JSS
      # but not from d3... skip it
      raise MissingDataError, "Missing :filename for :id (#{pkg_data[:id]}) " unless pkg_data[:filename] 
      
      # now we have pkg_data with something in it, so fill out the instance vars
      @id = pkg_data[:id]
      @filename = pkg_data[:filename]
      @name = pkg_data[:name]
      @feu = pkg_data[:feu]
      @reboot = pkg_data[:reboot] ? true : false
      @oses = pkg_data[:oses]
      @cpu_type = pkg_data[:cpu_type]
      @removable = pkg_data[:removable] ? true : false
      @info = pkg_data[:info]
      @notes = pkg_data[:notes]
      @stage = pkg_data[:stage]
      @category = pkg_data[:category]
      @cat_id = categories[@category]
      @svr_path = PixJSS::CSHARE_PKGS + @filename
      
      @in_jss = PixJSS.pkg_ids.include? @id
      
      # these will get looked up as needed, see #file_list and #index
      @index = [] 
      @file_list = []
      
      # if we have an id, and we should if we already are in the JSS, always use it as the rest rsrc
      @rest_rsrc = @id ? "packages/id/#{@id}" : "packages/name/#{URI.escape @name}"
  
    end # initialize    
    
    ###
    ### given a hash of pkg data for the JSS, make sure it's OK to be added to the server...
    ### clean it up, set defaults, or raise errors if needed.
    ###
    ### return the same hash, with valid data, and some variations of that data, eg:
    ### 
    ### the data that need to be both comma-separated strings, and arrays, can be provided as either, 
    ### and are returned as both with the same keynames with "_arr" or "_str" appeneded
    ### e.g. :oses  will yield both :oses_str and :oses_arr, for use as needed.
    ###
    ### the :category value should be provided as a string, the :cat_id will be set to the matching JSS id for the category
    ###
    ### when args contains :init=>true, everything is checked, with the assumption 
    ### we're initializing a new pkg to be added to the server.
    ### otherwise, only the item(s) passed in the hash are checked
    ###
    def validate_jss_pkg_for_server (args = {})
      all = args[:init]
      data = args.keys

      if all or data.include? :id
          # id can't be empty unless we're making a new jss db record
          args[:id] = nil if args[:id] == ''
          raise MissingDataError, "Missing Pkg :id for #{args[:filename]}" unless args[:id] or args[:new]
      end
      
      if all or data.include? :filename
          # filename can't be empty
          args[:filename] = nil if args[:filename] == ""
          raise MissingDataError, "Missing Pkg :filename (#{[args[:basename],args[:id],args[:name]].join ', '})" unless args[:filename]
      end

      if all or data.include? :name
          # name? defaults to the filename
          args[:name] = nil if  args[:name] == ''
          args[:name] = args[:filename] unless args[:name] 
          raise MissingDataError, "Missing Pkg :name or :filename (#{[args[:basename],args[:id],args[:name]].join ', '})" unless args[:name]
      end
      
      if all or data.include? :feu
          # feu? defaults to false
          args[:feu] = false if args[:feu].nil? or args[:feu] == ''
          raise InvalidTypeError, ":feu must be boolean 'true' or 'false'" unless args[:feu] == false or args[:feu]  == true
      end
  
      if all or data.include? :reboot
          # reboot? defaults to false
          args[:reboot] = false if args[:reboot].nil? or args[:reboot] == ''
          raise InvalidTypeError, ":reboot must be boolean 'true' or 'false'" unless args[:reboot] == false or args[:reboot]  == true
      end
      
      if all or data.include? :oses
          # oses? Defaults to empty array
          args[:oses] = [] if args[:oses].nil?
        
          # if a new value starts with >=, expand it
          if args[:oses].class == String 
            args[:oses] = expand_min_os(args[:oses]) if args[:oses] =~ /^>=/
          elsif args[:oses].class == Array and not args[:oses].empty?
            args[:oses].map!{|a|  a =~ /^>=/ ? expand_min_os(a) : a }
            args[:oses].flatten!
            args[:oses].uniq!
          end
          
          bothways = to_s_and_a args[:oses]
          raise InvalidTypeError, ":oses must be comma-separted string, or array" if bothways == "type error"
          args[:oses] = bothways[:arrayform]
          args[:oses_arr] = bothways[:arrayform]
          args[:oses_str] = bothways[:stringform]
      end
      
      if all or data.include? :cpu_type
          # cpu_type? defaults to None
          args[:cpu_type] = "None" if args[:cpu_type] == "" or args[:cpu_type].nil?
          raise InvalidTypeError, ":cpu_type must be one of: #{CPU_TYPES.join ', '}" unless CPU_TYPES.include? args[:cpu_type]
      end
      
      if all or data.include? :removable
          # removable? defaults to false
          # even though we usually want to be able to ununstall things, it would be
          # dangerous to do on things like OS updates, so it must be set explicitly.
          # - this triggers an 'indexing' when saving a new pkg
          args[:removable] = false if args[:removable].nil? or args[:removable] == ''
          raise InvalidTypeError, ":removable must be boolean 'true' or 'false'" unless args[:removable] == false or args[:removable]  == true
      end
  
      if all or data.include? :local_filepath
          # local file path? needed if making a new JSS pkg on the server
          if args[:new]  
            args[:local_filepath] = nil if args[:local_filepath] == ''
            raise MissingDataError, ":local_filepath needed to make a new JSSPkg on the server" if args[:local_filepath].nil?
            raise MissingDataError, ":local_filepath - file doesn't exist: #{args[:local_filepath]}" unless File.exist?(args[:local_filepath])
          end
      end
  
      if all or data.include? :stage
          # stage? must be in the STAGES constant, default Testing for Pilots, and Deployable for others
          # defaults to "Testing"
          args[:stage] = "Testing" unless args[:stage]
          raise InvalidTypeError, ":stage must be one of: #{STAGES.join ', ' }" unless STAGES.include? args[:stage]
      end
  
      if all or data.include? :category
          # category? defautls to Unknown
          args[:category] = "Unknown" unless args[:category]
          raise NoSuchItemError, "Category #{args[:category]} is not known to the JSS" unless categories.keys.include? args[:category]
          args[:cat_id] = categories[args[:category]]
      end
  
      if all or data.include? :info
          # info? line breaks should be \r
          args[:info].gsub!(/\n/, "\r") if args[:info]
      end
  
      if all or data.include? :notes
          # notes? line breaks should be \r
          args[:notes].gsub!(/\n/, "\r") if args[:notes]
      end
  
      return args
    end # validate data
    
    
    ###
    ### Save a new pkg to the JSS server and db
    ###
    def save
      return if @in_jss
      
      # make sure the file doesn't already exist - it shouldn't but who knows
      mount_caspershare
      raise AlreadyExistsError, "Package file #{@filename} already exists on the server" if @svr_path.exist?
      
      # make sure the local file exists
      raise  NoSuchItemError, "Local file '#{@local_filepath}' can't be found" unless test(?e, @local_filepath)
      
      # this is a jss pkg, so we have to make the DB recored via REST
      # *YAY* something along the way can't deal with whitespace at the begining of the lines in the xml :-(
      
      
      rest_xml = <<ENDXML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<package>
  <#{RMAP[:name]}>#{@name}</#{RMAP[:name]}>
  <#{RMAP[:category]}>#{@category}</#{RMAP[:category]}>
  <#{RMAP[:filename]}>#{@filename}</#{RMAP[:filename]}>
  <#{RMAP[:info]}>#{@info}</#{RMAP[:info]}>
  <#{RMAP[:notes]}>#{CGI.escapeHTML @notes.to_s}</#{RMAP[:notes]}>
  <#{RMAP[:reboot]}>#{@reboot}</#{RMAP[:reboot]}>
  <#{RMAP[:feu]}>#{@feu}</#{RMAP[:feu]}>
  <#{RMAP[:stage]}>#{@stage}</#{RMAP[:stage]}>
  <#{RMAP[:removable]}>#{@removable}</#{RMAP[:removable]}>
  <#{RMAP[:oses]}>#{to_s_and_a(@oses)[:stringform]}</#{RMAP[:oses]}>
  <#{RMAP[:cpu_type]}>#{@cpu_type}</#{RMAP[:cpu_type]}>
</package>
ENDXML
      
      # make the new record
      #REST_CNX.cnx[@rest_rsrc].post rest_xml, :content_type => 'text/xml'
      REST_CNX.post_rsrc( :rsrc => @rest_rsrc, :xml => rest_xml )
      
      # now re-query our new ID since I can't figure out how to get REST to return it as 
      # part of the POST
      theQuery = "SELECT #{JMAP[:id]} AS my_id FROM #{PKGS_TABLE} WHERE #{JMAP[:filename]} = '#{@filename}'"
      qr = @@db_cnx.query(theQuery)
      @id = qr.fetch_hash["my_id"].to_i
      qr.free
      @rest_rsrc = "packages/id/#{@id}" 
      @jss_id = @id
      
      # if the local file is a bundle .pkg or .mpkg, check that it has a
      # top-level index.bom (Used for http-based installs and casper remote)
      # and make one if not.
      if @local_filepath.to_s =~ /\.m?pkg\/?$/ && File.directory?(@local_filepath)
        unless File.exist? "#{@local_filepath}/index.bom"
          sudo_run "/usr/bin/mkbom '#{@local_filepath}' '#{@local_filepath}/index.bom'"
        end # unless
      end # if @local_filepath.to_s
      
      # time to upload the file...
      FileUtils::cp_r @local_filepath, @svr_path
      
      # it's now in the jss
      @in_jss = true

      
      # Now put the pkg BOM data into the contents table
      if @removable
        self.mk_index 
        self.removable = false
        self.removable = true
      end # if removable
      # and we're done!
      
      # if pkg_files etc have been generated already, refresh them
      pkg_files :refresh  if @@pkg_files
      pkgs :refresh if @@pkgs   
      pkg_ids :refresh  if @@pkg_ids
      return true
    end # save
    
    ###
    ### Delete this pkg from the JSS - this just moves the file and changes the stage...
    ### 
    ### NOTE: If you need to really delete stuff, open Casper Admin.app and empty the trash.
    ### if we ever do delete records from the DB use LIMIT like this:
    ### DELETE FROM `packages` WHERE `package_id` = 72 LIMIT 1
    ###
    def delete
      self.stage = "Deleted"
      mount_caspershare
      
      trashed = CSHARE_DELETED_PKGS + @filename
      
      FileUtils.mv @svr_path.to_s , trashed.to_s, :force => true
      
      @in_jss = false
      # if pkg_files has been generated already, refresh it
      
      pkg_files :refresh => true if @@pkg_files
      pkgs :refresh => true if @@pkgs
      return true
    end
    
    
    ###
    ### Create, or re-create, the BOM index records for this JSSPkg in the JSS Database
    ### 
    ### This is the equivalent of clicking the "index" button in Casper Admin.app, and is
    ### necessary for casper & d3 to be able to uninstall items.
    ###
    ### It can only happen after the item has already been saved to the JSS and has an id in the database.
    ###
    def mk_index
      return nil unless @in_jss
      
      PixJSS.check_connection
      
      # gather the BOM data
      mount_caspershare
      
      # where's the thing we're indexing?
      raise PIXJSSNoSuchItemError, "The file #{@filename} is missing from the Casper server" unless @svr_path.exist?
      
      
      # get the index data
      bom_lines = ''
      
      if @filename =~ /\.m?pkg$/
      
        # if the thing is a pkg bundle, find and read all the bom files it contains
        if (@svr_path + "Contents").directory?
          (@svr_path + "Contents").find do |path|
            bom_lines += `echo; /usr/bin/lsbom -p fugTsMc '#{path}'` if path.to_s =~ /\.bom$/
          end
          
        else
          # else its a flat file - so do it using pkgutil
          # NOTE I'm not sure this will get everything on flat mpkgs which have more than one
          # but I think it will
          bom_lines = `/usr/bin/lsbom -p fugTsMc \`/usr/sbin/pkgutil --bom '#{@svr_path}'\``
        end # if test -d
  
      elsif @filename =~ /\.dmg$/
        
        # if its a .dmg, mount it, make a tmp bom file, and read that
        mnt_point = sudo_run "/usr/bin/hdiutil attach -readonly -nobrowse -noautoopen -owners on '#{@svr_path}'  | /usr/bin/tail -1 | /usr/bin/cut -f3"
        mnt_point.strip!
        raise FileServiceError, "There was a problem mounting the image #{@filename}" unless test(?d, mnt_point)
        
        tmp_bom = "/tmp/#{@filename}.#{$$}.bom"
        sudo_run "rm -rf '#{tmp_bom}'"
        sudo_run "/usr/bin/mkbom '#{mnt_point}' '#{tmp_bom}'"
        bom_lines = sudo_run "/usr/bin/lsbom -p fugTsMc '#{tmp_bom}'"
        
        sudo_run "/usr/bin/hdiutil detach '#{mnt_point}'"
        sudo_run "rm -rf '#{tmp_bom}'"
      
      else
        raise InvalidTypeError, "#{@filename} is doesn't looks like a .pkg or .dmg. Try Casper Admin to index it."
      end # if filename .pkg
      
      unless bom_lines.empty?
      
        # split the bom lines, eliminating leading dots on the way, except the first which we'll get below.
        index_records = bom_lines.split "\n"        
        
        # reset our local lists of files
        @index = []
        @file_list = []
        
        # the start of the SQL insert statement
        insert_stmt = "INSERT INTO #{PKG_CONTENTS_TABLE} (package_id,file,owner_name,group_name,modification_date,size,mode,checksum) VALUES"
        insert_vals = []

        
        # loop through the bom data and make a new record for each line
        index_records.each do |line|
          
          next if line.empty?

          #break out the data for each item
          (path,uid,gid,modtime,size,mode,checksum) = line.split "\t"
          
          # if the path is just a dot (usually the first one)
          # make it a /  = all d3 pkgs start at the root
          if path == "."
            clean_path = "/" 
          elsif path.start_with? "."
            clean_path = path.sub ".", ""
          else
            clean_path = path
          end
          
          # rebuild our local lists of files
          @index << { 'path' => clean_path,
          'uid' => uid,
          'gif' => gid,
          'modtime' => modtime,
          'size' => size,
          'mode' => mode }
          
          @file_list << clean_path unless mode.start_with? "d"
          
          # JSS stores modtime as string w/o the weekday 
          modtime.gsub!(/^(Sun|Mon||Tue|Wed|Thu|Fri|Sat) /, '') if defined? modtime
          
          insert_vals << "('#{@id}','#{Mysql.quote clean_path}','#{uid}','#{gid}','#{modtime}','#{size}','#{mode}','#{checksum}')"
          
        end # do line
        
        # first delete any existing index records for this pkg
        stmt = @@db_cnx.prepare "DELETE FROM #{PKG_CONTENTS_TABLE} WHERE package_id = #{@id}"
        stmt_result = stmt.execute
        
        # now insert the new values
        stmt = @@db_cnx.prepare(insert_stmt + " " + insert_vals.join(','))
        stmt_result = stmt.execute
        
      end # unless bom_lines == ''
      
      return true
    end #mk_index
    
    ###
    ### return an array of strings representing the paths
    ### to each files installed by this pkg, if the pkg
    ### has been indexed
    ### return an empty array if not indexed
    ###
    def file_list
      if indexed?
        @file_list = []
        # grab each filename if the file isn't a directory
        self.index.each do |h| 
          @file_list << h["path"] unless h["mode"].start_with? 'd' 
        end
        @file_list.sort!
      end
      return @file_list
    end
    
    ###
    ### return an array of hashes representing BOM info
    ### for each item installed by this pkg, if the pkg
    ### has been indexed.
    ### return an empty array if not indexed
    ###
    def index (refresh = nil)
      @index = [] if refresh
      return @index unless @index.empty?
      
      PixJSS.check_connection

      q = "SELECT 
          file AS path,
          owner_name AS uid,
          group_name AS gid,
          modification_date AS modtime,
          size,
          mode
        FROM  #{PKG_CONTENTS_TABLE} WHERE package_id = #{@id}"
        
      qr = @@db_cnx.query(q)
      
      if qr.count > 0 
        qr.each_hash { |h| @index << h }
      end
      
      qr.free
      return @index
    end

    
    ###
    ### Is this pkg 'indexed' in the jss, so that it can be removable?
    ### (or, if it hasn't been saved yet, has the index been generated?)
    ###
    def indexed?
      not index.empty?
    end # indexed?
  
    
    ###
    ### Change the installer pkg file name in the JSS - make sure the file exists on the server!
    ### new_val = string
    ###
    def filename= (new_val = @filename)
      PixJSS.check_connection
      
      # do nothing if nothing's changing
      return if new_val == @filename
      
      # validate
      new_val = validate_jss_pkg_for_server(:filename => new_val)[:filename]
      
      # first, change the real filename on the server
      mount_caspershare
      raise NoSuchItemError, "Package file #{@filename} does't exist on the server" unless @svr_path.exist?
      raise AlreadyExistsError, "Package file #{new_val} already exists on the server" if @svr_path.exist?
      @svr_path.rename  "#{CSHARE_PKGS}/#{new_val}"
      
      # now update the jss
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:filename], :value => new_val) if @in_jss
      
      # and update self
      @filename = new_val
      
      # display name needs to change too, since we keep them in sync by default
      self.name = @filename
      
      # refresh things based on pkg filenames, if needed
      pkg_files :refresh  if @@pkg_files
      pkgs :refresh  if @@pkgs
      
    end #filename=
    
    ###
    ### Change the display name in the JSS - usually this should match the @filename
    ### new_val = string
    ###
    def name= (new_val = @filename)
      PixJSS.check_connection
      new_val = validate_jss_pkg_for_server(:name => new_val)[:name]
      
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:name], :value => new_val) if @in_jss
      @name = new_val
      
      # if we have a name-based rest rsrc, update it
      @rest_rsrc = "packages/name/#{@name}" if @rest_rsrc =~ /\/name\//
    end #name=
    
    ###
    ### Change the Fill Existing Users field in the JSS
    ### new_val = boolean
    ###
    def feu= (new_val = @feu)
      PixJSS.check_connection
      # validate
      new_val = validate_jss_pkg_for_server(:feu => new_val)[:feu]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:feu], :value => new_val.to_s) if @in_jss
      @feu = new_val
    end #fill_existing_users=
    
    ###
    ### Change the reboot-required field in the JSS
    ### new_val = boolean
    ###
    def reboot= (new_val = @reboot)
      # validate
      new_val = validate_jss_pkg_for_server(:reboot => new_val)[:reboot]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:reboot], :value => new_val) if @in_jss
      @reboot = new_val
    end #reboot_required=
    
    ###
    ### Change the os_requirements field in the JSS
    ### E.g. 10.5, 10.5.3, 10.6.x
    ### new_val =  comma-separated string, or array of os versions
    ### 
    ### Extra-casper feature: Minumum OS's can now be specified as a 
    ### string using the notation ">=10.6.7" See the expand_min_os method 
    ### (called by the validate_jss_pkg_for_server method) for details.
    ###
    def oses= (new_val = @oses)
      # validate
      clean = validate_jss_pkg_for_server(:oses => new_val)
      valarr = clean[:oses_arr]
      valstr = clean[:oses_str]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:oses], :value => valstr) if @in_jss
      @oses = valarr
    end #os_requirements=
    
    
    
    ###
    ### Change the required processor field in the JSS
    ###
    ### new_val = string, one of "None", "x86", or "PowerPC"
    ###
    def cpu_type=(new_val = @cpu_type)
      new_val = validate_jss_pkg_for_server(:cpu_type => new_val)[:cpu_type]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:cpu_type], :value => new_val) if @in_jss
      @cpu_type = new_val
    end #info=
    
    ###
    ### Change the 'allow to be uninstalled' field in the JSS
    ###
    ### new_val = boolean
    ###
    def removable= (new_val = @removable)
      new_val = validate_jss_pkg_for_server(:removable => new_val)[:removable]
      
      if new_val == true
        # we have to be saved and indexed before we can be made removeable
        mk_index unless indexed?
        raise  RuntimeError, "JSSPkg must be saved and indexed before it can be removable." unless indexed?
      end # if newval == true
      
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:removable], :value => new_val) if @in_jss
      @removable= new_val
      
    end #allow_uninstalled=
    
    ###
    ### Change the info field in the JSS
    ### for d3 pkgs, this should always contain a line "basename: xxxxx"
    ### and may contain a line "swupdate: xxx"
    ### 
    ### new_val = string, line breaks should be \r, not \n    
    ###
    def info=(new_val = @info)
      new_val = validate_jss_pkg_for_server(:info => new_val)[:info]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:info], :value => new_val) if @in_jss
      @info = new_val
    end #info=
    
  
    
    ###
    ### Change the notes field in the JSS
    ###
    ### new_val = string, line breaks should be \r, not \n
    ###
    def notes=(new_val = @notes)
      new_val = validate_jss_pkg_for_server(:notes => new_val)[:notes]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:notes], :value => new_val) if @in_jss
      @notes = new_val
    end #info=
    
    ###
    ### Change the stage in the JSS
    ###
    ### new_val = string, one of "Deployable", "Non-Deployable", "Testing", "Deleted"
    ###
    def stage=(new_val = @stage)
      new_val = validate_jss_pkg_for_server(:stage => new_val)[:stage]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:stage], :value => new_val) if @in_jss
      @stage = new_val
    end #info=
    
    ###
    ### Change the category in the JSS
    ###
    ### new_val = string, must be one listed by 'categories.keys'
    ###
    def category=(new_val = @category)
      clean = validate_jss_pkg_for_server(:category => new_val)
      new_val = clean[:category]
      new_cat_id = clean[:cat_id]
      REST_CNX.put_rsrc(:rsrc => @rest_rsrc, :attrib => RMAP[:category], :value => new_val) if @in_jss
      @category = new_val
      @cat_id = new_cat_id
    end #category=
  
    ###
    ### This causes the pkg to be installed in a JAMF-ish way, via the jamf command.
    ### If verbose=true, stderr and stdout go to stdout
    ###
    ### Returns 0 if both installer and jamf exit zero, otherwise 1
    ###
    def install (verbose = false)
      #require 'pty' if verbose
      
      Pixar.must_be_root "You must be root to install packages from Casper"
      
      # are we doing "fill existing users"?
      do_feu = self.feu? ? "-feu" : ""
      
      # use jamf binary to install the pkg via http
      http_command = "#{PixJSS::JAMF_BINARY}  install -package '#{@filename}' -path '#{PixJSS::HTTP_PKGS_URL}'  -target / #{do_feu} -showProgress ; echo jamfexit $?"

      exit_code = verbose ? install_verbosely(http_command) : exit_code = install_silently(http_command)
      
      # if exit_code != 0
      
        # just return the exit code, we don't want to mount the casper server ever
        
        # if that failed, mount the server and try it directly
       #  mount_caspershare
#         direct_command = "#{PixJSS::JAMF_BINARY}  install -package '#{@filename}' -path '#{PixJSS::CSHARE_PKGS}'  -target / #{do_feu} -showProgress ; echo jamfexit $?"
#         
#         if verbose
#           puts "http install failed, trying direct mount of the server."
#           exit_code = install_verbosely(direct_command)
#         else
#           exit_code = install_silently(direct_command)
#         end
#         
#       end

      return exit_code 
    end #run
    
    
    
    ###
    ### This causes the pkg to be uninstalled in a JAMF-ish way, via the jamf command.
    ### If verbose=true, stderr and stdout go to stdout
    ###
    ### Returns the Process::Status of the finished 'jamf uninstall' command.
    ###
    ### NOTE: the jamf binary must be run as root to uninstall pkgs.
    ###
    def uninstall (verbose = false)
      Pixar.must_be_root "You must be root to uninstall packages from the JSS"
      
      # are we verbose?
      redirect = verbose ? "" : "&> /dev/null"
      
      # are we doing "fill existing users"?
      do_feu = self.feu? ? "-feu" : ""
      
      # use jamf binary to uninstall the pkg
      system "#{JAMF_BINARY}  uninstall -target / -id '#{@id}' #{do_feu} #{redirect}"
      
      return $?
    end #uninstall
    
    # Private Methods below here
    private
    
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
        installer_exit = nil
        jamfexit = nil
        # using pty spawn allows us to get unbuffered output from the command
        # and process it before showing it to the user.
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
    ### Returns an Array of OS versions for use with Caspers OS requirements.
    ### Minumum OS's can now be specified using the notation ">=10.6.7" 
    ### If the value being checked starts with >= then it will be expanded thus:
    ### ["10.6.7", "10.6.8","10.6.9","10.6.10","10.6.11","10.6.12","10.6.13","10.6.14","10.6.15","10.7.x","10.8.x","10.9.x","10.10.x" ...]
    ### (up to "10.19.x")
    ### 
    ### i.e. the given minor version is taken up to maint-release 15, and then the minor version itself is taken up to 19.
    ### It's unlikely that this library will still be in use as-is by the release of OS X 10.19.15
    ### Hopefully well before then JAMF will implement a "minimum OS" in the JSS itself.
    ###
    ### 
    def expand_min_os (min_os)
      min_os.delete! ">="
      # split the version into major, minor and maintenance release numbers
      (maj,min,maint) = min_os.split(".")
      maint = "x" if maint.nil? or maint == "0"
      
      # if the maint release number is an "x" just start the list of OK OS's with it
      if maint == "x" 
        ok_oses = [maj + "." + min.to_s + ".x"]
      
      # otherwise, start with it and explicitly add all maint releases up to 15 
      # (and hope apple doesn't do more than 15 maint releases for an OS)
      else
        ok_oses = []
        (maint.to_i..15).each do |m|
          ok_oses <<  maj + "." + min +"." + m.to_s
        end # each m
      end
      
      # now account for all OS X versions starting with 10. 
      # up to at least 10.19.x
      ((min.to_i + 1)..19).each do |v|
        ok_oses <<  maj + "." + v.to_s + ".x"
      end # each v
      return ok_oses
    end
    
    
    
  end # class JSSPkg
end # module
