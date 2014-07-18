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
  ### A computer group in the JSS
  ###
  ### See also the parent class JSS::Group
  ###
  ### See also JSS::APIObject
  ###
  class ComputerGroup < JSS::Group
    
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
    RSRC_BASE = "computergroups"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_groups
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :computer_group
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:is_smart, :computers ]
    
    ### this allows the parent Group class to do things right
    MEMBER_CLASS = JSS::Computer
    
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

    
    ###
    ### Return an array of the serial numbers of members in this group
    ###
    def member_serial_numbers
      @members.map{|m| m[:serial_number]}
    end
    
    ###
    ### Return an array of the mac_addrs of members in this group
    ###
    def member_mac_addresses
      @members.map{|m| m[:mac_address]} + @members.map{|m| m[:alt_mac_address]}
    end
    
    #####################################
    ### Private Instance Methods
    #####################################
    
  end # class ComputerGroup
  
end # module
