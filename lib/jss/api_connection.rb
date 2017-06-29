### Copyright 2017 Pixar
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

  # Constants
  #####################################

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # An API connection to the JSS.
  #
  # Instances of this class are REST connections to a JSS API and contain
  # (once connected) all the data needed for communication with
  # that API, including login credentials, URLs, and so on.
  #
  # While multiple connection instances can be created (to different servers, or with
  # different creditials), only one is active at a time. The currently-
  # active connection instance is available from the {JSS.api} method.
  #
  # == The default connection
  #
  # When ruby-jss is loaded, a not-yet-connected default instance of
  # JSS::APIConnection is created, activated, and stored in the constant JSS::API.
  # Before using it you must call its {#connect} method, passing in appropriate
  # connection details and credentials.
  #
  # If you're only going to be connecting to one server, or one at a time,
  # using the default connection is preferred. You can call its {#connect}
  # method at any time to change servers or connection credentials.
  #
  #   require 'ruby-jss'
  #   JSS.api.connect server: 'server.address.edu', user: 'jss-api-user', pw: :prompt
  #
  # == Creating multiple connections
  #
  # Other connections can be created and stored for later use using the
  # standard ruby 'new' method, and storing the new connection instance in a
  # variable.  e.g. `other_connection = JSS::APIConnection.new`
  #
  # If you pass in connection details when calling new, they will be used to
  # call the #connect method immediately on the new connection.
  #
  #   production_api = JSS::APIConnection.new(
  #     name: 'prod',
  #     server: 'prodserver.address.org',
  #     user: 'produser',
  #     pw: :prompt
  #   )
  #
  #   # the new connection is now stored in the variable 'production_api'.
  #
  # == Switching between multiple connections
  #
  # Only one connection is active at a time and the currently active one is
  # returned when you call `JSS.api` or its aliases `JSS.api_connection` or
  # `JSS.connection`
  #
  # To active another connection, one that was created and stored in a variable,
  # just pass the variable in to the JSS.use_api like so:
  #
  #   JSS.use_api production_api
  #
  # To re-activate to the default connection, just call
  #    JSS.use_default_connection
  #
  # or its functional equivalent
  #    JSS.use_api JSS::API
  #
  # == Connection Names:
  #
  # As seen in the examples, you can provide an arbitrary 'name:' parameter
  # (a String or a Symbol) which can be used later to see which connection is
  # which.  If you don't provide one, the name is ':disconnected' until you
  # connect, and then 'user@server:port' after connecting.
  #
  # The name of the default connection is always :default
  #
  # To see the name of the currently active connection, just use `JSS.api.name`
  #
  #   JSS.use_api production_api
  #   JSS.api.name  # => 'prod'
  #   JSS.use_default_connection
  #   JSS.api.name  # => :default
  #
  # == Creating, Storing and Activating a connection in one step
  #
  # Both of the above steps (creating/storing a connection, and making it
  # active) can be performed in one step using the
  # `JSS.new_api_connection method`, which creates a new APIConnection, makes it
  # the current connection, and returns it. See the example
  #
  #    production_api2 = JSS.new_api_connection(
  #     name: 'prod2',
  #     server: 'prodserver.address.org',
  #     user: 'produser',
  #     pw: :prompt
  #     )
  #
  #   JSS.api.name  # => 'prod2'
  #
  # == Low-level use of APIConnection instances.
  #
  # For most uses, creating, activating, and connecting APIConnection instances
  # is all you'll need. However to access API resources that aren't yet
  # implemented in other parts of ruby-jss, you can use the methods
  # {#get_rsrc}, {#put_rsrc}, {#post_rsrc}, & {#delete_rsrc}
  # documented below.
  #
  # For even lower-level work, you can access the underlying RestClient::Resource
  # inside the APIConnection via the connection's {#cnx} attribute.
  #
  # APIConnection instances have a {#server} attribute which contains an
  # instance of {JSS::Server} q.v., representing the JSS to which it's connected.
  #
  class APIConnection

    # Class Constants
    #####################################

    # The base API path in the jss URL
    RSRC_BASE = 'JSSResource'.freeze

    # A url path to load to see if there's an API available at a host.
    # This just loads the API resource docs page
    TEST_PATH = "#{RSRC_BASE}/accounts".freeze

    # If the test path loads correctly from a casper server, it'll contain
    # this text (this is what we get when we make an unauthenticated
    # API call.)
    TEST_CONTENT = '<p>The request requires user authentication</p>'.freeze

    # The Default port
    HTTP_PORT = 9006

    # The SSL port
    SSL_PORT = 8443

    # The top line of an XML doc for submitting data via API
    XML_HEADER = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'.freeze

    # Default timeouts in seconds
    DFT_OPEN_TIMEOUT = 60
    DFT_TIMEOUT = 60

    # The Default SSL Version
    # As of Casper 9.61 we can't use SSL, must use TLS, since SSLv3 was susceptible to poodles.
    # NOTE - this requires rest-client v 1.7.0 or higher
    # which requires mime-types 2.0 or higher, which requires ruby 1.9.2 or higher!
    # That means that support for ruby 1.8.7 stops with Casper 9.6
    DFT_SSL_VERSION = 'TLSv1'.freeze

    # Attributes
    #####################################

    # @return [String] the username who's connected to the JSS API
    attr_reader :jss_user

    # @return [RestClient::Resource] the underlying connection resource
    attr_reader :cnx

    # @return [Boolean] are we connected right now?
    attr_reader :connected

    # @return [JSS::Server] the details of the JSS to which we're connected.
    attr_reader :server

    # @return [String] the hostname of the JSS to which we're connected.
    attr_reader :server_host

    # @return [Integer] the port used for the connection
    attr_reader :port

    # @return [String] the protocol being used: http or https
    attr_reader :protocol

    # @return [RestClient::Response] The response from the most recent API call
    attr_reader :last_http_response

    # @return [String] The base URL to to the current REST API
    attr_reader :rest_url

    # @return [String,Symbol] an arbitrary name that can be given to this
    # connection during initialization, using the name: parameter.
    # defaults to user@hostname:port
    attr_reader :name

    # @return [Hash]
    # This Hash holds the most recent API query for a list of all items in any
    # APIObject subclass, keyed by the subclass's RSRC_LIST_KEY.
    # See the APIObject.all class method.
    #
    # When the APIObject.all method is called without an argument,
    # and this hash has a matching value, the value is returned, rather than
    # requerying the API. The first time a class calls .all, or whnever refresh
    # is not false, the API is queried and the value in this hash is updated.
    attr_reader :object_list_cache

    # Constructor
    #####################################

    # To connect, use JSS.api_connection.connect
    #
    def initialize(args = {})
      @name = args.delete :name
      @name ||= :disconnected
      @connected = false
      @object_list_cache = {}
      connect args unless args.empty?
    end # init

    # Instance Methods
    #####################################

    # Connect to the JSS API.
    #
    # @param args[Hash] the keyed arguments for connection.
    #
    # @option args :server[String] the hostname of the JSS API server, required if not defined in JSS::CONFIG
    #
    # @option args :port[Integer] the port number to connect with, defaults to 8443
    #
    # @option args :use_ssl[Boolean] should the connection be made over SSL? Defaults to true.
    #
    # @option args :verify_cert[Boolean] should HTTPS SSL certificates be verified. Defaults to true.
    #   If your connection raises RestClient::SSLCertificateNotVerified, and you don't care about the
    #   validity of the SSL cert. just set this explicitly to false.
    #
    # @option args :user[String] a JSS user who has API privs, required if not defined in JSS::CONFIG
    #
    # @option args :pw[String,Symbol] Required, the password for that user, or :prompt, or :stdin
    #   If :prompt, the user is promted on the commandline to enter the password for the :user.
    #   If :stdin#, the password is read from a line of std in represented by the digit at #,
    #   so :stdin3 reads the passwd from the third line of standard input. defaults to line 1,
    #   if no digit is supplied. see {JSS.stdin}
    #
    # @option args :open_timeout[Integer] the number of seconds to wait for an initial response, defaults to 60
    #
    # @option args :timeout[Integer] the number of seconds before an API call times out, defaults to 60
    #
    # @return [true]
    #
    def connect(args = {})
      args = apply_connection_defaults args
      verify_basic_args args
      @jss_user = args[:user]

      @rest_url = build_rest_url args

      # figure out :verify_ssl from :verify_cert
      args[:verify_ssl] = verify_ssl args

      # figure out :password from :pw
      args[:password] = acquire_password args

      # heres our connection
      @cnx = RestClient::Resource.new(@rest_url.to_s, args)

      verify_server_version

      @name = "#{@jss_user}@#{@server_host}:#{@port}" if @name.nil? || @name == :disconnected
      @connected ? hostname : nil
    end # connect

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      @connected ? "Using #{@rest_url} as user #{@jss_user}" : 'not connected'
    end

    # Reset the response timeout for the rest connection
    #
    # @param timeout[Integer] the new timeout in seconds
    #
    # @return [void]
    #
    def timeout=(timeout)
      @cnx.options[:timeout] = timeout
    end

    # Reset the open-connection timeout for the rest connection
    #
    # @param timeout[Integer] the new timeout in seconds
    #
    # @return [void]
    #
    def open_timeout=(timeout)
      @cnx.options[:open_timeout] = timeout
    end

    # With a REST connection, there isn't any real "connection" to disconnect from
    # So to disconnect, we just unset all our credentials.
    #
    # @return [void]
    #
    def disconnect
      @jss_user = nil
      @rest_url = nil
      @server_host = nil
      @cnx = nil
      @connected = false
    end # disconnect

    # Get an arbitrary JSS resource
    #
    # The first argument is the resource to get (the part of the API url
    # after the 'JSSResource/' )
    #
    # By default we get the data in JSON, and parse it
    # into a ruby data structure (arrays, hashes, strings, etc)
    # with symbolized Hash keys.
    #
    # @param rsrc[String] the resource to get
    #   (the part of the API url after the 'JSSResource/' )
    #
    # @param format[Symbol] either ;json or :xml
    #  If the second argument is :xml, the XML data is returned as a String.
    #
    # @return [Hash,String] the result of the get
    #
    def get_rsrc(rsrc, format = :json)
      # puts object_id
      raise JSS::InvalidConnectionError, 'Not Connected. Use JSS.api.connect first.' unless @connected
      rsrc = URI.encode rsrc
      @last_http_response = @cnx[rsrc].get(accept: format)
      return JSON.parse(@last_http_response, symbolize_names: true) if format == :json
    end

    # Change an existing JSS resource
    #
    # @param rsrc[String] the API resource being changed, the URL part after 'JSSResource/'
    #
    # @param xml[String] the xml specifying the changes.
    #
    # @return [String] the xml response from the server.
    #
    def put_rsrc(rsrc, xml)
      raise JSS::InvalidConnectionError, 'Not Connected. Use JSS.api_connection.connect first.' unless @connected

      # convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;')

      # send the data
      @last_http_response = @cnx[rsrc].put(xml, content_type: 'text/xml')
    rescue RestClient::Conflict => exception
      raise_conflict_error(exception)
    end

    # Create a new JSS resource
    #
    # @param rsrc[String] the API resource being created, the URL part after 'JSSResource/'
    #
    # @param xml[String] the xml specifying the new object.
    #
    # @return [String] the xml response from the server.
    #
    def post_rsrc(rsrc, xml = '')
      raise JSS::InvalidConnectionError, 'Not Connected. Use JSS.api_connection.connect first.' unless @connected

      # convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;') if xml

      # send the data
      @last_http_response = @cnx[rsrc].post xml, content_type: 'text/xml', accept: :json
    rescue RestClient::Conflict => exception
      raise_conflict_error(exception)
    end # post_rsrc

    # Delete a resource from the JSS
    #
    # @param rsrc[String] the resource to create, the URL part after 'JSSResource/'
    #
    # @return [String] the xml response from the server.
    #
    def delete_rsrc(rsrc, xml = nil)
      raise JSS::InvalidConnectionError, 'Not Connected. Use JSS.api_connection.connect first.' unless @connected
      raise MissingDataError, 'Missing :rsrc' if rsrc.nil?

      # payload?
      return delete_with_payload rsrc, xml if xml

      # delete the resource
      @last_http_response = @cnx[rsrc].delete
    end # delete_rsrc

    # Test that a given hostname & port is a JSS API server
    #
    # @param server[String] The hostname to test,
    #
    # @param port[Integer] The port to try connecting on
    #
    # @return [Boolean] does the server host a JSS API?
    #
    def valid_server?(server, port = SSL_PORT)
      # cheating by shelling out to curl, because getting open-uri, or even net/http to use
      # ssl_options like :OP_NO_SSLv2 and :OP_NO_SSLv3 will take time to figure out..
      return true if `/usr/bin/curl -s 'https://#{server}:#{port}/#{TEST_PATH}'`.include? TEST_CONTENT
      return true if `/usr/bin/curl -s 'http://#{server}:#{port}/#{TEST_PATH}'`.include? TEST_CONTENT
      false

      # # try ssl first
      # # NOTE:  doesn't work if we can't disallow SSLv3 or force TLSv1
      # # See cheat above.
      # begin
      #   return true if open("https://#{server}:#{port}/#{TEST_PATH}", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read.include? TEST_CONTENT
      #
      # rescue
      #   # then regular http
      #   begin
      #     return true if open("http://#{server}:#{port}/#{TEST_PATH}").read.include? TEST_CONTENT
      #   rescue
      #     # any errors = no API
      #     return false
      #   end # begin
      # end # begin
      # # if we're here, no API
      # false
    end

    # The server to which we are connected, or will
    # try connecting to if none is specified with the
    # call to #connect
    #
    # @return [String] the hostname of the server
    #
    def hostname
      return @server_host if @server_host
      srvr = JSS::CONFIG.api_server_name
      srvr ||= JSS::Client.jss_server
      srvr
    end

    # aliases
    alias connected? connected
    alias host hostname

    # Private Insance Methods
    ####################################
    private

    # Apply defaults from the JSS::CONFIG,
    # then from the JSS::Client,
    # then from the module defaults
    # to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_connection_defaults(args)
      apply_defaults_from_config(args)
      apply_defaults_from_client(args)
      apply_module_defaults(args)
    end

    # Apply defaults from the JSS::CONFIG
    # to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_defaults_from_config(args)
      # settings from config if they aren't in the args
      args[:server] ||= JSS::CONFIG.api_server_name
      args[:port] ||= JSS::CONFIG.api_server_port
      args[:user] ||= JSS::CONFIG.api_username
      args[:timeout] ||= JSS::CONFIG.api_timeout
      args[:open_timeout] ||= JSS::CONFIG.api_timeout_open
      args[:ssl_version] ||= JSS::CONFIG.api_ssl_version

      # if verify cert was not in the args, get it from the prefs.
      # We can't use ||= because the desired value might be 'false'
      args[:verify_cert] = JSS::CONFIG.api_verify_cert if args[:verify_cert].nil?
      args
    end # apply_defaults_from_config

    # Apply defaults from the JSS::Client
    # to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_defaults_from_client(args)
      return unless JSS::Client.installed?
      # these settings can come from the jamf binary config, if this machine is a JSS client.
      args[:server] ||= JSS::Client.jss_server
      args[:port] ||= JSS::Client.jss_port
      args[:use_ssl] ||= JSS::Client.jss_protocol.to_s.end_with? 's'
      args
    end

    # Apply the module defaults to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_module_defaults(args)
      # defaults from the module if needed
      args[:port] ||= args[:use_ssl] ? SSL_PORT : HTTP_PORT
      args[:timeout] ||= DFT_TIMEOUT
      args[:open_timeout] ||= DFT_OPEN_TIMEOUT
      args[:ssl_version] ||= DFT_SSL_VERSION
      args
    end

    # Raise execeptions if we don't have essential data for the connection
    #
    # @param args[Hash] The args for #connect
    #
    # @return [void]
    #
    def verify_basic_args(args)
      # must have server, user, and pw
      raise JSS::MissingDataError, 'No JSS :server specified, or in configuration.' unless args[:server]
      raise JSS::MissingDataError, 'No JSS :user specified, or in configuration.' unless args[:user]
      raise JSS::MissingDataError, "Missing :pw for user '#{args[:user]}'" unless args[:pw]
    end

    # Verify that we can connect with the args provided, and that
    # the server version is high enough for this version of ruby-jss.
    #
    # This makes the first API GET call and will raise an exception if things
    # are wrong, like failed authentication. Will also raise an exception
    # if the JSS version is too low
    # (see also JSS::Server)
    #
    # @return [void]
    #
    def verify_server_version
      @connected = true

      # the jssuser resource is readable by anyone with a JSS acct
      # regardless of their permissions.
      # However, it's marked as 'deprecated'. Hopefully jamf will
      # keep this basic level of info available for basic authentication
      # and JSS version checking.
      begin
        @server = JSS::Server.new get_rsrc('jssuser')[:user]
      rescue RestClient::Unauthorized, RestClient::Request::Unauthorized
        raise JSS::AuthenticationError, "Incorrect JSS username or password for '#{JSS.api_connection.jss_user}@#{JSS.api_connection.server_host}'."
      end

      min_vers = JSS.parse_jss_version(JSS::MINIMUM_SERVER_VERSION)[:version]
      return unless @server.version < min_vers
      err_msg = "JSS version #{@server.raw_version} to low. Must be >= #{min_vers}"
      @connected = false
      raise JSS::UnsupportedError, err_msg
    end

    # Build the base URL for the API connection
    #
    # @param args[Hash] The args for #connect
    #
    # @return [String] The URI encoded URL
    #
    def build_rest_url(args)
      # we're using ssl if:
      #  1) args[:use_ssl] is anything but false
      # or
      #  2) the port is the default casper ssl port.
      (args[:use_ssl] = (args[:use_ssl] != false)) || (args[:port] == SSL_PORT)

      # and here's the URL
      @protocol = 'http'
      @protocol << 's' if args[:use_ssl]
      @server_host = args[:server]
      @port = args[:port].to_i
      URI.encode "#{@protocol}://#{@server_host}:#{@port}/#{RSRC_BASE}"
    end

    # From whatever was given in args[:pw], figure out the real password
    #
    # @param args[Hash] The args for #connect
    #
    # @return [String] The password for the connection
    #
    def acquire_password(args)
      if args[:pw] == :prompt
        JSS.prompt_for_password "Enter the password for JSS user #{args[:user]}@#{args[:server]}:"
      elsif args[:pw].is_a?(Symbol) && args[:pw].to_s.start_with?('stdin')
        args[:pw].to_s =~ /^stdin(\d+)$/
        line = Regexp.last_match(1)
        line ||= 1
        JSS.stdin line
      else
        args[:pw]
      end
    end

    # Get the appropriate OpenSSL::SSL constant for
    # certificate verification.
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Type] description_of_returned_object
    #
    def verify_ssl(args)
      # if verify_cert is anything but false, we will verify
      args[:verify_cert] == false ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    end

    # Parses the HTTP body of a RestClient::Conflict (409 conflict)
    # exception and re-raises a JSS::ConflictError with a more
    # useful error message.
    #
    # @param exception[RestClient::Conflict] the exception to parse
    #
    # @return [void]
    #
    def raise_conflict_error(exception)
      exception.http_body =~ %r{<p>Error:(.*)</p>}
      conflict_reason = Regexp.last_match(1)
      conflict_reason ||= exception.http_body
      raise JSS::ConflictError, conflict_reason
    end

    # RestClient::Resource#delete doesn't take an HTTP payload,
    # but some JSS API resources require it (notably, logflush).
    #
    # This method uses RestClient::Request#execute
    # to do the same thing that RestClient::Resource#delete does, but
    # adding the payload.
    #
    # @param rsrc[String] the sub-resource we're DELETEing
    #
    # @param payload[String] The XML to be passed with the DELETE
    #
    # @param additional_headers[Type] See RestClient::Request#execute
    #
    # @param &block[Type] See RestClient::Request#execute
    #
    # @return [String] the XML response from the server.
    #
    def delete_with_payload(rsrc, payload, additional_headers = {}, &block)
      headers = (@cnx.options[:headers] || {}).merge(additional_headers)
      @last_http_response = RestClient::Request.execute(
        @cnx.options.merge(
          method: :delete,
          url: @cnx[rsrc].url,
          payload: payload,
          headers: headers
        ),
        &(block || @block)
      )
    end # delete_with_payload

  end # class APIConnection

  # Create a new APIConnection object and use it for all
  # future API calls. If connection options are provided,
  # they are passed to the connect method immediately, otherwise
  # JSS.api.connect must be called before attemting to use the
  # connection.
  #
  # @param (See JSS::APIConnection#connect)
  #
  # @return [APIConnection] the new, active connection
  #
  def self.new_api_connection(args = {})
    @api = APIConnection.new args
    @api
  end

  # Switch the connection used for all API interactions to the
  # one provided. See {JSS::APIConnection} for details and examples
  # of using multiple connections
  #
  # @param connection [APIConnection] The APIConnection to use for future
  #   API calls. If omitted, use the default connection created when ruby-jss
  #   was loaded (which may or may not yet be connected)
  #
  # @return [APIConnection] The connection now being used.
  #
  def self.use_api_connection(connection)
    raise 'API connections must be instances of JSS::APIConnection' unless connection.is_a? JSS::APIConnection
    @api = connection
  end


  def self.use_default_connection
    use_api_connection API
  end

  def self.api
    @api
  end

  # aliases of module methods
  class << self

    alias api_connection api
    alias connection api
    alias new_connection new_api_connection
    alias new_api new_api_connection
    alias use_api use_api_connection
    alias use_connection use_api_connection

  end

  # create the default connection
  new_api_connection(name: :default) unless @api

  # put it in a constant for backward compatibility
  API = @api unless defined? API

end # module
