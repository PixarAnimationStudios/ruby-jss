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
  class MobileDeviceGroup < JSS::Group
    
    #####################################
    ### Mix-Ins
    #####################################
 
        
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "mobiledevicegroups"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_groups
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_group
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:is_smart, :mobile_devices ]
    
    ### this allows the parent Group class to do things right
    MEMBER_CLASS = JSS::MobileDevice
    
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
    ### Return an array of the udids of mobile_devices in this group
    ###
    def member_udids
      @members.map{|m| m[:udid]}
    end
    
    ###
    ### Return an array of the serial numbers of mobile_devices in this group
    ###
    def member_serial_numbers
      @members.map{|m| m[:serial_number]}
    end
    
    ###
    ### Return an array of the mac_addrs of mobile_devices in this group
    ###
    def member_mac_addresses
      @members.map{|m| m[:mac_address]}
    end
    
    ###
    ### Return an array of the wifi mac_addrs of mobile_devices in this group
    ###
    def member_wifi_mac_addresses
      @members.map{|m| m[:wifi_mac_address]}
    end
    
    #####################################
    ### Private Instance Methods
    #####################################
    

  end # class ComputerGroup
  
end # module
