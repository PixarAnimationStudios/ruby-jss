# = script.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A class representing a Script in the JSS. Access is via the REST API and/or
# direct SQL to the database, depending on the need.
#

module PixJSS
  
  #####################################
  # Constants
  #####################################
  
  ###
  ### Paths & Executables
  ###
  
  # The script storage folder on the CasperShare volume
  CSHARE_SCRIPTS = CASPERSHARE_MNTPNT + "Scripts"
  
  # The script storage folder on the CasperShare volume
  CSHARE_DELETED_SCRIPTS = CASPERSHARE_MNTPNT + "Casper Data/Deleted Scripts"
  
  ###
  ### URLS
  ###
  
  # The URL for http downloading of scripts from the Casper server
  HTTP_SCRIPTS_URL="http://#{JSS_HOST}/#{CSHARE}/Scripts"
  
  
  ###
  ### Mappings 
  ### the common symbols used throughout PixJSS mapped to
  ### the names they use in various database tables and REST resources
  ###
  
  # The scripts table in the JSS
  SCRIPTS_TABLE = "scripts"
  
  # The mapping of standardized symbols used throughout this module
  # to field names in the JSS scripts table
  SCRIPT_ATTRS_TO_JSS_FIELDS = {
            :id => 'script_id',
            :filename => 'file_name',
            :name => 'display_name',
            :oses => 'os_requirements',
            :priority => 'priority',
            :info => 'info',
            :notes => 'notes',
            :stage => 'stage',
            :cat_id => 'group_id'
  }
  
  # A shorter but less descriptive name for the SCRIPT_ATTRS_TO_JSS_FIELDS constant
  SMAP = SCRIPT_ATTRS_TO_JSS_FIELDS
  
  
  #####################################
  # Module Variables
  #####################################
  
  # a hash of JSSScript objects keyed by filename, for all scripts in the JSS
  # populated by the jss_scripts method, q.v.
  @@scripts = nil
    
  # an array of script filenames (strings) for all scripts in the JSS
  # populated by the scripts method, q.v.
  @@script_files = nil
  
  #####################################
  # Module Methods
  #####################################

  ###
  ### Return an array of hashes with all the server data needed to 
  ### create one or more JSSScript objects.
  ###
  ### If args contain :filename => somename or :id => someid, then one 
  ### script will be queried, otherwise all will be.
  ###
  def script_query (args ={})
  
    check_connection
    
    if args[:id] 
      where_clause = "AND #{SMAP[:id]} = '#{args[:id]}'"
    elsif args[:filename] 
      where_clause = "AND #{SMAP[:filename]}= '#{args[:filename]}'"
    else
      where_clause = ""
    end
    
    queried_scripts = []
    
    the_query = <<-ENDQUERY
      SELECT
        #{SMAP[:id]},
        #{SMAP[:filename]},
        #{SMAP[:name]},
        #{SMAP[:oses]},
        #{SMAP[:priority]},
        #{SMAP[:info]},
        #{SMAP[:notes]},
        #{SMAP[:stage]},
        #{SMAP[:cat_id]}
      FROM #{SCRIPTS_TABLE}
      WHERE #{SMAP[:stage]} != 'Deleted'
      #{where_clause}
    ENDQUERY

    # execute the query and loop through the resulting rows as hashes
    @@db_cnx.query(the_query).each_hash do |db_data|
      
      # clean up - mysql data is all strings. sadface
      script_data = clean_jss_db_data(db_data, :script)
         
      # add the data end of the big array
      queried_scripts.push({
        :data_came_from_server => true,
        :id => script_data[SMAP[:id]],
        :filename => script_data[SMAP[:filename]],
        :name => script_data[SMAP[:name]],
        :oses => script_data[SMAP[:oses]],
        :priority => script_data[SMAP[:cpu_type]],
        :info => script_data[SMAP[:info]],
        :notes => script_data[SMAP[:notes]],
        :stage => script_data[SMAP[:stage]],
        :category => script_data[:category], # the cleanup method converts cat_ids to names
        })
        
    end # query.each hash    
    queried_scripts
    
  end #jss script query
    
  ###
  ### Return a hash of JSSScript objects 
  ### for all scripts available on the server, keyed off their filenames
  ###
  ### If this list has been generated already in your script, it will not be regenerated
  ### at every call, so as to not bother the server with a new query every time.
  ### If you want to force a new query, just provide :refresh => true
  ###
  def scripts (refresh = nil)
    @@scripts = nil if refresh
    return @@scripts if @@scripts
    
    # start empty
    @@scripts = {}
    
    # calling jss_script_query with no args returns all of them
    script_query.each { |script| @@scripts[script[:filename]] = JSSScript.new(script) }
    
    return @@scripts
  end # jss_scripts

  
  ###
  ### Return an array of the script filenames in the JSS
  ###
  def script_files (refresh = nil)  
    @@script_files = nil if refresh
    return @@script_files if @@script_files
    
    check_connection
    
    # start empty
    @@script_files = []
    theQuery = "SELECT #{JMAP[:filename]} FROM #{SCRIPTS_TABLE} WHERE #{SMAP[:stage]} != 'Deleted'"
    # execute the query
    @@db_cnx.query(theQuery).each {|s| @@script_files.push s[0] }
    @@script_files
  end


  #####################################
  # Classes
  #####################################
  
  ### 
  ### A Script in the JSS
  ### 
  ###
  ### Reading data about packages is done via MySQL, for speed & flexibility
  ### Writing data to the JSS is also done via MySQL, because currently
  ### the REST API doesn't support writing data for scripts.
  ###
  ### When instantiating this object, a JSS script filename or id must be provided.
  ### Providing :lookup => true causes all the rest of the data to be queried
  ### from the JSS database.
  ###
  ### without :lookup => true, it is assumed that all the remaining data will be
  ### provided in the args. See the PixJSS::SCRIPT_ATTRS_TO_JSS_FIELDS constant for the 
  ### applicable keynames. The description of each keyname can be found
  ### in the attributes of PixJSS::JSSScript,
  ### 
  ### If :new => true is provided, a :filename is required as well as a :local_filepath 
  ### pointing at the script file to be uploaded.
  ### The file will be uploaded, and  new script will be added to the JSS DB 
  ### when the 'save' method is called, as if you had dragged it into Casper Admin
  ### and chosen "Save"
  ### The :filename given must not (obviously) already exist in the JSS scripts table.
  ### 
  class JSSScript
    include PixJSS
    
    # Integer- the id number of the script in the JSS
    attr_reader :id
    
    # String - the filename of the script on the Casper server
    attr_reader :filename
    
    # String - the display-name of the script
    attr_reader :name
    
    # Array of Strings - the OS versions this can be run on. For all minor versions, the format is 10.5.x
    attr_reader :oses
    
    # String - either 'Before' or 'After'.
    attr_reader :priority
  
    # String - the info field for this script
    attr_reader :info
    
    # String - the notes field for this script
    attr_reader :notes
    
    # String - the stage of this script in Casper Admin (Deployable,etc)
    attr_reader :stage
    
    # String - the category of this script, stored in the JSS as the id number from the categories table
    attr_reader :category
    
    # Pathname - where this file is located on the mounted CasperShare volume
    attr_reader :svr_path
    
    ###
    ### See the SCRIPT_ATTRS_TO_JSS_FIELDS constant for the symbols used as arg keys for instantiation
    ###
    def initialize (args = {})
      raise MissingDataError, "Missing :filename or :id" unless (args[:filename] or args[:id])
      if args[:lookup] then # we need to query for the data for one JSSScript
        
        search_item = args[:filename] ? args[:filename] : args[:id]
        search_result = script_query(:id => args[:id], :filename => args[:filename])
        
        raise NoSuchItemError, "Not found: JSS script #{search_item}" if search_result.count == 0
        script_data = search_result[0]
        
      else # we've been provided all the data, possibly to make a new pkg in the db
        
        # if the data we were handed didn't come directly from the server, 
        # clean it up and check for errors
        if args[:data_came_from_server]
          script_data =  args 
        else
          args[:init] = true # tells the validation method to check all the values needed for initialization
          script_data = validate_jss_script_for_server args
        end
        
          
        if args[:new] then # yes, we're gonna make a new one.
        
          # do some script-specific data checking first
          raise MissingDataError, ":filename needed to make a new JSSScript on the server" unless args[:filename]
          raise AlreadyExistsError, "A JSSScript already exists with file #{args[:filename]}" if script_files.include? args[:filename]
          raise MissingDataError, ":local_filepath needed to make a new JSSScript on the server" unless args[:local_filepath]
          @local_filepath = args[:local_filepath]
          
          
          
          # new ones don't yet have an id
          script_data[:id] = nil
          
          # method 'save' won't do anything if this isn't set.
          @make_new_jss = true
        end # if args :new
      end # if :lookup
      
      # now we have script_data with something in it, so fill out the instance vars
      @id = script_data[:id]
      @filename = script_data[:filename]
      @name = script_data[:name]
      @oses = script_data[:oses]
      @priority = script_data[:priority]
      @info = script_data[:info]
      @notes = script_data[:notes]
      @stage = script_data[:stage]
      @category = script_data[:category]
      @cat_id = categories[@category]
      @svr_path = CSHARE_SCRIPTS + @filename
      
      @in_jss = script_files.include? @filename
    end # initialize    
    
    ###
    ### Save a new script to the JSS server and db
    ###
    def save
      return if @in_jss
      return unless @make_new_jss
      
      # make sure the file doesn't already exist - it shouldn't but who knows
      raise AlreadyExistsError, "Script file #{@filename} already exists on the server" if @svr_path.exist?
      
      # this is a jss script, so we have to make the DB recored via mysql, until jamf supports it via REST
      # Note, this data was already validated in 'initialize'
      stmt = @@db_cnx.prepare <<-ENDINSERT
        INSERT INTO #{SCRIPTS_TABLE} (
        #{SMAP[:filename]},
        #{SMAP[:name]},
        #{SMAP[:oses]},
        #{SMAP[:priority]},
        #{SMAP[:info]},
        #{SMAP[:notes]},
        #{SMAP[:stage]},
        #{SMAP[:cat_id]}
        ) VALUES (
        '#{Mysql::quote @filename.to_s}',
        '#{Mysql::quote @name.to_s}',
        '#{Mysql::quote to_s_and_a(@oses)[:stringform]}',
        '#{Mysql::quote @priority.to_s}',
        '#{Mysql::quote @info.to_s}',
        '#{Mysql::quote @notes.to_s}',
        '#{Mysql::quote @stage.to_s}',
        '#{Mysql::quote @cat_id.to_s}'
        )
      ENDINSERT
      stmt_result = stmt.execute
      
      # now we have our new ID
      @id = stmt_result.insert_id
      
      # time to upload the file...
      # mount the file server
      mount_caspershare
      FileUtils::cp @local_filepath, @svr_path.to_s
      
      # and we're done!
      @in_jss = true
      @make_new_jss = false
      
      # refresh things based on  script filenames if needed
      script_files :refresh if @@script_files
      scripts :refresh  if @@scripts
      return true
    end # save
    
    ###
    ### Delete a script from the JSS - this just moves the file and changes the stage...
    ### 
    ### NOTE: If you need to really delete stuff, open Casper Admin.app and empty the trash.
    ### if we ever do delete records from the DB use LIMIT like this:
    ### DELETE FROM `scripts` WHERE `script_id` = 72 LIMIT 1
    ###
    def delete
      
      self.stage = "Deleted"
      mount_caspershare      
      @svr_path.rename(CSHARE_DELETED_SCRIPTS + @filename)
      
      @in_jss = false 
      # refresh things based on  script filenames if needed
      script_files :refresh if @@script_files
      scripts :refresh  if @@scripts
      return true
    end
    
    ###
    ### given a hash of script data for the JSS, make sure it's OK to be added to the server...
    ### clean it up, set defaults, or raise errors if needed.
    ###
    ### return the same hash, with valid data, and some variations of that data, eg:
    ### 
    ### the data that need to be both comma-separated strings, and arrays, can be provided as either, 
    ### and are returned as both with the same keynames with "_arr" or "_str" appeneded
    ### e.g. :oses  will yield both :oses_str and :oses_arr, for use as needed.
    ###
    ### the :category value should be provided as a string, 
    ### the :cat_id will be set to the matching JSS id for the category
    ###
    ### when args contains :init=>true, everything is checked, with the assumption 
    ### we're initializing a new script to be added to the server.
    ### otherwise, only the item(s) passed in the hash are checked
    ###
    def validate_jss_script_for_server (args = {})
      all = args [:init]
      data = args.keys
      
      if all or data.include? :id
          # id can't be empty unless we're making a new jss db record
          args[:id] = nil if args[:id] == ''
          raise MissingDataError, "Missing :id for #{args[:filename]}" unless args[:id] or args[:new]
      end
      
      if all
          # filename? can't be empty if we're 
          args[:filename] = nil if args[:filename] == ""
          raise MissingDataError, "Missing :filename (#{[args[:id],args[:name]].join ', '})" unless args[:filename]
      end
      
      if all or data.include? :name
          # name? defaults to the filename
          args[:name] = nil if  args[:name] == ''
          args[:name] = args[:filename] if args[:name].nil? 
          raise MissingDataError, "Missing :name or :filename (#{[args[:id],args[:name]].join ', '})" unless args[:name]
      end
      
      if all or data.include? :priority
          # priority? defaults to After
          args[:priority] = "After" if args[:priority] == "" or args[:priority].nil?
          raise InvalidTypeError, ":priority must be one of: #{SCRIPT_PRIORITIES.join ', '}" unless SCRIPT_PRIORITIES.include? args[:priority]
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
      
      if all or data.include? :stage
          # stage must be ons of the strings in the STAGES constant
          # defaults to "Testing"
          args[:stage] = "Testing" if args[:stage].nil? or args[:stage] == ""
          raise InvalidTypeError, ":stage must be one of: #{STAGES.join ', ' }" unless STAGES.include? args[:stage]
          
      end
      
      if all or data.include? :oses
          # oses? Defaults to empty array
          args[:oses] = [] if args[:oses].nil?
          bothways = to_s_and_a args[:oses]
          raise InvalidTypeError, "oses must be comma-separted string, or array" if bothways == "type error"
          args[:oses] = bothways[:arrayform]
          args[:oses_arr] = bothways[:arrayform]
          args[:oses_str] = bothways[:stringform]
      end
      
      if all or data.include? :local_filepath
          # local file path? needed if making a new JSS pkg on the server
          args[:local_filepath] = nil if args[:local_filepath] == ''
          raise MissingDataError, ":local_filepath needed to make a new JSSScript on the server" if args[:new] and self.class == JSSScript and args[:local_filepath].nil?
          raise MissingDataError, ":local_filepath - file doesn't exist: #{args[:local_filepath]}" unless File.exist?(args[:local_filepath])
      end
  
      return args
    end # validate data
    
    ###
    ### Change the script file name in the JSS - make sure the file exists on the server!
    ###
    ### new_val = string
    ###
    def filename=(new_val = @filename)
      
      # do nothing if nothing's changing
      return if new_val == @filename
      
      # validate
      new_val = validate_jss_script_for_server(:filename => new_val)[:filename]
      
      # first, change the real filename on the server
      mount_caspershare
      raise NoSuchItemError, "Script file #{@filename} does't exist on the server" unless  @svr_path.exist?
      raise AlreadyExistsError, "Script file #{new_val} already exists on the server" if  @svr_path.exist?
       @svr_path.rename  "#{CSHARE_SCRIPTS}/#{new_val}"
      
      # now update the jss
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:filename]} = '#{new_val}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry
      @filename = new_val
      
      # refresh things based on script filenames if needed
      script_files :refresh  if @@script_files
      scripts :refresh  if @@scripts
    end #name=
    
    ###
    ### Change the display name in the JSS - usually this should match the @filename
    ###
    ### new_val = string
    ###
    def name=(new_val = @filename)
      clean = validate_jss_script_for_server(:name => new_val)
      safeclean = Mysql::quote clean[:name]
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:name]} = '#{safeclean}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry
      @name = clean[:name]
    end #name=
    
    ###
    ### Change the os_requirements field in the JSS
    ### E.g. 10.5, 10.5.3, 10.6.x
    ###
    ### new_val =  comma-separated string, or array of os versions
    ###
    def oses=(new_val = @oses)
      clean = validate_jss_script_for_server(:oses => new_val)
      safeclean = Mysql::quote clean[:oses_str]
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:oses]} = '#{safeclean}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry      
      @oses = clean[:oses_arr]
    end #os_requirements=
    
    ###
    ### Change the priority field in the JSS
    ###
    ### new_val = string, one of "Before" or "After"
    ###
    def priority=(new_val = @priority)
      clean = validate_jss_script_for_server(:priority => new_val)
      safeclean = Mysql::quote clean[:priority]
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:priority]} = '#{safeclean}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry      
      @priority = clean[:priority]
    end #info=
    
    ###
    ### Change the info field in the JSS
    ###
    ### new_val = string, line breaks should be \r, not \n
    ###
    def info=(new_val = @info)
      safe = Mysql::quote new_val
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:info]} = '#{safe}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry
      @info = new_val
    end #info=
    
    ###
    ### Change the notes field in the JSS
    ###
    ### new_val = string, line breaks should be \r, not \n
    ###
    def notes=(new_val = @notes)
      safe = Mysql::quote new_val
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:notes]} = '#{safe}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry
      @notes = new_val
    end #info=
    
    ###
    ### Change the stage in the JSS
    ###
    ### new_val = string, one of those in STAGES
    ###
    def stage=(new_val = @stage)
      clean = validate_jss_script_for_server(:stage => new_val)
      safeclean = Mysql::quote clean[:stage]
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:stage]} = '#{safeclean}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry
      @stage = clean[:stage]
    end #stage  
    
    ###
    ### Change the category in the JSS
    ###
    ### new_val = string, must be one listed by 'categories.keys'
    ###
    def category=(new_val = @category)
      clean = validate_jss_script_for_server(:category => new_val)
      new_cat_id = clean[:cat_id]
      update_qry = "UPDATE #{SCRIPTS_TABLE} SET #{SMAP[:cat_id]} = '#{new_cat_id}' WHERE #{SMAP[:id]} = '#{@id}'"
      @@db_cnx.query update_qry
      @category = clean[:category]
      @cat_id = new_cat_id
    end #category=
    
    ###
    ### This causes the script to be run in a JAMF-ish way, via the jamf command.
    ### Any arguments needed should be provided either as a string 
    ### or an array of strings
    ### e.g.  "-f -b baz --bim=bam"  or [ "-f", "-b", "baz", "--bim=bam"]
    ###
    ### Be sure you understand how the jamf binary deals with arguments 
    ### (see 'jamf help runScript')
    ###
    ### if verbose = true, any stdout and stderr (of the jamf commmand,
    ### which usually includes the stdout/stderr of the script itslf)
    ### go to stdout, otherwise to /dev/null
    ### 
    ### Returns the exit code of the script, or -1 if the 'jamf runScript' itself failed.
    ###
    def run (script_args = nil, verbose = false)
      require 'pty' if verbose
      
      Pixar.must_be_root "You must be root to run scripts from the JSS"
      
      # script args?
      script_args = script_args.join(" ") if script_args.class == Array
      
      script_cmd = "#{JAMF_BINARY} runScript -script '#{@filename}' -path '#{HTTP_SCRIPTS_URL}' #{script_args}"
      
      script_exit = -1
      jamf_exit = 1
      
      if verbose
        # use a pseudo terminal so that we can both 
        # process, and display the output of the script command
        # in real time
        PTY.spawn(script_cmd + ";echo jamfexit $?" ) do |sout,sin,pid|
          sout.each do |line| 
            case line
              when /Script exit code: (\d+)/
                script_exit = $1.to_i 
                puts line
              when /jamfexit (\d+)/
                jamf_exit = $1.to_i 
              else 
                puts line
            end # case
          end # sout.each
        end # PTY.spawn
      
      else # not verbose
        output = `#{script_cmd}`
        jamf_exit = $?.exitstatus
        output =~ /Script exit code: (\d+)/
        script_exit = $1.to_i if $1
      end 
      
      return -1 if jamf_exit > 0
      return script_exit.to_i
      
    end #run
    
  end # class JSSScript
end # midule
