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
  ### A Software Update Server in the JSS
  ###
  ### See also JSS::APIObject
  ###
  class SoftwareUpdateServer < JSS::APIObject
    
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
    RSRC_BASE = "softwareupdateservers"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :software_update_servers
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :software_update_server
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:set_system_wide, :port]
    
    #####################################
    ### Attributes
    #####################################
    
    attr_reader :ip_address # String
    attr_reader :port # Integer
    attr_reader :set_system_wide # Boolean

    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject#initialize
    ###
    
    def initialize (args = {})
      super
      @ip_address = @init_data[:ip_address]
      @port = @init_data[:port]
      @set_system_wide = @init_data[:set_system_wide]
    end
    
    #####################################
    ### Public Instance Methods
    #####################################
    
    
  end # class NetbootServer
  
end # module
