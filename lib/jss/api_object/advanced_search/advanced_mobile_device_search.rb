module JSS
  
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
  ### An AdvancedComputerSearch in the JSS
  ###
  ### See Also the parent class JSS::AdvancedSearch
  ###
  ### See also JSS::APIObject
  ###
  class AdvancedMobileDeviceSearch < JSS::AdvancedSearch
    
    #####################################
    ### Mix-Ins
    #####################################
    
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "advancedmobiledevicesearches"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    ### NOTE - THIS IS A BUG, it should be advanced_mobile_device_searches
    RSRC_LIST_KEY = :advanced_computer_searches
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :advanced_mobile_device_search
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:sql_text, :display_fields, :mobile_devices]
    
    ### what kind of thing is returned by this search?
    RESULT_CLASS = JSS::MobileDevice
    
    ### the matching API report object
    REPORT_CLASS = nil
    
    #####################################
    ### Attributes
    #####################################
        
    #####################################
    ### Constructor 
    #####################################
  
    #####################################
    ### Public Instance Methods 
    #####################################
      
    #####################################
    ### Private Instance Methods
    #####################################    

  end # class 
  
end # module
