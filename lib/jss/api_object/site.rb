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
  ### A Site in the JSS.
  ###
  ### These are simple, in that they only have an ID and a name.
  ###
  ### @see JSS::APIObject
  ### 
  class Site < JSS::APIObject
    
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
    RSRC_BASE = "sites"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :sites
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :site
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = []
    
    #####################################
    ### Attributes
    #####################################
    
    #####################################
    ### Constructor 
    #####################################
    

    #####################################
    ### Public Instance Methods
    #####################################
    
    
  end # class site
  
end # module
