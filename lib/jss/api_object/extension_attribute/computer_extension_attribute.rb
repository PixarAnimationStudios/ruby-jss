### Copyright 2016 Pixar
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
  ### The definition of a Computer extension attribute in the JSS
  ###
  ### @see JSS::ExtensionAttribute
  ###
  ### @see JSS::APIObject
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
    
    ### A criterion that will return all members of the TARGET_CLASS
    ALL_TARGETS_CRITERION = JSS::Criteriable::Criterion.new(:and_or => "and", :name => "Username", :search_type => "like", :value => '')
    
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
    ###
    ### NOTE: The web app seems to let you have both Mac and Windows
    ### scripts defined when the type is "script",
    ### however the API will only return the Mac script info if both are defined.
    ###
    ### @return [String] 
    attr_reader :platform

    ### @return [String] the script code that will be executed when the @input_type is "script",
    attr_reader :script
    

    ### The scripting language of the @script when @input_type is "script",
    ### and the @platform is "Windows"
    ###
    ### @return [String]
    attr_reader :scripting_language

    ### @return [String] In which part of the Recon App does the data appear?
    attr_reader :recon_display

    #####################################
    ### Constructor
    #####################################

    ###
    ### @see JSS::APIObject#initialize
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
    ### @see JSS::Creatable#create
    ###
    ### @return [Integer] the JSS id of the newly created object
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
    ### @see JSS::ExtensionAttribute#input_type=
    ###
    ### @return [void]
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
    ### This unsets any script-related attributes
    ###
    ### @param (see JSS::ExtensionAttribute#popup_choices=)
    ###
    ### @return [void]
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
    ### @param new_val[String] the new value, which must be a member of PLATFORMS
    ###
    ### @return [void]
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
    ### @param new_val[String] the new value
    ###
    ### @return [void]
    ###
    def script= (new_val)
      return nil if @script == new_val
      self.input_type = "script"
      @script = new_val
      @need_to_update = true
    end #
    

    ###
    ### Change the scripting_language of this EA.
    ### Setting this automatically sets input_type to 'script'
    ### and the platform to "Windows"
    ###
    ### @param new_val[String] the new value, which must be one of {WINDOWS_SCRIPTING_LANGUAGES}
    ###
    ### @return [void]
    ###
    def scripting_language= (new_val)
      return nil if @scripting_language == new_val
      raise JSS::InvalidDataError, "Scripting language must be a string, one of: #{WINDOWS_SCRIPTING_LANGUAGES.join(", ")}" unless WINDOWS_SCRIPTING_LANGUAGES.include? new_val
      self.input_type = "script"
      self.platform = "Windows"
      @scripting_language = new_val
      @need_to_update = true
    end #




    ### Return an Array of Hashes showing the history of reported values for this EA on one computer.
    ###
    ### Each hash contains these 2 keys:
    ### * :value - String, Integer, or Time, depending on @data_type
    ### * :timestamp  - Time
    ###
    ### This method requires a MySQL database connection established via JSS::DB_CNX.connect
    ###
    ### @see JSS::DBConnection
    ###
    ### @param computer[Integer,String]  the id or name of the Computer.
    ###
    ### @return [Array<Hash{:timestamp=>Time,:value=>String,Integer,Time}>]
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
        newhash = {:value => value, :timestamp => JSS.epoch_to_time(entry['timestamp_epoch']) }
        history << newhash
      end # each hash

      history
    end # history
    
    
    ### Aliases here, since YARD seems to have issues with them above
    alias code script
    alias code= script=
    
    ######################
    ### Private Instance Methods
    #####################

    private

    ###
    ### Return the REST XML for this pkg, with the current values,
    ### for saving or updating
    ###
    def rest_xml

      cea = rest_rexml # See parent class
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
