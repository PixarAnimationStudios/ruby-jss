### Copyright 2016 Pixar
###  
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###  
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###  
###    You may obtain a copy of the Apache License at
###  
###        http://www.apache.org/licenses/LICENSE-2.0
###  
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
### 
###

###
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
  ### isn't connected to anything at that time.
  ###
  ### Use it via the {JSS::API} constant to call the #connect
  ### method, and the {#get_rsrc}, {#put_rsrc}, {#post_rsrc}, & {#delete_rsrc}
  ### methods, q.v. below.
  ###
  ### To access the underlying RestClient::Resource instance,
  ### use JSS::API.cnx
  ###
  class APIConnection
    include Singleton

    #####################################
    ### Class Constants
    #####################################

    ### The base API path in the jss URL
    RSRC_BASE = "JSSResource"
    
    ### A url path to load to see if there's an API available at a host.
    ### This just loads the API resource docs page
    TEST_PATH = "api"
    
    ### If the test path loads correctly from a casper server, it'll contain
    ### this text
    TEST_CONTENT = "<title>JSS REST API Resource Documentation</title>"
    
    ### The Default port
    HTTP_PORT = 9006

    ### The SSL port
    SSL_PORT = 8443

    ### The top line of an XML doc for submitting data via API
    XML_HEADER = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'

    ### Default timeouts in seconds
    DFT_OPEN_TIMEOUT = 60
    DFT_TIMEOUT = 60
    
    ### The Default SSL Version
    DFT_SSL_VERSION = 'TLSv1'
    
    #####################################
    ### Attributes
    #####################################

    ### @return [String] the username who's connected to the JSS API
    attr_reader :jss_user

    ### @return [RestClient::Resource] the underlying connection resource
    attr_reader :cnx

    ### @return [Boolean] are we connected right now?
    attr_reader :connected

    ### @return [JSS::Server] the details of the JSS to which we're connected.
    attr_reader :server

    ### @return [String] the hostname of the JSS to which we're connected.
    attr_reader :server_host
    
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
    ###
    ### @param args[Hash] the keyed arguments for connection.
    ###
    ### @option args :server[String] the hostname of the JSS API server, required if not defined in JSS::CONFIG
    ###
    ### @option args :port[Integer] the port number to connect with, defaults to 8443
    ###
    ### @option args :use_ssl[Boolean] should the connection be made over SSL? Defaults to true.
    ###
    ### @option args :verify_cert[Boolean] should HTTPS SSL certificates be verified. Defaults to true.
    ###   If your connection raises RestClient::SSLCertificateNotVerified, and you don't care about the
    ###   validity of the SSL cert. just set this explicitly to false.
    ###
    ### @option args :user[String] a JSS user who has API privs, required if not defined in JSS::CONFIG
    ###
    ### @option args :pw[String,Symbol] Required, the password for that user, or :prompt, or :stdin
    ###   If :prompt, the user is promted on the commandline to enter the password for the :user.
    ###   If :stdin#, the password is read from a line of std in represented by the digit at #, 
    ###   so :stdin3 reads the passwd from the third line of standard input. defaults to line 1, 
    ###   if no digit is supplied. see {JSS.stdin}
    ###
    ### @option args :open_timeout[Integer] the number of seconds to wait for an initial response, defaults to 60
    ###
    ### @option args :timeout[Integer] the number of seconds before an API call times out, defaults to 60
    ###
    ### @return [true]
    ###
    def connect (args = {})
      
      # the server, if not specified, might come from a couple places.
      # see #hostname
      args[:server] ||= hostname
      
      # settings from config if they aren't in the args
      args[:server] ||= JSS::CONFIG.api_server_name
      args[:port] ||= JSS::CONFIG.api_server_port
      args[:user] ||= JSS::CONFIG.api_username
      args[:timeout] ||= JSS::CONFIG.api_timeout
      args[:open_timeout] ||= JSS::CONFIG.api_timeout_open
      args[:ssl_version] ||= JSS::CONFIG.api_ssl_version

      # if verify cert given was NOT in the args....
      if args[:verify_cert].nil?
        # set it from the prefs
        args[:verify_cert] = JSS::CONFIG.api_verify_cert
      end
      
      # settings from client jamf plist if needed
      args[:port] ||=  JSS::Client.jss_port
      
      # default settings if needed
      args[:port] ||= SSL_PORT
      args[:timeout] ||= DFT_TIMEOUT
      args[:open_timeout] ||= DFT_OPEN_TIMEOUT
      
      # As of Casper 9.61 we can't use SSL, must use TLS, since SSLv3 was susceptible to poodles.
      # NOTE - this requires rest-client v 1.7.0 or higher
      # which requires mime-types 2.0 or higher, which requires ruby 1.9.2 or higher!
      # That means that support for ruby 1.8.7 stops with Casper 9.6
      args[:ssl_version] ||= DFT_SSL_VERSION
      
      
      # must have server, user, and pw
      raise JSS::MissingDataError, "No JSS :server specified, or in configuration." unless args[:server]
      raise JSS::MissingDataError, "No JSS :user specified, or in configuration." unless args[:user]
      raise JSS::MissingDataError, "Missing :pw for user '#{args[:user]}'" unless args[:pw]
      
      # we're using ssl if 1) args[:use_ssl] is anything but false
      # or 2) the port is the default casper ssl port.
      args[:use_ssl] = (not args[:use_ssl] == false) or (args[:port] == SSL_PORT)
      
      # and here's the URL
      ssl = args[:use_ssl] ? "s" : ''
      @rest_url = URI::encode "http#{ssl}://#{args[:server]}:#{args[:port]}/#{RSRC_BASE}"


      # prep the args for passing to RestClient::Resource
      # if verify_cert is anything but false, we will verify
      args[:verify_ssl] =  (args[:verify_cert] == false) ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
      
      args[:password] = if args[:pw] == :prompt
        JSS.prompt_for_password "Enter the password for JSS user #{args[:user]}@#{args[:server]}:"
      elsif args[:pw].is_a?(Symbol) and args[:pw].to_s.start_with?('stdin')
        args[:pw].to_s =~ /^stdin(\d+)$/
        line = $1
        line ||= 1
        JSS.stdin line
      else
        args[:pw]
      end
      
      # heres our connection
      @cnx = RestClient::Resource.new("#{@rest_url}", args)

      @jss_user = args[:user]
      @server_host = args[:server]
      @connected = true
      @server = JSS::Server.new

      if @server.version < JSS.parse_jss_version(JSS::MINIMUM_SERVER_VERSION)[:version]
        raise JSS::UnsupportedError, "Your JSS Server version, #{@server.raw_version}, is to low. Must be #{JSS::MINIMUM_SERVER_VERSION} or higher."
      end

      return @connected ? @server_host : nil
    end # connect

    ###
    ### Reset the response timeout for the rest connection
    ###
    ### @param timeout[Integer] the new timeout in seconds
    ###
    ### @return [void]
    ###
    def timeout= (timeout)
      @cnx.options[:timeout] = timeout
    end

    ###
    ### Reset the open-connection timeout for the rest connection
    ###
    ### @param timeout[Integer] the new timeout in seconds
    ###
    ### @return [void]
    ###
    def open_timeout= (timeout)
      @cnx.options[:open_timeout] = timeout
    end


    ###
    ### With a REST connection, there isn't any real "connection" to disconnect from
    ### So to disconnect, we just unset all our credentials.
    ###
    ### @return [void]
    ###
    def disconnect
      @jss_user = nil
      @rest_url = nil
      @server_host = nil
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
    ###
    ### @param format[Symbol] either ;json or :xml
    ###  If the second argument is :xml, the XML data is returned as a String.
    ###
    ### @return [Hash,String] the result of the get
    ###
    def get_rsrc (rsrc, format = :json)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::API.connect first." unless @connected
      rsrc = URI::encode rsrc
      data = @cnx[rsrc].get(:accept => format)
      return JSON.parse(data, :symbolize_names => true) if format == :json
      data
    end

    ###
    ### Change an existing JSS resource
    ###
    ### @param rsrc[String] the API resource being changed, the URL part after 'JSSResource/'
    ###
    ### @param xml[String] the xml specifying the changes.
    ###
    ### @return [String] the xml response from the server.
    ###
    def put_rsrc(rsrc,xml)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::API.connect first." unless @connected

      ### convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;')

      ### send the data
      @cnx[rsrc].put(xml, :content_type => 'text/xml')
    end

    ###
    ### Create a new JSS resource
    ###
    ### @param rsrc[String] the API resource being created, the URL part after 'JSSResource/'
    ###
    ### @param xml[String] the xml specifying the new object.
    ###
    ### @return [String] the xml response from the server.
    ###
    def post_rsrc(rsrc,xml)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::API.connect first." unless @connected

      ### convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;')

      ### send the data
      @cnx[rsrc].post xml, :content_type => 'text/xml', :accept => :json
    end #post_rsrc

    ### Delete a resource from the JSS
    ###
    ### @param rsrc[String] the resource to create, the URL part after 'JSSResource/'
    ###
    ### @return [String] the xml response from the server.
    ###
    def delete_rsrc(rsrc)
      raise JSS::InvalidConnectionError, "Not Connected. Use JSS::API.connect first." unless @connected
      raise MissingDataError, "Missing :rsrc" if rsrc.nil?

      ### delete the resource
      @cnx[rsrc].delete

    end #delete_rsrc
    
    
    ### Test that a given hostname & port is a JSS API server
    ###
    ### @param server[String] The hostname to test, 
    ###
    ### @param port[Integer] The port to try connecting on
    ###
    ### @return [Boolean] does the server host a JSS API?
    ###
    def valid_server? (server, port = SSL_PORT)
      # try ssl first
      begin
        return true if open("https://#{server}:#{port}/#{TEST_PATH}", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read.include? TEST_CONTENT
      rescue
        # then regular http
        begin 
          return true if open("http://#{server}:#{port}/#{TEST_PATH}").read.include? TEST_CONTENT
        rescue
          # any errors = no API
          return false
        end # begin
      end #begin
      # if we're here, no API
      return false
    end
    
    ### The server to which we are connected, or will 
    ### try connecting to if none is specified with the
    ### call to #connect
    ###
    ### @return [String] the hostname of the server
    ###
    def hostname
      return @server_host if @server_host
      srvr = JSS::CONFIG.api_server_name
      srvr ||= JSS::Client.jss_server
      return srvr
    end
    
    ### aliases
    alias connected? connected


  end # class JSSAPIConnection

  ### The single instance of the APIConnection
  API = APIConnection.instance


end # module
