### Copyright 2020 Pixar
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

require 'faraday' # >= 0.17.0
require 'faraday_middleware' # >= 0.13.0

###
module JSS

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
  # == Low-level use of APIConnection instances.
  #
  # For most cases, using APIConnection instances as mentioned above
  # is all you'll need. However to access API resources that aren't yet
  # implemented in other parts of ruby-jss, you can use the methods
  # {#get_rsrc}, {#put_rsrc}, {#post_rsrc}, & {#delete_rsrc}
  # documented below.
  #
  # For even lower-level work, you can access the underlying Faraday::Connection
  # inside the APIConnection via the connection's {#cnx} attribute.
  #
  # APIConnection instances also have a {#server} attribute which contains an
  # instance of {JSS::Server} q.v., representing the JSS to which it's connected.
  #
  class Connection

    # Class Constants
    #####################################

    # This version of ruby-jss only works with this version of the server
    # and higher
    MIN_JAMF_VERSION = Gem::Version.new('10.35.0')

    # The base of the Classic API resources
    CAPI_RSRC_BASE = 'JSSResource'.freeze

    # The base of the Jamf Pro API resources
    JPAPI_RSRC_BASE = 'api'.freeze

    # in case this is used out there, it is deprecated
    UAPI_RSRC_BASE = 'uapi'.freeze

    # pre-existing tokens must have this many seconds before
    # before they expire
    TOKEN_REUSE_MIN_LIFE = 60

    NOT_CONNECTED = 'Not Connected'.freeze

    # if @name is any of these when a connection is made, it
    # is reset to a default based on the connection params
    NON_NAMES = [NOT_CONNECTED, :unknown, nil, :disconnected].freeze

    HTTPS_SCHEME = 'https'.freeze

    # The Jamf default SSL port, default for on-prem servers
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
    DFT_SSL_VERSION = 'TLSv1_2'.freeze

    RSRC_NOT_FOUND_MSG = 'The requested resource was not found'.freeze

    # These classes are extendable, and may need cache flushing for EA definitions
    # EXTENDABLE_CLASSES = [JSS::Computer, JSS::MobileDevice, JSS::User].freeze
    EXTENDABLE_CLASSES = []

    # values for the format param of get_rsrc
    GET_FORMATS = %i[json xml].freeze

    HTTP_ACCEPT_HEADER = 'Accept'.freeze
    HTTP_CONTENT_TYPE_HEADER = 'Content-Type'.freeze

    MIME_JSON = 'application/json'.freeze
    MIME_XML = 'application/xml'.freeze

    # Attributes
    #####################################

    # These come from the token:
    # base_url, host, port, user, keep_alive?, ssl_version, verify_cert?, ssl_options,
    # pw_fallback?, jamf_version, jamf_build

    # These come from the JPAPI faraday connection object
    # timeout, open_timeout

    # @return [Faraday::Connection] the underlying C-API connection object
    attr_reader :c_cnx

    # @return [Faraday::Connection] the underlying JPAPI connection object
    attr_reader :jp_cnx

    # @return [JSS::Connection::Token] the token used for connecting
    attr_reader :token

    # @return [Boolean] are we connected right now?
    attr_reader :connected
    alias connected? connected

    # @return [String] any path in the URL below the hostname. See {#connect}
    attr_reader :server_path

    # @return [Faraday::Response] The response from the most recent API call
    attr_reader :last_http_response

    # @return [String,Symbol] an arbitrary name that can be given to this
    #   connection during initialization, using the name: parameter.
    #   defaults to user@hostname:port
    attr_reader :name

    # @return [Time] when this connection was connected
    attr_reader :login_time

    # @return [Hash] This Hash caches the results of C-API queries for an APIObject
    #   subclass's .all summary list, keyed by the subclass's RSRC_LIST_KEY.
    #   See the APIObject.all class method.
    #
    #   It also caches related data items for speedier processing:
    #
    #   - The Hashes created by APIObject.map_all_ids_to(foo), keyed by
    #     "#{RSRC_LIST_KEY}_map_#{other_key}".to_sym
    #
    #   - This hash also holds a cache of the rarely-used APIObject.all_objects
    #     hash, keyed by "#{RSRC_LIST_KEY}_objects".to_sym
    #
    #
    #   When APIObject.all, and related methods are called without an argument,
    #   and this hash has a matching value, the value is returned, rather than
    #   requerying the API. The first time a class calls .all, or whnever refresh
    #   is not false, the API is queried and the value in this hash is updated.
    attr_reader :object_list_cache

    # @return [Hash{Class: Hash{String => JSS::ExtensionAttribute}}]
    #   This Hash caches the C-API Extension Attribute
    #   definition objects for the three types of ext. attribs:
    #   ComputerExtensionAttribute, MobileDeviceExtensionAttribute, and
    #   UserExtensionAttribute, whenever they are fetched for parsing or
    #   validating extention attribute data.
    #
    #   The top-level keys are the EA classes themselves:
    #   - ComputerExtensionAttribute
    #   - MobileDeviceExtensionAttribute
    #   - UserExtensionAttribute
    #
    #   These each point to a Hash of their instances, keyed by name, e.g.
    #     {
    #      "A Computer EA" => <JSS::ComputerExtensionAttribute...>,
    #      "A different Computer EA" => <JSS::ComputerExtensionAttribute...>,
    #      ...
    #     }
    #
    attr_reader :ext_attr_definition_cache

    # @return [Hash] This Hash holds the most recently fetched instance of a JPAPI
    #   SingletonResource subclass, keyed by the subclass itself.
    #
    #   SingletonResource.fetch will return the instance from here, if it exists,
    #   unless the first parameter is truthy.
    attr_reader :singleton_cache

    # @return [Hash],This Hash holds the most recent API data (an Array of Hashes)
    #   for the list
    #   of all items in a JPAPI CollectionResource subclass, keyed by the subclass
    #   itself.
    #
    #   CollectionResource.all return the appropriate data from here, if it exists,
    #
    #   See the CollectionResource.all class method.
    attr_reader :collection_cache

    # @return [Hash] This hash holds JPAPI ExtensionAttribute instances, which are
    #   used for validating values passed to Extendable.set_ext_attr.
    attr_reader :ext_attr_cache

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
    # See #connect for the parameters
    #
    def initialize(url = nil, **params)
      @name = params.delete :name
      @connected = false
      @object_list_cache = {}
      @ext_attr_definition_cache = {}
      @singleton_cache = {}
      @collection_cache = {}
      @ext_attr_cache = {}

      connect url, params
    end # init

    # Instance Methods
    #####################################

    # Connect to the both the Classic and Jamf Pro APIs
    #
    # @param args[Hash] the keyed arguments for connection.
    #
    # @option args :host[String] the hostname of the JSS API server, required if not defined in JSS::CONFIG
    #
    # @option args :server_path[String] If your JSS is not at the root of the server, e.g.
    #   if it's at
    #     https://myjss.myserver.edu:8443/dev_mgmt/jssweb
    #   rather than
    #     https://myjss.myserver.edu:8443/
    #   then use this parameter to specify the path below the root e.g:
    #     server_path: 'dev_mgmt/jssweb'
    #
    # @option args :port[Integer] the port number to connect with, defaults to 8443
    #
    # @option args :use_ssl[Boolean] should the connection be made over SSL? Defaults to true.
    #
    # @option args :verify_cert[Boolean] should HTTPS SSL certificates be verified. Defaults to true.
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
    def connect(url = nil, **params)
      # reset all values, flush caches
      disconnect

      # If there's a Token object in :token, this sets @token,
      # and adds host, port, user from that token
      parse_token params

      # Get host, port, user and pw from a URL, add to params if needed
      parse_url url, params

      # apply defaults from config, client, and then ruby-jss itself.
      apply_default_params params

      # Once we're here, all params have been parsed & defaulted into the
      # params hash, so make sure we have the minimum needed params for a connection
      verify_basic_params params

      # if no @token already, get one from from
      # either a token string or a pw
      unless @token
        if params[:token].is_a? String
          # if pw_fallback, the pw must be acquired, since it isn't in the token
          # Can't do this yet, cuz we need to create the Token instance first in order
          # to learn who the user is!
          #  params[:pw] = acquire_password(params[:host], params[:user], params[:pw]) if params[:pw_fallback]
          token_src = :token_string
        else
          params[:pw] = acquire_password(params[:host], params[:user], params[:pw])
          token_src = :pw
        end
        @token = token_from token_src, params
      end

      verify_server_version

      @login_time = Time.now
      @name ||= "#{user}@#{host}:#{port}"

      @c_base_url = base_url + CAPI_RSRC_BASE
      @jp_base_url = base_url + JPAPI_RSRC_BASE

      # the faraday connection objects
      @c_cnx = create_classic_connection params
      @jp_cnx = create_jp_connection params

      @connected = true
    end # connect

    # With a REST connection, there isn't any real "connection" to disconnect from
    # So to disconnect, we just unset all our credentials.
    #
    # @return [void]
    #
    def disconnect
      flushcache

      @login_time = nil
      @jp_cnx = nil
      @c_cnx = nil
      @c_base_url = nil
      @jp_base_url = nil
      @server_path = nil

      @token&.invalidate
      @token = nil
      @connected = false
      :disconnected
    end # disconnect


    #####  Parsing Params & creating connections
    ######################################################

    # Get host, port, & user from a Token object
    # or just the user from a token string.
    def parse_token(params)
      return unless params[:token].is_a? JSS::Connection::Token

      verify_token params[:token]
      @token = params[:token]
    end

    # Raise execeptions if we were given an unusable token object
    #
    # @param params[Hash] The params for #connect
    #
    # @return [void]
    #
    def verify_token(token)
      raise JSS::InvalidConnectionError, 'Cannot use token: it has expired' if token.expired?
      raise JSS::InvalidConnectionError, 'Cannot use token: it is invalid' unless token.valid?

      if token.secs_remaining < TOKEN_REUSE_MIN_LIFE
        raise JSS::InvalidConnectionError,
              "Cannot use token: it expires in less than #{TOKEN_REUSE_MIN_LIFE} seconds"
      end
    end

    # Get host, port, user and pw from a URL, overriding any already in the params
    #
    # @return [String, nil] the pw if present
    #
    def parse_url(url, params)
      return unless url

      url = URI.parse url.to_s
      raise ArgumentError, 'Invalid url, scheme must be https' unless url.scheme == HTTPS_SCHEME

      # this removes any user and pw from the url, so we can give it to the token
      params[:given_url] = "#{url.scheme}://#{url.host}:#{url.port}#{url.path}/"
      params[:host] = url.host
      params[:port] = url.port
      params[:user] = url.user if url.user
      params[:pw] = url.password if url.password
    end

    # Apply defaults to the unset params for the #connect method
    # First apply them from from the Jamf.config,
    # then from the Jamf::Client (read from the jamf binary config),
    # then from the Jamf module defaults
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_default_params(params)
      # must have a host, but accept legacy :server as well as :host
      params[:host] ||= params[:server]

      # if we have no port set by this point, set to cloud port
      # if host is a cloud host. But leave port nil for other hosts
      # (will be set via client defaults or module defaults)
      params[:port] ||= JAMFCLOUD_PORT if params[:host].to_s.end_with?(JAMFCLOUD_DOMAIN)

      apply_defaults_from_config(params)

      apply_defaults_from_client(params)

      apply_module_defaults(params)
    end

    # Apply defaults from the Jamf.config
    # to the params for the #connect method
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_defaults_from_config(params)
      # settings from config if they aren't in the params
      params[:host] ||= JSS.config.api_server_name
      params[:port] ||= JSS.config.api_server_port
      params[:user] ||= JSS.config.api_username
      params[:timeout] ||= JSS.config.api_timeout
      params[:open_timeout] ||= JSS.config.api_timeout_open
      params[:ssl_version] ||= JSS.config.api_ssl_version

      # if verify cert was not in the params, get it from the prefs.
      # We can't use ||= because the desired value might be 'false'
      params[:verify_cert] = JSS.config.api_verify_cert if params[:verify_cert].nil?
    end # apply_defaults_from_config

    # Apply defaults from the Jamf::Client
    # to the params for the #connect method
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_defaults_from_client(params)
      return unless JSS::Client.installed?

      # these settings can come from the jamf binary config,
      # if this machine is a Jamf client.
      params[:host] ||= JSS::Client.jss_server
      params[:port] ||= JSS::Client.jss_port.to_i
    rescue
      nil
    end

    # Apply the module defaults to the params for the #connect method
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_module_defaults(params)
      # if we have no port set by this point, assume on-prem.
      params[:port] ||= SSL_PORT
      params[:timeout] ||= DFT_TIMEOUT
      params[:open_timeout] ||= DFT_OPEN_TIMEOUT
      params[:ssl_version] ||= DFT_SSL_VERSION
      params[:token_refresh_buffer] ||= self.class::Token::MIN_REFRESH_BUFFER
      # if we have a TTY, pw defaults to :prompt
      params[:pw] ||= :prompt if $stdin.tty?
    end

    # Raise execeptions if we don't have essential data for a new connection
    # namely a host, user, and pw
    #
    # @param params[Hash] The params for #connect
    #
    # @return [void]
    #
    def verify_basic_params(params)
      # if given a Token object, it has host, port, user, and base_url
      # and is already parsed
      return if @token

      # must have a host, it could have come from a url, or a param
      raise Jamf::MissingDataError, 'No Jamf :host specified, or in configuration.' unless params[:host]

      # no need for user or pass if using a token string
      # (tho a pw might be given)
      return if params[:token].is_a? String

      # must have user and pw
      raise Jamf::MissingDataError, 'No Jamf :user specified, or in configuration.' unless params[:user]
      raise Jamf::MissingDataError, "No :pw specified for user '#{params[:user]}'" unless params[:pw]
    end

    # given a token string or a password, get a valid token
    # Token.new will raise an exception if the token string or
    # credentials are invalid
    def token_from(type, params)
      token_params = {
        base_url: build_base_url(params),
        user: params[:user],
        timeout: params[:timeout],
        keep_alive: params[:keep_alive],
        refresh_buffer: params[:token_refresh_buffer],
        pw_fallback: params[:pw_fallback],
        ssl_version: params[:ssl_version],
        verify_cert: params[:verify_cert]
      }
      token_params[:token_string] = params[:token] if type == :token_string
      token_params[:pw] = params[:pw] unless params[:pw].is_a? Symbol

      self.class::Token.new token_params
    end

    # Build the base URL for the API connection
    #
    # @param args[Hash] The args for #connect
    #
    # @return [String] The URI encoded URL
    #
    def build_base_url(params)
      return params[:given_url] if params[:given_url]

      # trim any potential  leading slash on server_path, ensure a trailing slash
      server_path = params[:server_path].to_s.delete_prefix '/'
      server_path.delete_suffix! '/'

      # and here's the URL
      "#{HTTPS_SCHEME}://#{params[:host]}:#{params[:port]}/#{server_path}/"
    end

    # From whatever was given in args[:pw], figure out the real password
    #
    # @param args[Hash] The args for #connect
    #
    # @return [String] The password for the connection
    #
    def acquire_password(host, user, pw)
      if pw == :prompt
        JSS.prompt_for_password "Enter the password for JSS user #{user}@#{host}:"
      elsif pw.is_a?(Symbol) && args[:pw].to_s.start_with?('stdin')
        pw.to_s =~ /^stdin(\d+)$/
        line = Regexp.last_match(1)
        line ||= 1
        JSS.stdin line
      else
        pw
      end
    end

    # raise error if the server version is too old
    # @return [void]
    def verify_server_version
      return if jamf_version >= MIN_JAMF_VERSION

      raise(
        JSS::InvalidConnectionError,
        "This version of ruby-jss requires Jamf server version #{MIN_JAMF_VERSION} or higher. #{host} is running #{jamf_version}"
      )
    end

    # create the faraday CAPI connection object
    def create_classic_connection(params)
      Faraday.new(@c_base_url, ssl: ssl_options) do |cnx|
        cnx.authorization :Bearer, @token.token

        cnx.options[:timeout] = params[:timeout]
        cnx.options[:open_timeout] = params[:open_timeout]

        cnx.request :multipart
        cnx.request :url_encoded

        cnx.adapter Faraday::Adapter::NetHttp
      end
    end

    # create the faraday JPAPI connection object
    def create_jp_connection(params)
      Faraday.new(@jp_base_url, ssl: ssl_options) do |cnx|
        cnx.authorization :Bearer, @token.token
        cnx.headers[HTTP_ACCEPT_HEADER] = MIME_JSON

        cnx.options[:timeout] = params[:timeout]
        cnx.options[:open_timeout] = params[:open_timeout]

        cnx.request :json

        cnx.response :json, parser_options: { symbolize_names: true }

        cnx.adapter Faraday::Adapter::NetHttp
      end
    end

    #####  Getters & Setters
    ######################################################

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      @connected ? "Using #{base_url} as user #{@user}" : 'not connected'
    end

    # @return [Integer] the current response timeout for the http connection
    def timeout
      @jp_cnx.options[:timeout]
    end

    # Reset the response timeout for the rest connection
    #
    # @param timeout[Integer] the new timeout in seconds
    #
    # @return [void]
    #
    def timeout=(timeout)
      @c_cnx.options[:timeout] = timeout
      @jp_cnx.options[:timeout] = timeout
    end

    # @return [Integer] the current open-connection timeout for the http connection
    def open_timeout
      @jp_cnx.options[:open_timeout]
    end

    # Reset the open-connection timeout for the rest connection
    #
    # @param timeout[Integer] the new timeout in seconds
    #
    # @return [void]
    #
    def open_timeout=(timeout)
      @c_cnx.options[:open_timeout] = timeout
      @jp_cnx.options[:open_timeout] = timeout
    end

    # @return [URI::HTTPS] the base URL to the server
    def base_url
      @token.base_url
    end

    # @return [String] the hostname of the Jamf Pro server API connection
    def host
      @token.host
    end
    alias server host

    # @return [Integer] The port of the Jamf Pro server API connection
    def port
      @token.port
    end

    # @return [String] the username who's connected to the JSS API
    def user
      @token.user
    end

    # @return [Boolean] Is the connection token being automatically refreshed?
    def keep_alive?
      @token.keep_alive?
    end

    # @return [Boolean] If keep_alive is true, is the password Cached in memory
    #   to use if the refresh fails?
    def pw_fallback?
      @token.pw_fallback?
    end

    # @return [String] SSL version used for the connection
    def ssl_version
      @token.ssl_version
    end

    # @return [Boolean] Is the connection token being automatically refreshed?
    def verify_cert?
      @token.verify_cert?
    end
    alias verify_cert verify_cert?

    # @return [Hash] the ssl version and verify cert, to pass into faraday connections
    def ssl_options
      @token.ssl_options
    end

    # @return [Gem::Version] the version of the Jamf Pro server
    def jamf_version
      @token.jamf_version
    end

    # @return [String] the build of the Jamf Pro server
    def jamf_build
      @token.jamf_build
    end

    #####  API access
    ######################################################

    # raise exception if not connected
    def validate_connected
      raise JSS::InvalidConnectionError, "Connection '#{@name}' Not Connected. Use .connect first." unless connected?
    end

    # Get a Classic API resource
    #
    # The first argument is the resource to get (the part of the API url
    # after the 'JSSResource/' ) The resource must be properly URL escaped
    # beforehand. Note: URL.encode is deprecated, use CGI.escape
    #
    # By default we get the data in JSON, and parse it into a ruby Hash
    # with symbolized Hash keys.
    #
    # If the second parameter is :xml then the XML version is retrieved and
    # returned as a String.
    #
    # To get the raw JSON string as it comes from the API, pass raw_json: true
    #
    # @param rsrc[String] the resource to get
    #   (the part of the API url after the 'JSSResource/' )
    #
    # @param format[Symbol] either ;json or :xml
    #   If the second argument is :xml, the XML data is returned as a String.
    #
    # @param raw_json[Boolean] When GETting JSON, return the raw unparsed string
    #   (the XML is always returned as a raw string)
    #
    # @return [Hash,String] the result of the get
    #
    def c_get(rsrc, format = :json, raw_json: false)
      validate_connected
      raise JSS::InvalidDataError, 'format must be :json or :xml' unless GET_FORMATS.include?(format)

      @last_http_response =
        @c_cnx.get(rsrc) do |req|
          req.headers[HTTP_ACCEPT_HEADER] = format == :json ? MIME_JSON : MIME_XML
        end

      unless @last_http_response.success?
        handle_classic_http_error
        return
      end

      return JSON.parse(@last_http_response.body, symbolize_names: true) if format == :json && !raw_json

      # the raw body, either json or xml
      @last_http_response.body
    end
    # backward compatibility
    alias get_rsrc c_get

    # Get a JPAPI resource
    # The JSON data is parsed into a Ruby Hash with symbolized keys.
    #
    # @param rsrc[String] the resource to get
    #   (the part of the API url after the 'api/' )
    #
    # @return [Hash] the result of the get
    def jp_get(rsrc)
      validate_connected
      @last_http_response = @jp_cnx.get rsrc
      return @last_http_response.body if @last_http_response.success?

      raise JSS::Connection::APIError, resp
    end
    # backward compatibility
    alias get jp_get






















    ##########################################################
    ##########################################################
    ############# C API BELOW HERE ##############################









    # Update an existing JSS resource
    #
    # @param rsrc[String] the API resource being changed, the URL part after 'JSSResource/'
    #
    # @param xml[String] the xml specifying the changes.
    #
    # @return [String] the xml response from the server.
    #
    def put_rsrc(rsrc, xml)
      validate_connected

      # convert CRs & to &#13;
      xml.gsub!(/\r/, '&#13;')

      # send the data
      @last_http_response =
        @cnx.put(rsrc) do |req|
          req.headers[HTTP_CONTENT_TYPE_HEADER] = MIME_XML
          req.headers[HTTP_ACCEPT_HEADER] = MIME_XML
          req.body = xml
        end
      unless @last_http_response.success?
        handle_http_error
        return
      end

      @last_http_response.body
    end

    # Create a new JSS resource
    #
    # @param rsrc[String] the API resource being created, the URL part after 'JSSResource/'
    #
    # @param xml[String] the xml specifying the new object.
    #
    # @return [String] the xml response from the server.
    #
    def post_rsrc(rsrc, xml)
      validate_connected

      # convert CRs & to &#13;
      xml&.gsub!(/\r/, '&#13;')

      # send the data
      @last_http_response =
        @cnx.post(rsrc) do |req|
          req.headers[HTTP_CONTENT_TYPE_HEADER] = MIME_XML
          req.headers[HTTP_ACCEPT_HEADER] = MIME_XML
          req.body = xml
        end
      unless @last_http_response.success?
        handle_http_error
        return
      end
      @last_http_response.body
    end # post_rsrc

    # Upload a file. This is really only used for the
    # 'fileuploads' endpoint, as implemented in the
    # Uploadable mixin module, q.v.
    #
    # @param rsrc[String] the API resource being uploadad-to,
    #   the URL part after 'JSSResource/'
    #
    # @param local_file[String, Pathname] the local file to upload
    #
    # @return [String] the xml response from the server.
    #
    def upload(rsrc, local_file)
      validate_connected

      # the upload file object for faraday
      local_file = Pathname.new local_file
      upfile = Faraday::UploadIO.new(
        local_file.to_s,
        'application/octet-stream',
        local_file.basename.to_s
      )

      # send it and get the response
      @last_http_response =
        @cnx.post rsrc do |req|
          req.headers['Content-Type'] = 'multipart/form-data'
          req.body = { name: upfile }
        end

      unless @last_http_response.success?
        handle_http_error
        return false
      end

      true
    end # post_rsrc

    # Delete a resource from the JSS
    #
    # @param rsrc[String] the resource to create, the URL part after 'JSSResource/'
    #
    # @return [String] the xml response from the server.
    #
    def delete_rsrc(rsrc)
      validate_connected
      raise MissingDataError, 'Missing :rsrc' if rsrc.nil?

      # delete the resource
      @last_http_response =
        @cnx.delete(rsrc) do |req|
          req.headers[HTTP_CONTENT_TYPE_HEADER] = MIME_XML
          req.headers[HTTP_ACCEPT_HEADER] = MIME_XML
        end

      unless @last_http_response.success?
        handle_http_error
        return
      end

      @last_http_response.body
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
    alias host hostname

    # Empty cached lists from this connection
    # then run garbage collection to clear any available memory
    #
    # See the attr_readers for
    # - object_list_cache
    # - ext_attr_definition_cache
    # - singleton_cache
    # - collection_cache
    # - ext_attr_cache
    #
    # NOTE if you've referenced objects in these caches, those objects
    # won't be removed from memory by garbage collection but all cached data
    # will be recached as needed.
    #
    # @param key_or_klass[Symbol, Class] Flush only the caches for the given
    #   RSRC_LIST_KEY. or the EAdef cache for the given extendable class.
    #   If nil (the default), flushes all caches
    #
    # @return [void]
    #
    def flushcache(key_or_klass = nil)
      # EA defs for just one extendable class?
      if EXTENDABLE_CLASSES.include? key_or_klass
        @ext_attr_definition_cache[key_or_klass] = {}

      # one API object class?
      elsif key_or_klass
        map_key_pfx = "#{key_or_klass}_map_"
        @object_list_cache.delete_if do |cache_key, _cache|
          cache_key == key_or_klass || cache_key.to_s.start_with?(map_key_pfx)
        end
        @collection_cache.delete klass
        @singleton_cache.delete klass
        @ext_attr_cache.delete klass

      # flush everything
      else
        @object_list_cache = {}
        @ext_attr_definition_cache = {}
        @collection_cache = {}
        @singleton_cache = {}
        @ext_attr_cache = {}
      end

      GC.start
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
      vars.delete :@ext_attr_definition_cache
      vars
    end

    # Private Insance Methods
    ####################################
    private


    # Parses the @last_http_response
    # and raises a JSS::APIError with a useful error message.
    #
    # @return [void]
    #
    def handle_classic_http_error
      return if @last_http_response.success?

      case @last_http_response.status
      when 404
        err = JSS::NoSuchItemError
        msg = 'Not Found'
      when 409
        err = JSS::ConflictError

        # TODO: Clean this up
        @last_http_response.body =~ /<p>(The server has not .*?)(<|$)/m
        msg = Regexp.last_match(1)

        unless msg
          @last_http_response.body =~ %r{<p>Error: (.*?)</p>}
          msg = Regexp.last_match(1)
        end

        unless msg
          @last_http_response.body =~ /<p>(Unable to complete file upload.*?)(<|$)/m
          msg = Regexp.last_match(1)
        end
      when 400
        err = JSS::BadRequestError
        @last_http_response.body =~ %r{>Bad Request</p>\n<p>(.*?)</p>\n<p>You can get technical detail}m
        msg = Regexp.last_match(1)
      when 401
        err = JSS::AuthorizationError
        msg = 'You are not authorized to do that.'
      when (500..599)
        err = JSS::APIRequestError
        msg = 'There was an internal server error'
      else
        err = JSS::APIRequestError
        msg = "There was a error processing your request, status: #{@last_http_response.status}"
      end
      raise err, msg
    end

  end # class APIConnection

  # JSS MODULE METHODS
  ######################

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
    args[:name] ||= :default
    @api = Connection.new args
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
    use_api_connection @api
  end

  # The currently active JSS::APIConnection instance.
  #
  # @return [JSS::APIConnection]
  #
  def self.api
    @api ||= APIConnection.new name: :default
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
  new_api_connection unless @api

  # Save the default connection in the API constant,
  # mostly for backward compatibility.
  API = @api unless defined? API

end # module
