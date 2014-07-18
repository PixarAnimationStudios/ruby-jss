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
  ### A User extension attribute as defined in the JSS
  ###
  ### See also the parent class JSS::ExtensionAttribute
  ###
  ### See also JSS::APIObject
  ###
  class UserExtensionAttribute < JSS::ExtensionAttribute
    
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
    RSRC_BASE = "userextensionattributes"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :user_extension_attributes
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :user_extension_attribute
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:description, :data_type, :input_type]
    
    ### these ext attribs are related to these kinds of objects
    TARGET_CLASS = JSS::User
    
    ######################
    ### Attributes
    ######################
    
    #####################################
    ### Constructor 
    #####################################

    #####################################
    ### Public Instance Methods 
    #####################################
  
    ######################
    ### Private Instance Methods
    #####################
    private
    
    ###
    ### Return the REST XML for this item, with the current values,
    ### for saving or updating
    ###
    def rest_xml
      uea = self.rest_rexml  
      doc = REXML::Document.new APIConnection::XML_HEADER
      doc << uea
      return doc.to_s
    end # rest xml
    
  end # class ExtAttrib
  
  
end # module
