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
  ### A User in the JSS
  ### These are simple, in that they only have an ID and a name
  ###
  ### See also JSS::APIObject
  ###
  class User < JSS::APIObject
    
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
    RSRC_BASE = "users"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :users
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :user
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = []
    
    ### This class lets us seach for users
    SEARCH_CLASS = JSS::AdvancedUserSearch
    
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
    
    
  end # class user
  
end # module
