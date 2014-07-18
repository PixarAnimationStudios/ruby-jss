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
  ### A NetBoot Server in the JSS
  ###
  ### See also JSS::APIObject
  ###  
  class NetBootServer < JSS::APIObject
    
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
    RSRC_BASE = "netbootservers"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :netboot_servers
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :netboot_server
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:protocol, :boot_args]
    
    #####################################
    ### Attributes
    #####################################
    
    attr_reader :boot_args # String, the nvram/bless args
    attr_reader :boot_device # String, the nvram/bless args
    attr_reader :boot_file # String, the nvram/bless args
    attr_reader :configure_manually # Boolean
    attr_reader :default_image # boolean, is thisone default?
    attr_reader :image # String, the actual dmg name , eg "NetBoot.dmg"
    attr_reader :ip_address # String
    attr_reader :protocol # String "nfs" or "http"
    attr_reader :set # String, the nbi folder "MetroNB-dhoffman-10.9.3-1063.nbi"
    attr_reader :share_point # String the tftp/protocol sharepoint name "NetBootSP0"
    attr_reader :specific_image # Boolean 
    attr_reader :target_platform # String e.g."Intel/x86",
    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject#initialize
    ###
    
    def initialize (args = {})
      super
      @boot_args = @init_data[:boot_args]
      @boot_device = @init_data[:boot_device]
      @boot_file = @init_data[:boot_file]
      @configure_manually = @init_data[:configure_manually]
      @default_image = @init_data[:default_image]
      @image = @init_data[:image]
      @ip_address = @init_data[:ip_address]
      @protocol = @init_data[:protocol]
      @set = @init_data[:set]
      @share_point = @init_data[:share_point]
      @specific_image = @init_data[:specific_image]
      @target_platform = @init_data[:target_platform]
    
    end
    
    #####################################
    ### Public Instance Methods
    #####################################
    
    
  end # class NetbootServer
  
end # module
