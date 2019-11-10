# Copyright 2018 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.

require 'faraday' # >= 0.17.0
require 'faraday_middleware' # >= 0.13.0

require 'jamf/api/connection/token'
require 'jamf/api/connection/api_error'

# The module
module Jamf

  # Changes from classic Jamf::APIconnection
  #   - uses Faraday as the REST engine
  #   - accepts a url with connect/initialize
  #   - only supports https, no http
  #   - no xml
  #   - tokens & keep_alive
  #   - no object class method wrappers in connection objects,
  #     only passing connection objects into the class methods
  #
  class Connection

    # Class Constants
    #####################################

    # The start of the path for API resources
    RSRC_BASE = 'uapi'.freeze

    # The API version must be this or higher
    MIN_API_VERSION = Gem::Version.new('1.0')

    HTTPS_SCHEME = 'https'.freeze

    # The https default SSL port, default for Jamf Cloud servers
    HTTPS_SSL_PORT = 443

    # The Jamf default SSL port, default for on-prem servers
    ON_PREM_SSL_PORT = 8443

    # if either of these is specified, we'll default to SSL
    SSL_PORTS = [ON_PREM_SSL_PORT, HTTPS_SSL_PORT].freeze

    # Recognize Jamf Cloud servers
    JAMFCLOUD_DOMAIN = '.jamfcloud.com'.freeze

    # JamfCloud connections default to 443, not 8443
    JAMFCLOUD_PORT = HTTPS_SSL_PORT

    # Default open-connection timeout in seconds
    DFT_OPEN_TIMEOUT = 60

    # Default response timeout in seconds
    DFT_TIMEOUT = 60

    # The Default SSL Version
    DFT_SSL_VERSION = 'TLSv1_2'.freeze

    # refresh token if less than this many seconds till
    # expiration,
    TOKEN_REFRESH_THRESHOLD = 60 * 60 * 24

    # pre-existing tokens must have this many seconds before
    # before they expire
    TOKEN_REUSE_MIN_LIFE = 60

    HTTP_ACCEPT_HEADER = 'Accept'
    HTTP_CONTENT_TYPE_HEADER = 'Content-Type'

    MIME_JSON = 'application/json'

    SLASH = '/'.freeze

    VALID_URL_REGEX = /\A#{URI.regexp(%w[https])}\z/.freeze

    NOT_CONNECTED = 'Not Connected'.freeze

    # Only these variables are displayed with PrettyPrint
    # This avoids, especially, the caches, which are available
    # as attr_readers
    PP_VARS = %i[
      @name
      @connected
      @host
      @port
      @user
      @base_url
      @ssl_options
      @open_timeout
      @timeout
      @login_time
      @keep_alive
    ].freeze

    # Attributes
    #####################################

    # @return [String, nil]
    attr_reader :name

    # @return [String, nil]
    attr_reader :host

    # @return [Integer, nil]
    attr_reader :port

    # @return [String, nil]
    attr_reader :user

    # @return [Integer, nil]
    attr_reader :timeout

    # @return [Jamf::Connection::Token, nil]
    attr_reader :token

    # @return [String, nil]
    attr_reader :base_url

    # @return [Boolean]
    attr_reader :connected
    alias connected? connected

    # @return [RestClient::Resource] the underlying rest resource
    attr_reader :rest_cnx

    # when was this connection logged in?
    attr_reader :login_time

    # @return [Hash]
    # This Hash holds the most recently fetched instance of a SingletonResource
    # subclass, keyed by the subclass itself.
    #
    # SingletonResource.fetch will return the instance from here, if it exists,
    # unless the first parameter is truthy.

    attr_reader :singleton_cache

    # @return [Hash]
    # This Hash holds the most recent API data (an Array of Hashes) for the list
    # of all items in a CollectionResource subclass, keyed by the subclass itself.
    #
    # CollectionResource.all return the appropriate data from here, if it exists,
    #
    # See the CollectionResource.all class method.
    attr_reader :collection_cache

    # @return [Hash]
    # This hash holds ExtensionAttribute instances, which are used
    # for validating values passed to Extendable.set_ext_attr.
    attr_reader :ext_attr_cache

    # @return [Faraday::Response] The response object from the last API access.
    attr_reader :last_http_response

    # Constructor
    #####################################

    # @see #connect
    def initialize(url = nil, **params)
      @name = params.delete :name
      @name ||= NOT_CONNECTED
      connect(url, params) unless params[:at_load]
    end

    # Public Instance Methods
    #####################################

    # Connect this Connection object to an Jamf Pro API
    #
    # The first parameter may be a URL (must be https) from which
    # the host & port will be used, and if present, the user and password
    # E.g.
    #   connect 'https://myuser:pass@host.domain.edu:8443'
    #
    # which is the same as:
    #   connect host: 'host.domain.edu', port: 8443, user: 'myuser', pw: 'pass'
    #
    # When using a URL, other parameters below may be specified, however
    # host: and port: parameters will be ignored, since they came from the URL,
    # as will user: and :pw, if they are present in the URL. If the URL doesn't
    # contain user and pw, they can be provided via the parameters, or left
    # to default values.
    #
    # ### Passwords
    # The pw: parameter also accepts the symbols :prompt, and :stdin[X]
    #
    # If :prompt, the user is promted on the commandline to enter the password
    # for the :user.
    #
    # If :stdin the password is read from the first line of stdin
    #
    # If :stdinX (where X is an integer) the password is read from the Xth
    # line of stdin.see {Jamf.stdin}
    #
    # If omitted, and running from an interactive terminal, the user is
    # prompted as with :prompt
    #
    # ### Tokens
    # Instead of a user and password, you may specify a valid 'token:', either:
    #
    # A Jamf::Connection::Token object, which  can be extracted from an active
    # Jamf::Connection via its #token method
    #
    # or
    #
    # A token string e.g. "eyJhdXR...6EKoo" from any source can also be used.
    #
    #
    # Any values available via Jamf.config will be used if they are not provided
    # in the parameters.
    #
    # @param host: [String] The API server hostname. The param 'server:' is a
    #   synonym
    #
    # @param port: [Integer] The API server port. If omitted, the value from
    #   Jamf.config will be used. If no config value, defaults to 443 if the
    #   host ends with 'jamfcloud.com' or 8443 otherwise
    #
    # @param user: [String] The username for the API connection
    #
    # @param pw: [String, Symbol] The password for the user, :prompt, or :stdin[X]
    #
    # @param token: [Jamf::Connection::Token, String] An existing, valid token.
    #   When used, there's no need to provide user: or pw:.
    #
    # @param open_timeout: [Integer] The number of seconds for initial contact
    #   with the host.
    #
    # @param timeout: [Integer] The number of seconds for a full response from
    #   the host.
    #
    # @param ssl_version: [Symbol] The SSL version, e.g. :TLSv1_2
    #
    # @param verify_cert: [Boolean] Should the SSL certificate be verified?
    #   Default is true, should only be set to false if using a on-prem
    #   server with a self-signed certificate, which is rare
    #
    def connect(url = nil, **params)
      # This sets all the instance vars to nil, and flushes/creates the caches
      disconnect

      # parse the url if one was given
      params[:url] = url
      parse_url params if params[:url]

      # apply defaults from config, client, and then this class.
      apply_connection_defaults params

      # confirm we know a host, port, user and pw
      verify_basic_params params
      parse_connect_params params

      @token = acquire_token params
      @login_time = @token.login_time
      @user ||= @token.user

      # if we're here we have a valid token
      @rest_cnx = create_connection

      validate_api_version

      @connected = true

      @keep_alive = params[:keep_alive].nil? ? false : params[:keep_alive]
      @keep_alive && start_keep_alive
      to_s
    end # connect

    def disconnect
      # reset everything exceot the name & timeouts
      @connected = false
      @login_time = nil
      @host = nil
      @port = nil
      @user = nil
      @token = nil
      @base_url = nil
      @rest_cnx = nil
      @ssl_version = nil
      flushcache
    end

    def get(rsrc)
      validate_connected
      resp = @rest_cnx.get rsrc
      @last_http_response = resp
      return resp.body if resp.success?

      raise Jamf::Connection::APIError.new(resp)
    end

    def post(rsrc, data)
      validate_connected
      resp = @rest_cnx.post(rsrc) do |req|
        req.body = data
      end
      @last_http_response = resp
      return resp.body if resp.success?

      raise Jamf::Connection::APIError.new(resp)
    end

    def put(rsrc, data)
      validate_connected
      resp = @rest_cnx.put(rsrc) do |req|
        req.body = data
      end
      @last_http_response = resp
      return resp.body if resp.success?

      raise Jamf::Connection::APIError.new(resp)
    end

    def patch(rsrc, data)
      validate_connected
      resp = @rest_cnx.patch(rsrc) do |req|
        req.body = data
      end
      @last_http_response = resp
      return resp.body if resp.success?

      raise Jamf::Connection::APIError.new(resp)
    end

    def delete(rsrc)
      validate_connected
      resp = @rest_cnx.delete rsrc
      @last_http_response = resp
      return resp.body if resp.success?

      raise Jamf::Connection::APIError.new(resp)
    end

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      "Jamf::Connection: https://#{@user}@#{@host}:#{@port}"
    end

    def keep_alive?
      !@keep_alive_thread.nil?
    end

    def keep_alive=(bool)
      bool ? start_keep_alive : stop_keep_alive
    end

    def api_version
      @token.api_version
    end

    # Flush the collection and/or ea cache for the given class,
    # or all cached data
    # @param klass[Class] the class of cache to flush
    #
    # @return [void]
    #
    def flushcache(klass = nil)
      if klass
        @collection_cache.delete klass
        @singleton_cache.delete klass
        @ext_attr_cache.delete klass
      else
        @collection_cache = {}
        @singleton_cache = {}
        @ext_attr_cache = {}
      end
    end

    # Remove large cached items from
    # the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      PP_VARS
    end

    # Private Insance Methods
    ####################################
    private

    # given a token string or a password, get a valid token
    # Token.new will raise an exception if the token string or
    # credentials are invalid
    def token_from(type, data)
      token_params = {
        user: @user,
        base_url: @base_url,
        timeout: @timeout,
        ssl_options: @ssl_options
      }

      case type
      when :token_string
        token_params[:token_string] = data
      when :pw
        token_params[:pw] = data
      end
      self.class::Token.new token_params
    end

    # raise exception if not connected
    def validate_connected
      raise Jamf::InvalidConnectionError, 'Not Connected. Use .connect first.' unless connected?
    end

    # raise exception if API version is too low.
    def validate_api_version
      vers = api_version
      return if Gem::Version.new(vers) >= MIN_API_VERSION

      raise Jamf::InvalidConnectionError, "API version '#{vers}' too low, must be >= '#{MIN_API_VERSION}'"
    end

    def parse_url(params)
      url = URI.parse params[:url].to_s
      raise ArgumentError, 'Invalid url, scheme must be https' unless url.scheme == HTTPS_SCHEME

      params[:user] = url.user
      params[:pw] = url.password
      params[:host] = url.host
      params[:port] = url.port
    end

    # Apply defaults from the Jamf.config,
    # then from the Jamf::Client,
    # then from the module defaults
    # to the params for the #connect method
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_connection_defaults(params)
      apply_defaults_from_config(params)
      # TODO: when clients are moved over
      # apply_defaults_from_client(params)
      apply_module_defaults(params)

      # if we have a TTY, pw defaults to :prompt
      params[:pw] ||= :prompt if STDIN.tty?
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
      params[:host] ||= Jamf.config.api_server_name
      params[:port] ||= Jamf.config.api_server_port
      params[:user] ||= Jamf.config.api_username
      params[:timeout] ||= Jamf.config.api_timeout
      params[:open_timeout] ||= Jamf.config.api_timeout_open
      params[:ssl_version] ||= Jamf.config.api_ssl_version

      # if verify cert was not in the params, get it from the prefs.
      # We can't use ||= because the desired value might be 'false'
      params[:verify_cert] = Jamf.config.api_verify_cert if params[:verify_cert].nil?
    end # apply_defaults_from_config

    # Apply defaults from the Jamf::Client
    # to the params for the #connect method
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_defaults_from_client(params)
      return unless Jamf::Client.installed?

      # these settings can come from the jamf binary config,
      # if this machine is a Jamf client.
      params[:host] ||= Jamf::Client.jss_server
      params[:port] ||= Jamf::Client.jss_port.to_i
    end

    # Apply the module defaults to the params for the #connect method
    #
    # @param params[Hash] The params for #connect
    #
    # @return [Hash] The params with defaults applied
    #
    def apply_module_defaults(params)
      params[:port] ||= params[:host].to_s.end_with?(JAMFCLOUD_DOMAIN) ? JAMFCLOUD_PORT : ON_PREM_SSL_PORT
      params[:timeout] ||= DFT_TIMEOUT
      params[:open_timeout] ||= DFT_OPEN_TIMEOUT
      params[:ssl_version] ||= DFT_SSL_VERSION
    end

    # From whatever was given in params[:pw], figure out the real password
    #
    # @param params[Hash] The params for #connect
    #
    # @return [String] The password for the connection
    #
    def acquire_password(params)
      if params[:pw] == :prompt
        Jamf.prompt_for_password "Enter the password for Jamf user #{params[:user]}@#{params[:host]}:"
      elsif params[:pw].is_a?(Symbol) && params[:pw].to_s.start_with?('stdin')
        params[:pw].to_s =~ /^stdin(\d+)$/
        line = Regexp.last_match(1)
        line ||= 1
        Jamf.stdin line
      else
        params[:pw]
      end
    end

    # Raise execeptions if we don't have essential data for a new connection
    #
    # @param params[Hash] The params for #connect
    #
    # @return [void]
    #
    def verify_basic_params(params)
      # if given a Token object, it has host, port, user, and base_url
      # and will be verified and parsed
      return if params[:token].is_a? self.class::Token

      # must have a host, accept :server as well as :host
      params[:host] ||= params[:server]
      raise Jamf::MissingDataError, 'No Jamf :host specified, or in configuration.' unless params[:host]

      # no need for user or pass if using a token string
      return if params[:token]

      raise Jamf::MissingDataError, 'No Jamf :user specified, or in configuration.' unless params[:user]
      raise Jamf::MissingDataError, "No :pw specified for user '#{params[:user]}'" unless params[:pw]
    end

    def parse_connect_params(params)
      @host = params[:host]
      @port = params[:port]
      @port ||= @host.end_with?(JAMFCLOUD_DOMAIN) ? JAMFCLOUD_PORT : ON_PREM_SSL_PORT
      @user = params[:user]
      @timeout = params[:timeout] || DFT_TIMEOUT
      @open_timeout = params[:open_timeout] || DFT_TIMEOUT
      @base_url = URI.parse "https://#{@host}:#{@port}/#{RSRC_BASE}"
      # ssl opts for faraday
      # TODO: implement all of faraday's options
      @ssl_options = {
        verify: params[:verify_cert],
        version: params[:ssl_version]
      }
      @name = "#{@user}@#{@host}:#{@port}" if @name == NOT_CONNECTED
    end

    # Get our token either from a passwd or another token or token string
    def acquire_token(params)
      if params[:token]
        if params[:token].is_a? self.class::Token
          verify_token params[:token]
          parse_token params[:token]
          params[:token]
        else
          token_from :token_string, params[:token].to_s
        end
      else
        token_from :pw, acquire_password(params)
      end
    end

    # Raise execeptions if we were given an unusable token
    #
    # @param params[Hash] The params for #connect
    #
    # @return [void]
    #
    def verify_token(token)
      raise 'Cannot use token: it has expired' if token.expired?
      raise 'Cannot use token: it is invalid' unless token.valid?
      raise "Cannot use token: it expires in less than #{TOKEN_REUSE_MIN_LIFE} seconds" if token.secs_remaining < TOKEN_REUSE_MIN_LIFE
    end

    def parse_token(token)
      @host = token.host
      @port = token.port
      @user = token.user
      @base_url = token.base_url
    end

    # create the faraday connection object
    def create_connection
      Faraday.new(@base_url, ssl: @ssl_options) do |cnx|
        cnx.headers[HTTP_ACCEPT_HEADER] = MIME_JSON
        cnx.headers[:authorization] = @token.auth_token
        cnx.request :json
        cnx.response :json, parser_options: { symbolize_names: true }
        cnx.options[:timeout] = @timeout
        cnx.options[:open_timeout] = @open_timeout
        cnx.use Faraday::Adapter::NetHttp
      end
    end

    # creates a thread that loops forever, sleeping until just before
    # the token expires then refreshing the token and sleeping again.
    #
    # Sets @keep_alive_thread to the Thread object
    #
    # @return [void]
    #
    def start_keep_alive
      return if @keep_alive_thread
      raise 'Token expired' if @token.expired?

      @keep_alive_thread =
        Thread.new do
          loop do
            sleep(@token.secs_remaining - TOKEN_REFRESH_THRESHOLD)
            @token.keep_alive
          end # loop
        end # thread
    end

    # Kills the @keep_alive_thread, if it exists, and sets
    # @keep_alive_thread to nil
    #
    # @return [void]
    #
    def stop_keep_alive
      return unless @keep_alive_thread

      @keep_alive_thread.kill
      @keep_alive_thread = nil
    end

  end # class Connection

  # Jamf module methods dealing with the active connection

  # @return [Jamf::Connection] the active connection
  #
  def self.cnx
    @active_connection ||= Connection.new
  end

  # Create a new Connection object and use it as the active_connection,
  # replacing the current active_connection. If connection options are provided,
  # they are passed to the connect method immediately, otherwise
  # Jamf.cnx.connect must be called before attemting to use the
  # connection.
  #
  # @param (See Jamf::Connection#connect)
  #
  # @return [APIConnection] the new, active connection
  #
  def self.connect(**params)
    @active_connection = Connection.new params
  end

  # Switch the connection used for all API interactions to the
  # one provided. See {Jamf::APIConnection} for details and examples
  # of using multiple connections
  #
  # @param connection [APIConnection] The APIConnection to use for future
  #   API calls. If omitted, use the default connection created when ruby-jss
  #   was loaded (which may or may not yet be connected)
  #
  # @return [APIConnection] The connection now being used.
  #
  def self.cnx=(connection)
    raise 'API connections must be instances of Jamf::Connection' unless connection.is_a? Jamf::Connection

    @active_connection = connection
  end

  # create the default connection
  connect(at_load: true) unless @active_connection

end # module Jamf
