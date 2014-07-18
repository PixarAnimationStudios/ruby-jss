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
  ### The parent class of Extension attributes in the JSS
  ###
  ### Subclasses must define these constants:
  ### * TARGET_CLASS - the JSS module class to which the extention attribute applies.
  ###                  e.g.JSS::Computer
  ###
  ### See also JSS::APIObject
  ### 
  class ExtensionAttribute < JSS::APIObject
    
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
    
    ### What kinds of data can be created by EAs?
    ### Note, Dates must be in the format "YYYY-MM-DD hh:mm:ss"
    DATA_TYPES = ["String", "Date", "Integer"]
    DEFAULT_DATA_TYPE = "String"
    
    ### Where does the data come from?
    INPUT_TYPES = [ "Text Field", "Pop-up Menu", "script", "LDAP Attribute Mapping"]
    DEFAULT_INPUT_TYPE = "Text Field"
    
    ### Where can it be displayed in the WebApp?
    ### subclasses can add to this list
    WEB_DISPLAY_CHOICES = [
      "General",
      "Operating System",
      "Hardware",
      "User and Location",
      "Purchasing",
      "Extension Attributes"
    ]
    DEFAULT_WEB_DISPLAY_CHOICE = "Extension Attributes"

    
    ######################
    ### Attributes
    ######################
    
    ### :id, :name, :in_jss, :need_to_update, and :rest_rsrc come from JSS::APIObject
    
    ### String - description of the ext attrib
    attr_reader :description
    alias desc description
    
    ### String - the type of data created by the EA.
    ### must be one of DATA_TYPES
    attr_reader :data_type
    
    ### String - where does this data come from.
    ### one of the INPUT_TYPES. Some other attributes
    ### are dependent on this one
    attr_reader :input_type
    
    ### Array of Strings - the choices available in the UI when
    ### the @input_type is "Pop-up Menu"
    attr_reader :popup_choices
    
    
    
    ### String - In which part of the web UI does the data appear?
    attr_reader :web_display
    
    
    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject.initialize 
    ###
    def initialize(args = {})
      
      super args
      
      ### @init_data now has the raw data
      ### so fill in our attributes or set defaults
      
      @description = @init_data[:description]
      @data_type = @init_data[:data_type] || DEFAULT_DATA_TYPE
      @web_display = @init_data[:inventory_display] || DEFAULT_WEB_DISPLAY_CHOICE
      
      @input_type = @init_data[:input_type][:type] || DEFAULT_INPUT_TYPE
      if @init_data[:input_type]
        @popup_choices = @init_data[:input_type][:popup_choices] 
      end
    end # init 
    
    #####################################
    ### Public Instance Methods 
    #####################################
    
    ###
    ### create a new one in the JSS
    ###
    def create      
      if @input_type == "Pop-up Menu"
          raise MissingDataError, "No popup_choices set for Pop-up Menu input_type." unless @popup_choices.kind_of? Array and (not @popup_choices.empty?)
      end 
      super
    end
    
    
    ###
    ### Change the description of this EA
    ###
    def description= (new_val)
      return nil if @description == new_val
      @description = new_val
      @need_to_update = true
    end #  name=(newname)
    
    ###
    ### Change the data type of this EA
    ###
    def data_type= (new_val)
      return nil if @data_type == new_val
      raise JSS::InvalidDataError, "data_type must be a string, one of: #{DATA_TYPES.join(", ")}" unless DATA_TYPES.include? new_val
      @data_type = new_val
      @need_to_update = true
    end #  
    
    
    ###
    ### Change the inventory_display of this EA
    ###
    def web_display= (new_val)
      return nil if @web_display == new_val
      raise JSS::InvalidDataError, "inventory_display must be a string, one of: #{INVENTORY_DISPLAY_CHOICES.join(", ")}" unless WEB_DISPLAY_CHOICES.include? new_val
      @web_display = new_val
      @need_to_update = true
    end #
    
    
    ###
    ### Change the input type of this EA
    ###
    def input_type= (new_val)
      return nil if @input_type == new_val
      raise JSS::InvalidDataError, "input_type must be a string, one of: #{INPUT_TYPES.join(", ")}" unless DATA_TYPES.include? new_val
      @input_type = new_val
      @popup_choices = nil if @input_type == "Text Field"
      @need_to_update = true
    end #  
    
    ###
    ### Change the Popup Choices of this EA
    ### New value must be an Array, the items will be converted to Strings.
    ### 
    ### This automatically sets input_type to "Pop-up Menu"
    ### and unsets all script-related attributes
    ### 
    ### Values are checked to ensure they match the @data_type
    ### Note, Dates must be in the format "YYYY-MM-DD hh:mm:ss"
    ###
    def popup_choices= (new_val)
      return nil if @popup_choices == new_val
      raise JSS::InvalidDataError, "popup_choices must be an Array" unless new_val.kind_of?(Array)
      
      ### convert each one to a String, 
      ### and check that it matches the @data_type
      new_val.map! do |v|
        v = v.to_s.strip
        case @data_type
          when "Date"
            raise JSS::InvalidDataError, "data_type is Date, but '#{v}' is not formatted 'YYYY-MM-DD hh:mm:ss'" unless v =~ /^\d{4}(-\d\d){2} (\d\d:){2}\d\d$/
          when "Integer"
            raise JSS::InvalidDataError, "data_type is Integer, but '#{v}' is not an integer" unless v =~ /^\d+$/
        end
        v
      end
      self.input_type = "Pop-up Menu"
      @popup_choices = new_val
      @need_to_update = true
    end #
    
    
    ###
    ### Return an Array of hashes  with :id & :name for all inventory objects
    ### with a desired result in their latest report for this EA.
    ### search type must be one of those listed in JSS::Criterion::SEARCH_TYPES
    ###
    ### This is done by creating a temprary AdvancedComputerSearch
    ### then getting the #computers hash from it, then deleting it.
    ###
    def all_with_result(search_type, result)
      raise JSS::NoSuchItemError, "EA Not In JSS! Use #create to create this #{REST_OBJECT_KEY}." unless @in_jss
      raise JSS::InvalidDataError, "Invalid search_type, see JSS::Criteriable::Criterion::SEARCH_TYPES" unless JSS::Criteriable::Criterion::SEARCH_TYPES.include? search_type.to_s
      begin
        search_class = self.class::TARGET_CLASS::SEARCH_CLASS
        acs = search_class.new :id => :new, :name => "JSSgem-EA-#{DateTime.now.to_jss_xml_epoch}-result-search"
        acs.display_fields = ["Username"]
        crit_list = [JSS::Criteriable::Criterion.new(:and_or => "and", :name => @name, :search_type => search_type.to_s, :value => result)]
        acs.criteria = JSS::Criteriable::Criteria.new crit_list
        acs.create
        results = acs.search_results
      ensure
        acs.delete
      end
      results
    end
    
    ######################
    ### Private Instance Methods
    #####################
    
    ###private
    
    ###
    ### Return a REXML object for this ext attr, with the current values.
    ### Subclasses should augment this in their rest_xml methods
    ### then return it .to_s, for saving or updating
    ###
    def rest_rexml
      ea = REXML::Element.new RSRC_OBJECT_KEY.to_s
      ea.add_element('name').text = @name      
      ea.add_element('description').text = @description      
      ea.add_element('data_type').text = @data_type      
      ea.add_element('inventory_display').text = @web_display      
      
      it = ea.add_element('input_type')    
      it.add_element('type').text = @input_type
      if @input_type == "Pop-up Menu"
        pcs = it.add_element('popup_choices')
        @popup_choices.each{|pc| pcs.add_element('choice').text = pc}
      end     
      return ea
    end # rest xml
    
    
  end # class ExtAttrib

end # module JSS

require "jss/api_object/extension_attribute/computer_extension_attribute"
require "jss/api_object/extension_attribute/mobile_device_extension_attribute"
require "jss/api_object/extension_attribute/user_extension_attribute"
