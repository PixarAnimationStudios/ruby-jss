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
  ### A Script in the JSS
  ### 
  ### When instantiating a script, :data, :id or :name must be provided
  ### :id => <id> or :name => <script name> will cause a lookup 
  ### for that script in the API
  ###
  ### :data must be the JSON response from a previous API lookup for a script.
  ###
  ### Changes to existing values remain local until #update is called, which
  ### saves them to the JSS.
  ###
  ### To create a script that doesn't yet exist in the JSS, use :id => :new
  ### and provide a unique :name. Other values should be set via the setter
  ### methods before calling #create, which will create the script in the JSS.
  ### 
  ### Here are the keys returned by a JSON API query for a script:
  ###
  ### :category=>"d3-preflight",
  ### :filename=>"pixit-507-2.d3pre"
  ### :id=>137,
  ### :info=>"",
  ### :name=>"pixit-507-2.d3pre",
  ### :notes=>"",
  ### :os_requirements=>"",
  ### :parameters=>{},
  ### :priority=>"Before",
  ###
  ### If script contents (aka code) are saved in the database, and you have database access with JSS::DB_CNX
  ### then the #fetch_code, #code=, and #save_code methods can be used to work with that code.
  ### If JSS::DB_CNX.connected? is true when instantiated, #fetch_code will be called automatically
  ### when the script already exists in the JSS.
  ###
  ### If your scripts are stored on the master distribution point, you can use #upload_master_file to
  ### save it to the server, and #delete_master_file to delete it from the server.
  ###
  ### See also JSS::APIObject
  ###
  class Script < JSS::APIObject
    
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
    RSRC_BASE = "scripts"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :scripts
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :script
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:parameters, :filename, :os_requirements ]
    
    ### The script storage folder on the distribution point, if used
    DIST_POINT_SCRIPTS_FOLDER = "Scripts"    
    
    ### Priority to use for running the script in relation to other actions during imaging
    PRIORITIES = [ 'Before', 'After','At Reboot']
    
    ### which is default?
    DEFAULT_PRIORITY = "After"
    
    ### The keys used in the @parameters Hash
    PARAMETER_KEYS = [:parameter4, :parameter5, :parameter6,:parameter7, :parameter8, :parameter9, :parameter10, :parameter11]
    
    #####################################
    ### Attributes
    #####################################
  
    
    ### String the file name of the script, if stored in a Distr. point
    attr_reader :filename
    
    ### Array of Strings - the OS versions this can be installed onto. For all minor versions, the format is 10.5.x
    attr_reader :os_requirements
    alias oses os_requirements
    
    ### String - either 'Before' or 'After' or "At Reboot".
    attr_reader :priority
  
    ### String - the info field for this script
    attr_reader :info
    
    ### String - the notes field for this script
    attr_reader :notes
    
    ### String - the category of this script, stored in the JSS as the id number from the categories table
    attr_reader :category
    
    ### Hash - Labels to use for script parameters 4-11. 
    ### Parameters 1 through 3 are predefined as mount point, computer name, and username
    attr_reader :parameters
    
    ### the actual code for this script, if it's stored in the database.
    attr_reader :code
    
    ###
    ### 
    ###
    def initialize (args = {})
      super
      
      @category = @init_data[:category]
      @cat_id = JSS::Category.map_all_ids_to(:name).invert[@category]
      @filename = @init_data[:filename]
      @info = @init_data[:info]
      @notes = @init_data[:notes]
      @os_requirements = @init_data[:os_requirements]
      @parameters = @init_data[:parameters] ? data[:parameters] : {}
      @priority = @init_data[:priority] || DEFAULT_PRIORITY
      @code = nil
      
    end # initialize    
    
    ###
    ### Change the script filename
    ### Setting it to nil will make it match the script name
    ###
    ### new_val = string or nil
    ###
    def filename= (new_val)
      
      new_val = nil if new_val == ''
      new_val = @name unless new_val
      
      return nil if new_val == @filename
      
      @filename = new_val
      @need_to_update = true
    end #filename=
    
    ###
    ### Change the display name
    ### If the filename is the same as the name, the filename
    ### will be changed also
    ### new_val = string
    ###
    def name= (new_val)   
      return nil if new_val == @name
      new_val = nil if new_val == ''
      raise JSS::MissingDataError, "Name can't be empty" unless new_val
      raise JSS::AlreadyExistsError, "A #{RSRC_OBJECT_KEY} already exists with the name '#{args[:name]}'" if JSS.send(LIST_METHOD).values.include? 
          
      ### if the filename is the same, keep it the same
      @filename = new_val if @filename == @name
      @name = new_val
      
      ### if our REST resource is based on the name, update that too
      @rest_rsrc = "#{RSRC_BASE}/name/#{URI.escape @name}" if @rest_rsrc.include? '/name/'
      @need_to_update = true
    end #name=
    
    ###
    ### Change the os_requirements field in the JSS
    ### E.g. 10.5, 10.5.3, 10.6.x
    ### new_val =  comma-separated string, or array of strings
    ### 
    ### Extra feature: Minumum OS's can now be specified as a 
    ### string using the notation ">=10.6.7" See the JSS.expand_min_os method 
    ### for details.
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
    ### Change the priority in the JSS
    ###
    ### new_val = integer
    ###
    def priority= (new_val) 
      return nil if new_val == @priority
      new_val = DEFAULT_PRIORITY if new_val.nil? or new_val == "" 
      raise JSS::InvalidDataError, ":priority must be one of: #{PRIORITIES.join ', '}" unless PRIORITIES.include? new_val
      @need_to_update = true
      @priority = new_val
    end #priority=
    
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
    ### Change the category in the JSS
    ###
    ### new_val = string, must be in the JSS
    ###
    def category= (new_val) 
      return nil if new_val == @category
      new_val = nil if new_val == ''
      new_val ||= JSS::Category::DEFAULT_CATEGORY
      raise JSS::InvalidDataError, "Category #{new_val} is not known to the JSS" unless JSS::Category.all_names.include? new_val
      @need_to_update = true
      @category = new_val
      @cat_id =  JSS::Category.map_all_ids_to(:name).invert[@category]
    end #category=
    
    ###
    ### Change all the script parameter labels 
    ### This will replace the entire set with 
    ### the hash provided.
    ###
    ### new_val = Hash with keys from PARAMETER_KEYS
    ###
    def parameters= (new_val) 
      return nil if new_val == @parameters
      new_val = {} if new_val.nil? or new_val== ''
      
      ### check the values
      raise JSS::InvalidDataError, ":parameters must be a Hash with keys :parameter4 thru :parameter11" unless new_val.kind_of? Hash and (new_val.keys & PARAMETER_KEYS) == new_val.keys
      new_val.each do |k,v|
            raise JSS::InvalidDataError, ":parameter values must be strings or nil" unless v.nil? or v.kind_of? String
      end
          
      @parameters = new_va
      @need_to_update = true
    end # parameters=
    
    ###
    ### Change one of the parameter labels
    ###
    def set_parameter (param_num, new_val)
      raise JSS::NoSuchItemError, "Parameter numbers must be from 4-11" unless (4..11).include? param_num
      pkey = "parameter#{param_num}".to_sym
      raise JSS::InvalidDataError, "parameter values must be strings or nil" unless new_val.nil? or new_val.kind_of? String
      return nil if new_val == @parameters[pkey]
      @parameters[pkey] = new_val
      @need_to_update = true
    end
    
    
    ###
    ### Since there's currently no API access to the script code when it's stored in the database
    ### it requires a database connection to read or save it.
    ### Hopefully this will not be needed in the near future
    ###
    ### This fetches the code for this script from the Database.
    ###
    def fetch_code
      raise JSS::NoSuchItemError, "Script not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      raise JSS::InvalidConnectionError, "Database connection required for code fetching." unless JSS::DB_CNX.connected?
      qrez = JSS::DB_CNX.db.query "SELECT script_contents from scripts where script_id = #{@id}"
      res = qrez.fetch_row
      @code = res[0]
    end
    
    ###
    ### Since there's currently no API access to the script code when it's stored in the database
    ### it requires a database connection to read or save it.
    ### Hopefully this will not be needed in the near future
    ###
    ### This saves the code for this script into the Database.
    ###
    def save_code
      raise JSS::MissingDataError, "No code specified. Use #fetch_code or #code= first." if @code.nil? or @code.empty?   
      raise JSS::NoSuchItemError, "Script not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      raise JSS::InvalidConnectionError, "Database connection required for code saving." unless JSS::DB_CNX.connected?
      update = JSS::DB_CNX.db.prepare "UPDATE scripts SET script_contents = '#{Mysql::quote(@code)}' WHERE script_id = '#{@id}'"
      update.execute
    end
    
    ###
    ### Change the executable code of this script.
    ### If the arg is a Pathname instance, or a String starting with "/"
    ### Then the arg is assumed to be a file from which to read the code.
    ### 
    ### Otherwise it should be a String with the code itself, and it must start with '#!"
    ###
    ### After doing this, use #save_code to write it to the database or
    ### use #upload_master_file to save it to the master dist. point.
    ###
    def code= (new_val)
      @code = case new_val
        when String
          if new_val.start_with? '/'
            Pathname.new(new_val).read
          elsif new_val.start_with? '#!'
            new_val
          else
            raise JSS::InvalidDataError, "New code String values must start with '/' for a path, or '#!' for code."
          end #if 
        when Pathname
          new_val.read
        else
          raise JSS::InvalidDataError, "New code must be a String (path or code) or Pathname instance"
      end
      @need_to_update = true
    end
    
    ###
    ### Save the @code for this script to a file on the Master Distribution point.
    ###
    ### The first argument is the password for the read/write account on the master dist. point
    ### The second arg is boolean, whether or not to unmount the dist. point when finished,
    ### which defaults to true
    ###
    ### use #code=  to set the code from a String or Pathname
    ###
    def upload_master_file( rw_pw, unmount = true)
      raise JSS::MissingDataError, "No code specified. Use #code= first." if @code.nil? or @code.empty?
      destination = JSS::DistributionPoint.master_distribution_point.mount(rw_pw, :rw) + "#{DIST_POINT_SCRIPTS_FOLDER}/#{@filename}"
      destination.save @code
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
      file = JSS::DistributionPoint.master_distribution_point.mount(rw_pw, :rw) + "#{DIST_POINT_SCRIPTS_FOLDER}/#{@filename}"
      if file.exist?
        file.delete
        did_it = true
      else
        did_it = false
      end # if exists
      JSS::DistributionPoint.master_distribution_point.unmount if unmount
      return did_it
    end 
    
    #####################################
    ### Private Instance Methods
    #####################################
    
    private
    
    ### 
    ### Return the xml for creating or updating this script in the JSS
    ###
    def rest_xml
      doc = REXML::Document.new
      scpt = doc.add_element "script"      
      scpt.add_element('category').text = @category
      scpt.add_element('filename').text = @filename
      scpt.add_element('id').text = @id
      scpt.add_element('info').text = @info
      scpt.add_element('name').text = @name
      scpt.add_element('notes').text = @notes
      scpt.add_element('os_requirements').text = JSS.to_s_and_a(@os_requirements)[:stringform]
      scpt.add_element('priority').text = @priority
      if @parameters.empty?
        scpt.add_element('parameters').text = nil
      else
        pars = scpt.add_element('parameters')
        PARAMETER_KEYS.each {|p| pars.add_element(p.to_s).text = @parameters[p]}
      end
      
      return doc.to_s
    end # rest xml
    
  end # class Script
end # midule
