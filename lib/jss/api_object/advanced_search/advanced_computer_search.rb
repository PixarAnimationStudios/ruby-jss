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
  class AdvancedComputerSearch < JSS::AdvancedSearch
    
    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "advancedcomputersearches"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :advanced_computer_searches
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :advanced_computer_search
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:sql_text, :display_fields, :computers]
    
    ### what kind of thing is returned by this search?
    RESULT_CLASS = JSS::Computer
    
    ### the matching API report object
    REPORT_CLASS = JSS::ComputerReport
    
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
