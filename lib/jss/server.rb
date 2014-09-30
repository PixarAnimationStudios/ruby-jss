module JSS

  ### A class representing a JSS Server.
  ###
  ### The {JSS::APIConnection} instance has a JSS::Server instance in its @server attribute.
  ### It is created fresh every time {APIConnection#connect} is called.
  ###
  ### That's the only time it should be instantiated, and all access should be through
  ### {JSS::API.server}
  ###
  class Server

    #####################################
    ### Attributes
    #####################################

    ### @return [String] the organization to which the server is licensed
    attr_reader :organization
    

    ### @return [String] the activation code for the server licence
    attr_reader :activation_code

    ### @return [String] the type of server licence
    attr_reader :license_type

    ### @return [String] the license product name
    attr_reader :product

    ###  @return [String] The version of the JSS. See the method JSS.parse_jss_version
    attr_reader :version

    ###  @return [Integer]
    attr_reader :major_version

    ###  @return [Integer]
    attr_reader :minor_version

    ###  @return [Integer]
    attr_reader :revision_version

    ###  @return [String]
    attr_reader :raw_version

    #####################################
    ### Instance Methods
    #####################################

    ###
    ### Initialize!
    ###
    def initialize
      begin

        # the jssuser resource is readable by anyone with a JSS acct
        # regardless of their permissions.
        # However, it's marked as 'deprecated'. Hopefully jamf will
        # keep this basic level of info available for basic authentication
        # and JSS version checking.
        ju = JSS::API.get_rsrc('jssuser')[:user]
        @license_type = ju[:license_type]
        @product = ju[:product]
        @raw_version = ju[:version]
        parsed = JSS.parse_jss_version(@raw_version)
        @major_version = parsed[:major]
        @minor_version = parsed[:minor]
        @revision_version = parsed[:revision]
        @version = parsed[:version]

      rescue RestClient::Request::Unauthorized
        raise JSS::InvalidConnectionError, "Incorrect JSS username or password for '#{JSS::API.jss_user}'."
      end

    end

    
    ##### Aliases
    alias institution organization
    alias product_name product
    
  end # class server

end # module
