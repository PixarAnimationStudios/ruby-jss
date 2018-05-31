### Copyright 2018 Pixar
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

  # Instances of this class represent a REST connection to a JSS API.
  #
  # For most cases, a single connection to a single JSS is all you need, and
  # this is ruby-jss's default behavior.
  #
  # If needed, multiple connections can be made and used sequentially or
  # simultaneously.
  #
  # == Using the default connection
  #
  # When ruby-jss is loaded, a not-yet-connected default instance of
  # JSS::APIConnection is created and stored in the constant JSS::API.
  # This connection is used as the initial 'active connection' (see below)
  # so all methods that make API calls will use it by default. For most uses,
  # where you're only going to be working with one connection to one JSS, the
  # default connection is all you need.
  #
  # Before using it you must call its {#connect} method, passing in appropriate
  # connection details and credentials.
  #
  # Example:
  #
  #    require 'ruby-jss'
  #    JSS.api.connect server: 'server.address.edu', user: 'jss-api-user', pw: :prompt
  #    # (see {JSS::APIConnection#connect} for all the connection options)
  #
  #    a_phone = JSS::MobileDevice.fetch id: 8743
  #
  #    # the mobile device was fetched through the default connection
  #
  # == Using Multiple Simultaneous Connections
  #
  # Sometimes you need to connect simultaneously to more than one JSS.
  # or to the same JSS with different credentials. ruby-jss allows you to
  # create as many connections as needed, and gives you three ways to use them:
  #
  # 1. Making a connection 'active', after which API calls go thru it
  #    automatically
  #
  #    Example:
  #
  #        a_computer = JSS::Computer.fetch id: 1234
  #
  #        # the JSS::Computer with id 1234 is fetched from the active connection
  #        # and stored in the variable 'a_computer'
  #
  #    NOTE: When ruby-jss is first loaded, the default connection (see above)
  #    is the active connection.
  #
  # 2. Passing an APIConnection instance to methods that use the API
  #
  #    Example:
  #
  #         a_computer = JSS::Computer.fetch id: 1234, api: production_api
  #
  #         # the JSS::Computer with id 1234 is fetched from the connection
  #         # stored in the variable 'production_api'. The computer is
  #         # then stored in the variable 'a_computer'
  #
  # 3. Using the APIConnection instance itself to make API calls.
  #
  #    Example:
  #
  #         a_computer = production_api.fetch :Computer, id: 1234
  #
  #         # the JSS::Computer with id 1234 is fetched from the connection
  #         # stored in the variable 'production_api'. The computer is
  #         # then stored in the variable 'a_computer'
  #
  # See below for more details about the ways to use multiple connections.
  #
  # NOTE:
  # Objects retrieved or created through an APIConnection store an internal
  # reference to that APIConnection and use that when they make other API
  # calls, thus ensuring data consistency when using multiple connections.
  #
  # Similiarly, the data caches used by APIObject list methods (e.g.
  # JSS::Computer.all, .all_names, and so on) are stored in the APIConnection
  # instance through which they were read, so they won't be incorrect when
  # you use multiple connections.
  #
  # == Making new APIConnection instances
  #
  # New connections can be created using the standard ruby 'new' method.
  #
  # If you provide connection details when calling 'new', they will be passed
  # to the {#connect} method immediately. Otherwise you can call {#connect} later.
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
  # == Using the 'Active' Connection
  #
  # While multiple connection instances can be created, only one at a time is
  # 'the active connection' and all APIObject-based access methods in ruby-jss
  # will use it automatically. When ruby-jss is loaded, the  default connection
  # (see above) is the active connection.
  #
  # To use the active connection, just call a method on an APIObject subclass
  # that uses the API.
  #
  # For example, the various list methods:
  #
  #   all_computer_sns = JSS::Computer.all_serial_numbers
  #
  #   # the list of all computer serial numbers is read from the active
  #   # connection and stored in all_computer_sns
  #
  # Fetching an object from the API:
  #
  #   victim_md = JSS::MobileDevice.fetch id: 832
  #
  #   # the variable 'victim_md' now contains a JSS::MobileDevice queried
  #   # through the active connection.
  #
  # The currently-active connection instance is available from the
  # `JSS.api` method.
  #
  # === Making a Connection Active
  #
  # Only one connection is 'active' at a time and the currently active one is
  # returned when you call `JSS.api` or its alias `JSS.active_connection`
  #
  # To activate another connection just pass it to the JSS.use_api method like so:
  #
  #   JSS.use_api production_api
  #   # the connection we stored in 'production_api' is now active
  #
  # To re-activate to the default connection, just call
  #   JSS.use_default_connection
  #
  # == Connection Names:
  #
  # As seen in the example above, you can provide a 'name:' parameter
  # (a String or a Symbol) when creating a new connection. The name can be
  # used later to identify connection objects.
  #
  # If you don't provide one, the name is ':disconnected' until you
  # connect, and then 'user@server:port' after connecting.
  #
  # The name of the default connection is always :default
  #
  # To see the name of the currently active connection, just use `JSS.api.name`
  #
  #   JSS.use_api production_api
  #   JSS.api.name  # => 'prod'
  #
  #   JSS.use_default_connection
  #   JSS.api.name  # => :default
  #
  # == Creating, Storing and Activating a connection in one step
  #
  # Both of the above steps (creating/storing a connection, and making it
  # active) can be performed in one step using the
  # `JSS.new_api_connection` method, which creates a new APIConnection, makes it
  # the active connection, and returns it.
  #
  #    production_api2 = JSS.new_api_connection(
  #      name: 'prod2',
  #      server: 'prodserver.address.org',
  #      user: 'produser',
  #      pw: :prompt
  #    )
  #
  #   JSS.api.name  # => 'prod2'
  #
  # == Passing an APIConnection object to API-related methods
  #
  # All methods that use the API can take an 'api:' parameter which
  # contains an APIConnection object. When provided, that APIconnection is
  # used rather than the active connection.
  #
  # For example:
  #
  #   prod2_computer_sns = JSS::Computer.all_serial_numbers, api: production_api2
  #
  #   # the list of all computer serial numbers is read from the connection in
  #   # the variable 'production_api2' and stored in 'prod2_computer_sns'
  #
  #   prod2_victim_md = JSS::MobileDevice.fetch id: 832, api: production_api2
  #
  #   # the variable 'prod2_victim_md' now contains a JSS::MobileDevice queried
  #   # through the connection 'production_api2'.
  #
  # == Using the APIConnection itself to make API calls.
  #
  # Rather than passing an APIConnection into another method, you can call
  # similar methods on the connection itself. For example, these two calls
  # have the same result as the two examples above:
  #
  #   prod2_computer_sns = production_api2.all :Computer, only: :serial_numbers
  #   prod2_victim_md = production_api2.fetch :MobileDevice, id: 832
  #
  # Here are the API calls you can make directly from an APIConnection object.
  # They behave practically identically to the same methods in the APIObject
  # subclasses, since they just call those methods, passing themselves in as the
  # APIConnection to use.
  #
  # - {#all}  The 'list' methods of the various APIObject classes. Use the 'only:'
  #   parameter to specify one of the sub-list-methods, like #all_ids or
  #   #all_laptops, e.g. `my_connection.all :computers, only: :id`
  # - {#map_all_ids} the equivalent of #map_all_ids_to in the APIObject classes
  # - {#valid_id} given a class and an identifier (like macaddress or udid)
  #   return a valid id or nil
  # - {#exist?} given a class and an identifier (like macaddress or udid) does
  #   the identifier exist for the class in the JSS
  # - {#match} list items in the JSS matching a query
  #   (if the object is {Matchable})
  # - {#fetch} retrieve an object from the JSS
  # - {#make} instantiate an object to be created in the JSS
  # - {#computer_checkin_settings} same as {Computer.checkin_settings}
  # - {#computer_inventory_collection_settings} same as {Computer.inventory_collection_settings}
  # - {#computer_application_usage} same as {Computer.application_usage}
  # - {#computer_management_data} same as {Computer.management_data}
  # - {#master_distribution_point} same as {DistributionPoint.master_distribution_point}
  # - {#my_distribution_point} same as {DistributionPoint.my_distribution_point}
  # - {#network_ranges} same as {NetworkSegment.network_ranges}
  # - {#network_segments_for_ip} same as {NetworkSegment.segments_for_ip}
  # - {#my_network_segments} same as {NetworkSegment.my_network_segments}
  #
  # == Low-level use of APIConnection instances.
  #
  # For most cases, using APIConnection instances as mentioned above
  # is all you'll need. However to access API resources that aren't yet
  # implemented in other parts of ruby-jss, you can use the methods
  # {#get_rsrc}, {#put_rsrc}, {#post_rsrc}, & {#delete_rsrc}
  # documented below.
  #
  # For even lower-level work, you can access the underlying RestClient::Resource
  # inside the APIConnection via the connection's {#cnx} attribute.
  #
  # APIConnection instances also have a {#server} attribute which contains an
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

    # The Jamf default SSL port, default for locally-hosted servers
    SSL_PORT = 8443

    # The https default SSL port, default for Jamf Cloud servers
    HTTPS_SSL_PORT = 443

    # if either of these is specified, we'll default to SSL
    SSL_PORTS = [SSL_PORT, HTTPS_SSL_PORT].freeze

    # Recognize Jamf Cloud servers
    JAMFCLOUD_DOMAIN = 'jamfcloud.com'.freeze

    # JamfCloud connections default to 443, not 8443
    JAMFCLOUD_PORT = HTTPS_SSL_PORT

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

    # If name: is provided (as a String or Symbol) that will be
    # stored as the APIConnection's name attribute.
    #
    # For other available parameters, see {#connect}.
    #
    # If they are provided, they will be used to establish the
    # connection immediately.
    #
    # If not, you must call {#connect} before accessing the API.
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

      # confirm we know basics
      verify_basic_args args

      # parse our ssl situation
      verify_ssl args

      @jss_user = args[:user]

      @rest_url = build_rest_url args

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
      raise JSS::InvalidConnectionError, 'Not Connected. Use .connect first.' unless @connected
      raise JSS::InvalidDataError, 'format must be :json or :xml' unless format == :json || format == :xml

      rsrc = URI.encode rsrc
      @last_http_response = @cnx[rsrc].get(accept: format)
      format == :json ? JSON.parse(@last_http_response, symbolize_names: true) : @last_http_response
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
      raise JSS::InvalidConnectionError, 'Not Connected. Use .connect first.' unless @connected

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
      raise JSS::InvalidConnectionError, 'Not Connected. Use .connect first.' unless @connected

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
      raise JSS::InvalidConnectionError, 'Not Connected. Use .connect first.' unless @connected
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

    #################

    # Call one of the 'all*' methods on a JSS::APIObject subclass
    # using this APIConnection.
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass
    #   see {JSS.api_object_class}
    #
    # @param refresh[Boolean] Should the data be re-read from the API?
    #
    # @param only[String,Symbol] Limit the output to subset or data. All
    #   APIObject subclasses can take :ids or :names, which calls the .all_ids
    #   and .all_names methods. Some subclasses can take other options, e.g.
    #   MobileDevice can take :udids
    #
    # @return [Array] The list of items for the class
    #
    def all(class_name, refresh = false, only: nil)
      the_class = JSS.api_object_class(class_name)
      list_method = only ? :"all_#{only}" : :all

      raise ArgumentError, "Unknown identifier: #{only} for #{the_class}" unless
        the_class.respond_to? list_method

      the_class.send list_method, refresh, api: self
    end

    # Call the 'map_all_ids_to' method on a JSS::APIObject subclass
    # using this APIConnection.
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass
    #   see {JSS.api_object_class}
    #
    # @param refresh[Boolean] Should the data be re-read from the API?
    #
    # @param to[String,Symbol] the value to which the ids should be mapped
    #
    # @return [Hash] The ids for the class keyed to the requested identifier
    #
    def map_all_ids(class_name, refresh = false, to: nil)
      raise "'to:' value must be provided for mapping ids." unless to
      the_class = JSS.api_object_class(class_name)
      the_class.map_all_ids_to to, refresh, api: self
    end

    # Call the 'valid_id' method on a JSS::APIObject subclass
    # using this APIConnection. See {JSS::APIObject.valid_id}
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass,
    #   see {JSS.api_object_class}
    #
    # @param identifier[String,Symbol] the value to which the ids should be mapped
    #
    # @param refresh[Boolean] Should the data be re-read from the API?
    #
    # @return [Integer, nil] the id of the matching object of the class,
    #   or nil if there isn't one
    #
    def valid_id(class_name, identifier, refresh = true)
      the_class = JSS.api_object_class(class_name)
      the_class.valid_id identifier, refresh, api: self
    end

    # Call the 'exist?' method on a JSS::APIObject subclass
    # using this APIConnection. See {JSS::APIObject.exist?}
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass
    #   see {JSS.api_object_class}
    #
    # @param identifier[String,Symbol] the value to which the ids should be mapped
    #
    # @param refresh[Boolean] Should the data be re-read from the API?
    #
    # @return [Boolean] Is there an object of this class in the JSS matching
    #   this indentifier?
    #
    def exist?(class_name, identifier, refresh = false)
      !valid_id(class_name, identifier, refresh).nil?
    end

    # Call {Matchable.match} for the given class.
    #
    # See {Matchable.match}
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass
    #   see {JSS.api_object_class}
    #
    # @return (see Matchable.match)
    #
    def match(class_name, term)
      the_class = JSS.api_object_class(class_name)
      raise JSS::UnsupportedError, "Class #{the_class} is not matchable" unless the_class.respond_to? :match
      the_class.match term, api: self
    end

    # Retrieve an object of a given class from the API
    # See {APIObject.fetch}
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass
    #   see {JSS.api_object_class}
    #
    # @return [APIObject] The ruby-instance of the object.
    #
    def fetch(class_name, arg)
      the_class = JSS.api_object_class(class_name)
      the_class.fetch arg, api: self
    end

    # Make a ruby instance of a not-yet-existing APIObject
    # of the given class
    # See {APIObject.make}
    #
    # @param class_name[String,Symbol] The name of a JSS::APIObject subclass
    #   see {JSS.api_object_class}
    #
    # @return [APIObject] The un-created ruby-instance of the object.
    #
    def make(class_name, **args)
      the_class = JSS.api_object_class(class_name)
      args[:api] = self
      the_class.make args
    end

    # Call {JSS::Computer.checkin_settings} q.v.,  passing this API
    # connection
    #
    def computer_checkin_settings
      JSS::Computer.checkin_settings api: self
    end

    # Call {JSS::Computer.inventory_collection_settings} q.v., passing this API
    # connection
    #
    def computer_inventory_collection_settings
      JSS::Computer.inventory_collection_settings api: self
    end

    # Call {JSS::Computer.application_usage} q.v., passing this API
    # connection
    #
    def computer_application_usage(ident, start_date, end_date = nil)
      JSS::Computer.application_usage ident, start_date, end_date, api: self
    end

    # Call {JSS::Computer.management_data} q.v., passing this API
    # connection
    #
    def computer_management_data(ident, subset: nil, only: nil)
      JSS::Computer.management_data ident, subset: subset, only: only, api: self
    end

    # Call {JSS::Computer.history} q.v., passing this API
    # connection
    #
    # @deprecated Please use JSS::Computer.management_history or its
    #   convenience methods. @see JSS::ManagementHistory
    #
    def computer_history(ident, subset: nil)
      JSS::Computer.history ident, subset, api: self
    end

    # Call {JSS::Computer.send_mdm_command} q.v.,  passing this API
    # connection
    #
    # @deprecated Please use JSS::Computer.send_mdm_command or its
    #   convenience methods. @see JSS::MDM
    #
    def send_computer_mdm_command(targets, command, passcode = nil)
      opts = passcode ? { passcode: passcode } : {}
      JSS::Computer.send_mdm_command targets, command, opts: opts, api: self
    end

    # Get the DistributionPoint instance for the master
    # distribution point in the JSS. If there's only one
    # in the JSS, return it even if not marked as master.
    #
    # @param refresh[Boolean] re-read from the API?
    #
    # @return [JSS::DistributionPoint]
    #
    def master_distribution_point(refresh = false)
      @master_distribution_point = nil if refresh
      return @master_distribution_point if @master_distribution_point

      all_dps = JSS::DistributionPoint.all refresh, api: self

      @master_distribution_point =
        case all_dps.size
        when 0
          raise JSS::NoSuchItemError, 'No distribution points defined'
        when 1
          JSS::DistributionPoint.fetch id: all_dps.first[:id], api: self
        else
          JSS::DistributionPoint.fetch id: :master, api: self
        end
    end

    # Get the DistributionPoint instance for the machine running
    # this code, based on its IP address. If none is defined for this IP address,
    # use the result of master_distribution_point
    #
    # @param refresh[Boolean] should the distribution point be re-queried?
    #
    # @return [JSS::DistributionPoint]
    #
    def my_distribution_point(refresh = false)
      @my_distribution_point = nil if refresh
      return @my_distribution_point if @my_distribution_point

      my_net_seg = my_network_segments[0]
      @my_distribution_point = JSS::NetworkSegment.fetch(id: my_net_seg, api: self).distribution_point if my_net_seg
      @my_distribution_point ||= master_distribution_point refresh
      @my_distribution_point
    end

    # All NetworkSegments in this jss as IPAddr object Ranges representing the
    # Segment, e.g. with starting = 10.24.9.1 and ending = 10.24.15.254
    # the range looks like:
    #   <IPAddr: IPv4:10.24.9.1/255.255.255.255>..#<IPAddr: IPv4:10.24.15.254/255.255.255.255>
    #
    # Using the #include? method on those Ranges is very useful.
    #
    # @param refresh[Boolean] should the data be re-queried?
    #
    # @return [Hash{Integer => Range}] the network segments as IPv4 address Ranges
    #
    def network_ranges(refresh = false)
      @network_ranges = nil if refresh
      return @network_ranges if @network_ranges
      @network_ranges = {}
      JSS::NetworkSegment.all(refresh, api: self).each do |ns|
        @network_ranges[ns[:id]] = IPAddr.new(ns[:starting_address])..IPAddr.new(ns[:ending_address])
      end
      @network_ranges
    end # def network_segments

    # Find the ids of the network segments that contain a given IP address.
    #
    # Even tho IPAddr.include? will take a String or an IPAddr
    # I convert the ip to an IPAddr so that an exception will be raised if
    # the ip isn't a valid ip.
    #
    # @param ip[String, IPAddr] the IP address to locate
    #
    # @param refresh[Boolean] should the data be re-queried?
    #
    # @return [Array<Integer>] the ids of the NetworkSegments containing the given ip
    #
    def network_segments_for_ip(ip)
      ok_ip = IPAddr.new(ip)
      matches = []
      network_ranges.each { |id, subnet| matches << id if subnet.include?(ok_ip) }
      matches
    end

    # Find the current network segment ids for the machine running this code
    #
    # @return [Array<Integer>]  the NetworkSegment ids for this machine right now.
    #
    def my_network_segments
      network_segments_for_ip JSS::Client.my_ip_address
    end

    # Send an MDM command to one or more mobile devices managed by
    # this JSS
    #
    # see {JSS::MobileDevice.send_mdm_command}
    #
    # @deprecated Please use JSS::MobileDevice.send_mdm_command or its
    #   convenience methods. @see JSS::MDM
    #
    def send_mobiledevice_mdm_command(targets, command, data = {})
      JSS::MobileDevice.send_mdm_command(targets, command, opts: data, api: self)
    end

    # Remove the various cached data
    # from the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      vars = instance_variables.sort
      vars.delete :@object_list_cache
      vars.delete :@last_http_response
      vars.delete :@network_ranges
      vars.delete :@my_distribution_point
      vars.delete :@master_distribution_point
      vars
    end

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
      args[:port] ||= JSS::Client.jss_port.to_i
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
      args[:port] ||= args[:server].to_s.end_with?(JAMFCLOUD_DOMAIN) ? JAMFCLOUD_PORT : SSL_PORT
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
        @server = JSS::Server.new get_rsrc('jssuser')[:user], self
      rescue RestClient::Unauthorized
        raise JSS::AuthenticationError, "Incorrect JSS username or password for '#{@jss_user}@#{@server_host}:#{@port}'."
      end

      min_vers = JSS.parse_jss_version(JSS::MINIMUM_SERVER_VERSION)[:version]
      return if @server.version >= min_vers # we're good...

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
      # use SSL for those ports unless specifically told not to
      if SSL_PORTS.include? args[:port]
        args[:use_ssl] = true if args[:use_ssl].nil?
      end
      # if verify_cert is anything but false, we will verify
      args[:verify_ssl] =
        if args[:verify_cert] == false
          OpenSSL::SSL::VERIFY_NONE
        else
          OpenSSL::SSL::VERIFY_PEER
        end
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
      exception.http_body =~ %r{<p>Error:(.*)(<|$)}
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

  # Make the default connection (Stored in JSS::API) active
  #
  # @return [void]
  #
  def self.use_default_connection
    use_api_connection API
  end

  # The currently active JSS::APIConnection instance.
  #
  # @return [JSS::APIConnection]
  #
  def self.api
    @api
  end

  # aliases of module methods
  class << self

    alias api_connection api
    alias connection api
    alias active_connection api

    alias new_connection new_api_connection
    alias new_api new_api_connection

    alias use_api use_api_connection
    alias use_connection use_api_connection
    alias activate_connection use_api_connection

  end

  # create the default connection
  new_api_connection(name: :default) unless @api

  # Save the default connection in the API constant,
  # mostly for backward compatibility.
  API = @api unless defined? API

end # module
