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
  ### A Category in the JSS
  ### These are simple, in that they only have an ID and a name.
  ###
  ### See also JSS::APIObject
  ### 
  class Category < JSS::APIObject
    
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
    RSRC_BASE = "categories"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :categories
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :category
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = []
    
    ### The Default category
    DEFAULT_CATEGORY = "Unknown"
  
    #####################################
    ### Attributes
    #####################################
    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject#initialize
    ###

    #####################################
    ### Public Instance Methods
    #####################################
    
  end # class category
  
end # module
