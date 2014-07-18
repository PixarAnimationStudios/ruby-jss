module JSS

### A class representing a JSS Server.
###
### The APIConnection instance has a JSS::Server instance in its @server attribute.
### It is created fresh every time APIConnection.connect is called. That's the only 
### time it should be instantiated.
###



  class Server

    #####################################
    ### Attributes
    #####################################
    
    ### the organization to which the server is licensed
    attr_reader :organization
    alias institution organization
    
    ### the activation code for the server licence
    attr_reader :activation_code
    
    ### the type of server licence
    attr_reader :license_type
    
    ### the license product name
    attr_reader :product
    alias product_name product
    
    ### The version of the JSS.
    ### See the method JSS.parse_jss_version
    attr_reader :version
    attr_reader :major_version
    attr_reader :minor_version
    attr_reader :revision_version
    attr_reader :raw_version
    
    #####################################
    ### Instance Methods
    #####################################
    
    ###
    ### Initialize!
    ###
    def initialize
      begin 
        actc = JSS::API.get_rsrc('activationcode')[:activation_code]
        @organization = actc[:organization_name]
        @activation_code = actc[:code]
        
        ju = JSS::API.get_rsrc('jssuser')[:user]
        @license_type = ju[:license_type]
        @product = ju[:product]
        
        @raw_version = ju[:version]
        parsed = JSS.parse_jss_version(@raw_version)
        @major_version = parsed[:major]
        @minor_version = parsed[:minor]
        @revision_version = parsed[:revision]
        @version = parsed[:version]
      rescue
      end
    end
    
   
  end # class server
  
end # module
