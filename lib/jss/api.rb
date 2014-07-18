module JSS
  
  #####################################
  ### Constants
  #####################################
  
  #####################################
  ### Module Variables
  #####################################
  
  #####################################
  ### Module Methods
  #####################################
  
  #####################################
  ### Module Classes
  #####################################
  
  ### 
  ### An API connection to the JSS.
  ###
  ### This is a singleton class, only one can exist at a time.
  ### Its one instance is created automatically when the module loads, but it
  ### isn't connected to anything. 
  ###
  ### Use it via the JSS::API constant to call the #connect
  ### method, and the get_rsrc, put_rsrc, post_rsrc, & delete_rsrc
  ### methods, q.v. below.
  ###
  ### To access the underlying RestClient::Resource instance,
  ### use JSS::API.cnx 
  ###
  ### See Also JSS::APIObject
  ###
  class APIConnection
    include Singleton
    
    #####################################
    ### Class Constants
    #####################################
    
    ### The base API path in the jss URL
    RSRC = "JSSResource"
    
    ### The Default port
    HTTP_PORT = 9006
    
    ### The SSL port
    SSL_PORT = 8443
    
    ### The top line of an XML doc for submitting data via API
    XML_HEADER = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
    
    ### Default timeouts in seconds
    DFT_OPEN_TIMEOUT = 60
    DFT_TIMEOUT = 60
    
    #####################################
    ### Attributes
    #####################################
    
    ### String - the username who's connected to the JSS API
    attr_reader :jss_user
    
    ### RestClient::Resource - the underlying connection resource
    attr_reader :cnx
    
    ### Boolean - are we connected right now?
    attr_reader :connected
    alias connected? connected
    
    ### JSS::Server - the details of the JSS to which we're connected.
    attr_reader :server
    
    #####################################
    ### Constructor
    ##################################### 
    
    ###
    ### To connect, use JSS::APIConnection.instance.connect
    ### or a shortcut, JSS::API.connect
    ###
    def initialize ()
      @connected = false
    end # init
    
    #####################################
    ### Class Methods
    ##################################### 
    
    ###
    ### Connect to the JSS API.  
    ### @param args[Hash] the keyed arguments for connection.
    ###   Arguments must include
    ###   - :server => the hostname of the JSS API server
    ###   - :user => a JSS user who as API privs
    ###   - :pw => the password for that user
    ###   Other args available:
    ###   - :port => the port number to connect with, defaults to 8443
    ###   - :open_timeout => the number of seconds to wait for an initial response, defaults to 60
    ###   - :timeout => the number of seconds before an API call times out, defaults to 60
    ### @return [true]
    ###
    def connect (args = {})
      
      raise JSS::MissingDataError, "Missing :user or :pw for API connection" unless (args[:user] and args[:pw])
      raise JSS::MissingDataError, "Missing :server" unless args[:server]
      
      args[:port] ||= SSL_PORT
      
      ssl = SSL_PORT == args[:port].to_i ? "s" : ''
      @rest_url = URI::encode "http#{ssl}://#{args[:server]}:#{args[:port]}/#{RSRC}"
      
      args[:password] = args[:pw]
      args[:timeout] ||= DFT_TIMEOUT
      args[:open_timeout] ||= DFT_OPEN_TIMEOUT
      @cnx = RestClient::Resource.new("#{@rest_url}", args)
      
      ### TO DO make sure we have at least read-access?
      @jss_user = args[:user]
      
      @connected = true
      
      @server = JSS::Server.new
      
      if @server.version < JSS.parse_jss_version(JSS::MINIMUM_SERVER_VERSION)[:version]
        raise JSS::UnsupportedError, "Your JSS Server version, #{@server.raw_version}, is to low. Must be #{JSS::MINIMUM_SERVER_VERSION} or higher."
      end
      
      true
    end # connect
    
    ###
    ### Reset the response timeout for the rest connection
    ###
    ### @param timeout[Integer] the new timeout in seconds
    ###
    def timeout= (timeout)
      @cnx.options[:timeout] = timeout
    end
    
    ###
    ### Reset the open-connection timeout for the rest connection
    ###
    ### @param timeout[Integer] the new timeout in seconds
    ###
    def open_timeout= (timeout)
      @cnx.options[:open_timeout] = timeout
    end
  
  
    ###
    ### With a REST connection, there isn't any real "connection" to disconnect from,
    ### just the saved authentication credentials. So to disconnect, just 
    ### unset all our credentials.
    ###
    def disconnect
      @jss_user = nil
      @rest_url = nil
      @cnx = nil
      @connected = false
    end # disconnect
    
    ###
    ### Get an arbitrary JSS resource
    ### 
    ### The first argument is the resource to get (the part of the API url 
    ### after the 'JSSResource/' )
    ###
    ### By default we get the data in JSON, and parse it 
    ### into a ruby data structure (arrays, hashes, strings, etc)
    ### with symbolized Hash keys.
    ###
    ### @param rsrc[String] the resource to get
    ###   (the part of the API url after the 'JSSResource/' )
    ### @param format[Symbol] either ;json or :xml
    ###  If the second argument is :xml, the XML data is returned as a String.
    ###
    ### @return [Hash,String] the result of the get
    ###
    def get_rsrc (rsrc, format = :json)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::APIConnection.connect first." unless @connected
      rsrc = URI::encode rsrc
      data = @cnx[rsrc].get(:accept => format)
      return JSON.parse(data, :symbolize_names => true) if format == :json
      data
    end
    
    ###
    ### Change an existing JSS resource
    ###
    ### @param rsrc[String] the API resource being changed, the URL part after 'JSSResource/'
    ### @param xml[String] the xml specifying the changes.
    ### @return [String] the xml response from the server.
    ###
    def put_rsrc(rsrc,xml)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::APIConnection.connect first." unless @connected
      
      ### convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;')
      
      ### send the data
      @cnx[rsrc].put(xml, :content_type => 'text/xml')
    end
  
    ###
    ### Create a new JSS resource
    ###
    ### @param rsrc[String] the API resource being created, the URL part after 'JSSResource/'
    ### @param xml[String] the xml specifying the new object.
    ### @return [String] the xml response from the server.
    ###
    def post_rsrc(rsrc,xml)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::APIConnection.connect first." unless @connected
      
      ### convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;')
      
      ### send the data
      @cnx[rsrc].post xml, :content_type => 'text/xml', :accept => :json
    end #post_rsrc
    
    ###
    ### Delete a resource from the JSS
    ###
    ### @param rsrc[String] the resource to create, the URL part after 'JSSResource/'
    ###
    def delete_rsrc(rsrc)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::APIConnection.connect first." unless @connected
      raise MissingDataError, "Missing :rsrc" if rsrc.nil?
      
      ### delete the resource
      @cnx[rsrc].delete
      
    end #delete_rsrc
    
    
  end # class JSSAPIConnection
  
  ### The single instance of the APIConnection
  API = APIConnection.instance

    
end # module