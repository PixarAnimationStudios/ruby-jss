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
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute
    
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
    RSRC_BASE = "mobiledeviceextensionattributes"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_extension_attributes
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_extension_attribute
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:description, :inventory_display, :recon_display]
    
    ### these ext attribs are related to these kinds of objects
    TARGET_CLASS = JSS::MobileDevice
    
    
    ######################
    ### Attributes
    ######################
    
    ### String - when the @input Type is "LDAP Attribute Mapping"
    ### the name of the LDAP attribute to use
    attr_reader :attribute_mapping
    
    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject.initialize 
    ###
    def initialize(args = {})
      
      super args
      
      if @init_data[:input_type]
        @attribute_mapping = @init_data[:input_type][:attribute_mapping]
      end
    end # init 
    
    
    #####################################
    ### Public Instance Methods 
    #####################################
    
    ###
    ### create a new one in the JSS
    ###
    def create
      if @input_type == 'LDAP Attribute Mapping'
        raise MissingDataError, "No scripting_language set for Windows script input_type." unless @attribute_mapping
      end
      super
    end

    
    ###
    ### Change the web_display of this EA
    ###
    def web_display= (new_val)
      raise JSS::InvalidDataError, "web_display cannot be 'Operating System' for Mobile Device Extension Attributes." if new_val == 'Operating System'
      super
    end #
    
    
    ###
    ### Change the input type of this EA
    ###
    def input_type= (new_val)
      raise JSS::InvalidDataError, "Mobile Device Extension Attribute input_type cannot be 'script'" if new_val == 'script'
      
      super
      
      if @input_type == 'LDAP Attribute Mapping'
        @popup_choices = nil
      else
        @attribute_mapping = nil
      end
    end #  
    
    ######################
    ### Private Instance Methods
    #####################
    
    ###private
    
    ###
    ### Return the REST XML for this item, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      mdea = self.rest_rexml  
      if @input_type == 'LDAP Attribute Mapping'
        it = mdea.elements["input_type"]
        it.add_element('attribute_mapping').text = @attribute_mapping
      end 
      
      doc = REXML::Document.new APIConnection::XML_HEADER
      doc << mdea
      
      return doc.to_s
    end # rest xml
    
  end # class ExtAttrib

end # module
