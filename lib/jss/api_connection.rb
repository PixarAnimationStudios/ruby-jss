### Copyright 2014 Pixar
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

    ### @return [String] the username who's connected to the JSS API
    attr_reader :jss_user

    ### @return [RestClient::Resource] the underlying connection resource
    attr_reader :cnx

    ### @return [Boolean] are we connected right now?
    attr_reader :connected

    ### @return [JSS::Server] the details of the JSS to which we're connected.
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
    ###
    ### @param args[Hash] the keyed arguments for connection.
    ###
    ### @option args :server[String] Required, the hostname of the JSS API server
    ###
    ### @option args :port[Integer] the port number to connect with, defaults to 8443
    ###
    ### @option args :verify_cert[Boolean]should HTTPS SSL certificates be verified. Defaults to true.
    ###   If your connection raises RestClient::SSLCertificateNotVerified, and you don't care about the
    ###   validity of the SSL cert. just set this explicitly to false.
    ###
    ### @option args :user[String] Required, a JSS user who as API privs
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

      # settings from config if they aren't in the args
      args[:server] ||= JSS::CONFIG.api_server_name
      args[:port] ||= JSS::CONFIG.api_server_port
      args[:user] ||= JSS::CONFIG.api_username
      args[:timeout] ||= JSS::CONFIG.api_timeout
      args[:open_timeout] ||= JSS::CONFIG.api_timeout_open

      # if verify cert given was NOT in the args....
      if args[:verify_cert].nil?
        # set it from the prefs
        args[:verify_cert] = JSS::CONFIG.api_verify_cert
      end

      # default settings if needed
      args[:port] ||= SSL_PORT
      args[:timeout] ||= DFT_TIMEOUT
      args[:open_timeout] ||= DFT_OPEN_TIMEOUT

      # must have server, user, and pw
      raise JSS::MissingDataError, "Missing :server" unless args[:server]
      raise JSS::MissingDataError, "Missing :user" unless args[:user]
      raise JSS::MissingDataError, "Missing :pw for user '#{args[:user]}'" unless args[:pw]

      ssl = SSL_PORT == args[:port].to_i ? "s" : ''
      @rest_url = URI::encode "http#{ssl}://#{args[:server]}:#{args[:port]}/#{RSRC}"

      # prep the args for passing to RestClient::Resource
      # if verify_cert is nil (unset) or non-false, then we will verify
      args[:verify_ssl] =  (args[:verify_cert].nil? or args[:verify_cert]) ? OpenSSL::SSL::VERIFY_PEER :  OpenSSL::SSL::VERIFY_NONE
      
      # make sure we have a user
      raise JSS::MissingDataError, "No JSS user specified, or listed in configuration." unless args[:user]
      
      args[:password] = if args[:pw] == :prompt
        JSS.prompt_for_password "Enter the password for JSS user '#{args[:user]}':"
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
      @connected = true
      @server = JSS::Server.new

      if @server.version < JSS.parse_jss_version(JSS::MINIMUM_SERVER_VERSION)[:version]
        raise JSS::UnsupportedError, "Your JSS Server version, #{@server.raw_version}, is to low. Must be #{JSS::MINIMUM_SERVER_VERSION} or higher."
      end

      return true
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

    ###
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

    ### aliases
    alias connected? connected


  end # class JSSAPIConnection

  ### The single instance of the APIConnection
  API = APIConnection.instance


end # module
