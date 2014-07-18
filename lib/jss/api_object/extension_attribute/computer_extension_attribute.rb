module JSS


  
  #####################################
  ### Constants
  ##################################### 
  
  #####################################
  ### Module Variables
  ##################################### 
  
  #####################################
  ### Module Methods
  ##################################### 
  
  ####################################
  ### Classes
  ##################################### 
  
  
  ### 
  ### An extension attribute as defined in the JSS
  ###
  ### See also the parent class JSS::ExtensionAttribute
  ###
  ### See also JSS::APIObject
  ###
  class ComputerExtensionAttribute < JSS::ExtensionAttribute
    
    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Methods
    #####################################
       
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "computerextensionattributes"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_extension_attributes
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :computer_extension_attribute
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:description, :inventory_display, :recon_display]
    
    ### these ext attribs are related to these kinds of objects
    TARGET_CLASS = JSS::Computer
  
    ### When the intput type is script, what platforms can they run on?
    PLATFORMS = ["Mac","Windows"]
    
    ### When the platform is Windows, what languages can be user?
    WINDOWS_SCRIPTING_LANGUAGES = ["VBScript", "Batch File", "PowerShell"]
    
    ### Where can it be displayed in the Recon App?
    RECON_DISPLAY_CHOICES = [
      "Computer",
      "User and Location",
      "Purchasing",
      "Extension Attributes"
    ]
    
    DEFAULT_RECON_DISPLAY_CHOICE = "Extension Attributes"
    
    ######################
    ### Attributes
    ######################
    
    ### When the  @input_type is "script", The platform on which a script will run.
    ### NOTE: The web app seems to let you have both Mac and Windows
    ### scripts defined when the type is "script",
    ### however the API will only return the Mac script info if there is 
    ### one at all.
    attr_reader :platform
    
    ### String - when @input_type is "script",
    ### the script code that will be executed when the 
    ### 
    attr_reader :script
    alias code script
    
    ### String -  when @input_type is "script", 
    ### and the @platform is "Windows"
    ### the scripting language of the @script,
    ### must be one of WINDOWS_SCRIPTING_LANGUAGES
    attr_reader :scripting_language
    
    ### String - In which part of the Recon App does the data appear?
    ### when this is a computer ext attr?
    attr_reader :recon_display
    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject.initialize 
    ###
    def initialize(args = {})
      
      super args
      
      @recon_display = @init_data[:recon_display] || DEFAULT_RECON_DISPLAY_CHOICE
      
      if @init_data[:input_type]
        @platform = @init_data[:input_type][:platform]
        @script = @init_data[:input_type][:script]
        @scripting_language = @init_data[:input_type][:scripting_language]
      end
    end # init 
    
    
    #####################################
    ### Public Instance Methods 
    #####################################
    
    ###
    ### create a new one in the JSS
    ###
    def create      
      if @input_type ==  "script"
          raise MissingDataError, "No platform set for script input_type." unless @platform
          raise MissingDataError, "No script set for script input_type." unless @script
          if @platform == "Windows"
            raise MissingDataError, "No scripting_language set for Windows script input_type." unless @scripting_language
          end
      end # case
      
      super
    end
    
    ###
    ### Change the recon_display of this EA
    ###
    def recon_display= (new_val)
      return nil if @recon_display == new_val
      raise JSS::InvalidDataError, "recon_display must be a string, one of: #{RECON_DISPLAY_CHOICES.join(", ")}" unless RECON_DISPLAY_CHOICES.include? new_val
      @recon_display = new_val
      @need_to_update = true
    end #
    
    
    ###
    ### Change the input type of this EA
    ###
    def input_type= (new_val)
      raise JSS::InvalidDataError, "ComputerExtensionAttribute input_types cannot be 'LDAP Attribute Mapping'" if new_val == 'LDAP Attribute Mapping'
      
      super
      
      case @input_type
        when *["Text Field","Pop-up Menu"]
          @script = nil
          @scripting_language = nil
          @platform = nil
        when "script"
          @popup_choices = nil
      end # case
    end #  
    
    ###
    ### Change the Popup Choices of this EA
    ### 
    ### This automatically unsets all script-related attributes
    ###
    def popup_choices= (new_val)
      super
      @script = nil
      @scripting_language = nil
      @platform = nil
    end #
    
    ###
    ### Change the platform of this EA.
    ### Setting this automatically sets input_type to script
    ###
    def platform= (new_val)
      return nil if @platform == new_val
      raise JSS::InvalidDataError, "platform must be a string, one of: #{PLATFORMS.join(", ")}" unless PLATFORMS.include? new_val
      self.input_type = "script"
      @platform = new_val
      @need_to_update = true
    end #  
    
    ###
    ### Change the script of this EA.
    ### Setting this automatically sets input_type to script
    ###
    def script= (new_val)
      return nil if @script == new_val
      self.input_type = "script"
      @scipt = new_val
      @need_to_update = true
    end #
    
    ###
    ### Change the scripting_language of this EA.
    ### Setting this automatically sets input_type to script
    ### and the platform to "Windows"
    def scripting_language= (new_val)
      return nil if @scripting_language == new_val
      raise JSS::InvalidDataError, "Scripting language must be a string, one of: #{WINDOWS_SCRIPTING_LANGUAGES.join(", ")}" unless WINDOWS_SCRIPTING_LANGUAGES.include? new_val
      self.input_type = "script"
      self.platform = "Windows"
      @scripting_language = new_val
      @need_to_update = true
    end #
    
    ###
    ### Return an Array of Hashes showing the most recent value 
    ### for this EA on all computers in the JSS.
    ### Each Hash is one computer, with these keys: 
    ###   :id - the computer id
    ###   :name - the computer name
    ###   :value - the most recent ext attr value for the computer.
    ###
    ### This is done by creating a temporary AdvancedComputerSearch
    ### for all computers with the EA as a display field, then 
    ### getting the matching ComputerReport with the data.
    ### The AdvancedComputerSearch is then deleted.
    ###
    ### NOTE: This is BROKEN until JAMF fixes the ComputerReports JSON bug.
    ###  it will only return one computer.
    ###
    ### UNTIL THEN, we'll do this via the MySQL database.
    ###
    def latest_values
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      
      ######## TEMPORARY - until bug is fixed.
      raise JSS::InvalidConnectionError, "Database connection required for 'latest_values' query." unless JSS::DB_CNX.connected?
      
      query = <<-ENDOFQUERY
      SELECT c.computer_id AS id, c.computer_name as name, eav.value_on_client AS value
      FROM computers_denormalized c
      JOIN extension_attribute_values eav ON c.last_report_id = eav.report_id
      WHERE eav.extension_attribute_id = #{@id}
      ENDOFQUERY
      
      qrez = JSS::DB_CNX.db.query query
      the_values = []
      
      qrez.each_hash do |entry|
        value = case @data_type
          when 'String' then entry['value']
          when 'Integer' then entry['value'].to_i
          when 'Date' then JSS.parse_datetime(entry['value'])
        end # case
        the_values <<  { :id => entry['id'].to_i, :name => entry['name'], :value => value }
      end # each hash
      
      return the_values
      ######## END TEMPORARY
      
      ## Some day we'll do it like this:
      
      acs = JSS::AdvancedComputerSearch.new :id => :new, :name => "JSSgem-CEA-#{DateTime.now.to_jss_xml_epoch}-tmp-latest"
      acs.display_fields = ["JSS Computer ID", "Computer Name", @name]
      
      crit_list = [JSS::Criteriable::Criterion.new(:and_or => "and",:name => "Computer Name",:search_type => "like", :value => '')]
      acs.criteria = JSS::Criteriable::Criteria.new crit_list
      begin
        report = acs.create.report
        the_values = []
        symbolized_name = @name.gsub(/[ -]/, '_').to_sym # hopefully this'll be fixed too
        report.each do |comp|
          value = case @data_type
            when 'String' then comp[symbolized_name]
            when 'Integer' then comp[symbolized_name].to_i
            when 'Date' then JSS.parse_datetime(comp[symbolized_name])
          end # case
          the_values <<  { :id => ecomp[:JSS_Computer_ID].to_i, :name => comp[:Computer_Name].to_i, :value => value }
        end
      ensure
        acs.delete      
      end
      the_values
    end # latest values
    
    
    ###
    ### Return an array of hashes showing the history of values for this EA on one computer.
    ### The computer must be specified as a computer name or ID in the JSS.
    ### Each hash contains these 2 keys:
    ### :value - String, Integer, or DateTime, depending on @data_type
    ### :timestamp  - DateTime
    ###
    ### This method requires a MySQL database connection established via JSS::DB_CNX.connect
    ###
    def history(computer)
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{RSRC_OBJECT_KEY}." unless @in_jss
      raise JSS::InvalidConnectionError, "Database connection required for 'history' query." unless JSS::DB_CNX.connected?
      
      computer_id = case computer
        when *JSS::Computer.all_ids
          computer
        when *JSS::Computer.all_names
          JSS::Computer.map_all_ids_to(:name).invert[computer]
        else nil
      end # case
      
      raise JSS::NoSuchItemError, "No computer found matching '#{computer}'" unless computer_id
      
      the_query = <<-END_Q
      SELECT eav.value_on_client AS value, r.date_entered_epoch AS timestamp_epoch
      FROM extension_attribute_values eav JOIN reports r ON eav.report_id = r.report_id 
      WHERE r.computer_id = #{computer_id}
        AND eav.extension_attribute_id = #{@id}
        AND eav.value_on_client != '' 
        AND eav.value_on_client IS NOT NULL 
        AND eav.value_on_client != '(null)'
      ORDER BY timestamp_epoch
      END_Q
      
      qrez = JSS::DB_CNX.db.query the_query
      history = []
      
      qrez.each_hash do |entry|
        value = case @data_type
          when 'String' then entry['value']
          when 'Integer' then entry['value'].to_i
          when 'Date' then JSS.parse_datetime(entry['value'])
        end # case
        newhash = {:value => value, :timestamp => JSS.parse_datetime(entry['timestamp_epoch']) }
        history << newhash
      end # each hash
      
      history
    end # history
    
    ######################
    ### Private Instance Methods
    #####################
    
    ###private
    
    ###
    ### Return the REST XML for this pkg, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      
      cea = self.rest_rexml  
      cea.add_element('recon_display').text = @recon_display 
      
      if @input_type == 'script'
        it = cea.elements["input_type"]
        it.add_element('script').text = @script
        it.add_element('platform').text = @platform
        it.add_element('scripting_language').text = @scripting_language if @scripting_language
      end 
      
      doc = REXML::Document.new APIConnection::XML_HEADER
      doc << cea
      
      return doc.to_s
    end # rest xml
    
  end # class ExtAttrib
  
  
end # module
