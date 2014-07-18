module JSS
  
  #####################################
  ### Module Constants
  #####################################  
  
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
  ### A Mobile Device group in the JSS
  ###
  ### See also the parent class JSS::Group
  ###
  ### See also JSS::APIObject
  ###
  class UserGroup < JSS::Group
    
    #####################################
    ### Mix-Ins
    #####################################
 
        
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "usergroups"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :user_groups
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :user_group
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:is_smart, :mobile_devices ]
    
    ### this allows the parent Group class to do things right
    MEMBER_CLASS = JSS::User
    
    #####################################
    ### Class Variables
    #####################################
    
    #####################################
    ### Class Methods
    #####################################
    
    #####################################
    ### Attributes
    #####################################
    
    #####################################
    ### Public Instance Methods
    #####################################
    
    #####################################
    ### Private Instance Methods
    #####################################
    

  end # class UserGroup
  
end # module
