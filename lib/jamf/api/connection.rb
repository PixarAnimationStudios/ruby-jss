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
#

require 'jamf/api/connection/token'
require 'jamf/api/connection/api_error'

# The module
module Jamf

  # Changes from classic Jamf::APIconnection
  #   - only support https
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

    # The Jamf default SSL port, default for on-prem servers
    ON_PREM_SSL_PORT = 8443

    # The https default SSL port, default for Jamf Cloud servers
    HTTPS_SSL_PORT = 443

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

    # Attributes
    #####################################

    # @return [String, nil]
    attr_reader :host

    # @return [Integer, nil]
    attr_reader :port

    # @return [String, nil]
    attr_reader :user

    # @return [Integer, nil]
    attr_reader :timeout

    # @return [String, nil]
    attr_reader :token

    # @return [String, nil]
    attr_reader :base_url

    # @return [Boolean]
    attr_reader :connected
    alias connected? connected

    # @return [RestClient::Resource] the underlying rest resource
    attr_reader :rest_cnx

    # @return [Hash]
    # This Hash holds the most recent API query for a list of all items in any
    # CollectionResource subclass, keyed by the subclass itself.
    # See the CollectionResource.all class method.
    #
    # When the CollectionResource.all method is called without an argument,
    # and this hash has a matching value, the value is returned, rather than
    # requerying the API. The first time a class calls .all, or whnever refresh
    # is not false, the API is queried and the value in this hash is updated.
    attr_reader :collection_cache

    # @return [Hash]
    # This hash holds Extension Attribute Objects, which are used
    # for validating values passed to Extendable.set_ext_attr.
    attr_reader :ext_attr_cache

    # Constructor
    #####################################

    # @see #connect
    def initialize(**params)
      @name = params.delete :name
      connect(params) if params[:token] || params[:user]
    end

    # Public Instance Methods
    #####################################

    def connect(**params)
      disconnect

      # apply defaults from config, client, and then this class.
      apply_connection_defaults params

      # parse our ssl situation
      verify_ssl params

      if params[:token]
        verify_token(params[:token])
        parse_token params[:token]
      else
        # figure out :password from :pw
        params[:password] = acquire_password(params)

        # confirm we know a host, port, user and pw
        verify_basic_params params
        parse_raw_params params

        # this does the authentication
        @token = self.class::Token.new @user, params[:password], @base_url, timeout: @timeout
      end

      # if we're here we have a valid token
      @rest_cnx = RestClient::Resource.new(
        @base_url.to_s,
        headers: {
          authorization: @token.auth_token,
          accept: :json,
          content_type: :json
        }
      )
      @connected = true

      validate_api_version

      @name = "#{@user}@#{@host}:#{@port}"

      @keep_alive = params[:keep_alive].nil? ? false : params[:keep_alive]
      @keep_alive && start_keep_alive
      to_s
    end # connect

    def disconnect
      # reset everything exceot the name
      @connected = false
      @host = nil
      @port = nil
      @user = nil
      @token = nil
      @timeout = nil
      @base_url = nil
      @rest_cnx = nil
      @collection_cache = {}
      @ext_attr_cache = {}
    end

    def get(rsrc, symbolize: true)
      validate_connected
      response_to_ruby @rest_cnx[rsrc].get, symbolize: symbolize
    rescue RestClient::ExceptionWithResponse => e
      raise Jamf::Connection::APIError.new(e)
    end

    def post(rsrc, data, symbolize: true)
      validate_connected
      response_to_ruby @rest_cnx[rsrc].post(data.to_json), symbolize: symbolize
    rescue RestClient::ExceptionWithResponse => e
      raise Jamf::Connection::APIError.new(e)
    end

    def put(rsrc, data, symbolize: true)
      validate_connected
      response_to_ruby @rest_cnx[rsrc].put(data.to_json), symbolize: symbolize
    rescue RestClient::ExceptionWithResponse => e
      raise Jamf::Connection::APIError.new(e)
    end

    def patch(rsrc, data, symbolize: true)
      validate_connected
      response_to_ruby @rest_cnx[rsrc].patch(data.to_json), symbolize: symbolize
    rescue RestClient::ExceptionWithResponse => e
      raise Jamf::Connection::APIError.new(e)
    end

    def delete(rsrc, symbolize: true)
      validate_connected
      response_to_ruby @rest_cnx[rsrc].delete, symbolize: symbolize
    rescue RestClient::ExceptionWithResponse => e
      raise Jamf::Connection::APIError.new(e)
    end

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      connected? ? "Using #{@base_url} as user #{@user}" : 'not connected'
    end

    def keep_alive?
      !@keep_alive_thread.nil?
    end

    def keep_alive=(bool)
      bool ? start_keep_alive : stop_keep_alive
    end

    def api_version
      get('/')[:version]
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
        @ext_attr_cache.delete klass
      else
        @collection_cache = {}
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
      %i[
        @name
        @connected
        @host
        @port
        @user
        @base_url
        @imeout
        @keep_alive
      ]
    end

    # Private Insance Methods
    ####################################
    private

    # raise exception if not connected
    def validate_connected
      raise Jamf::InvalidConnectionError, 'Not Connected. Use .connect first.' unless connected?
    end

    # raise exception if API version is too low.
    def validate_api_version
      return if Gem::Version.new(api_version) >= MIN_API_VERSION
      raise Jamf::InvalidConnectionError, "API version too low, must be >= #{MIN_API_VERSION}"
    end

    # Apply defaults from the Jamf.config,
    # then from the Jamf::Client,
    # then from the module defaults
    # to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_connection_defaults(params)
      apply_defaults_from_config(params)
      # apply_defaults_from_client(args) TODO: when clients are moved over
      apply_module_defaults(params)
    end

    # Apply defaults from the Jamf.config
    # to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_defaults_from_config(params)
      # settings from config if they aren't in the args
      params[:host] ||= Jamf.config.api_server_name
      params[:port] ||= Jamf.config.api_server_port
      params[:user] ||= Jamf.config.api_username
      params[:timeout] ||= Jamf.config.api_timeout
      params[:open_timeout] ||= Jamf.config.api_timeout_open
      params[:ssl_version] ||= Jamf.config.api_ssl_version

      # if verify cert was not in the args, get it from the prefs.
      # We can't use ||= because the desired value might be 'false'
      params[:verify_cert] = Jamf.config.api_verify_cert if params[:verify_cert].nil?
      params
    end # apply_defaults_from_config

    # Apply defaults from the Jamf::Client
    # to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_defaults_from_client(params)
      return unless Jamf::Client.installed?

      # these settings can come from the jamf binary config, if this machine is a Jamf client.
      params[:host] ||= Jamf::Client.jss_server
      params[:port] ||= Jamf::Client.jss_port.to_i
      params[:use_ssl] ||= Jamf::Client.jss_protocol.to_s.end_with? 's'
    end

    # Apply the module defaults to the args for the #connect method
    #
    # @param args[Hash] The args for #connect
    #
    # @return [Hash] The args with defaults applied
    #
    def apply_module_defaults(params)
      params[:port] ||= params[:host].to_s.end_with?(JAMFCLOUD_DOMAIN) ? JAMFCLOUD_PORT : ON_PREM_SSL_PORT
      params[:timeout] ||= DFT_TIMEOUT
      params[:open_timeout] ||= DFT_OPEN_TIMEOUT
      params[:ssl_version] ||= DFT_SSL_VERSION
    end

    # From whatever was given in args[:pw], figure out the real password
    #
    # @param args[Hash] The args for #connect
    #
    # @return [String] The password for the connection
    #
    def acquire_password(args)
      if args[:pw] == :prompt
        Jamf.prompt_for_password "Enter the password for Jamf user #{args[:user]}@#{args[:host]}:"
      elsif args[:pw].is_a?(Symbol) && args[:pw].to_s.start_with?('stdin')
        args[:pw].to_s =~ /^stdin(\d+)$/
        line = Regexp.last_match(1)
        line ||= 1
        Jamf.stdin line
      else
        args[:pw]
      end
    end

    # Raise execeptions if we don't have essential data for a new connection
    #
    # @param args[Hash] The args for #connect
    #
    # @return [void]
    #
    def verify_basic_params(params)
      params[:host] ||= params[:server]
      # must have server, user, and pw
      raise Jamf::MissingDataError, 'No Jamf :host specified, or in configuration.' unless params[:host]
      raise Jamf::MissingDataError, 'No Jamf :user specified, or in configuration.' unless params[:user]
      raise Jamf::MissingDataError, "Missing :pw for user '#{params[:user]}'" unless params[:pw]
    end

    # Raise execeptions if we were given an unusable token
    #
    # @param args[Hash] The args for #connect
    #
    # @return [void]
    #
    def verify_token(token)
      raise 'Token must be an existing Jamf::Connection::Token object' unless token.is_a? Jamf::Connection::Token
      raise 'Cannot use token: it has expired' if token.expired?
      raise 'Cannot use token: it is invalid' unless token.valid?
      raise "Cannot use token: it expires in less than #{TOKEN_REUSE_MIN_LIFE} seconds" if token.secs_remaining < TOKEN_REUSE_MIN_LIFE
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

    def parse_token(token)
      @host = token.host
      @port = token.port
      @user = token.user
      @base_url = token.base_url
      @token = token
    end

    def parse_raw_params(params)
      @host = params[:host] # || Jamf.config.host
      @port = params[:port] # || Jamf.config.port
      @port ||= @host.end_with?(JAMFCLOUD_DOMAIN) ? JAMFCLOUD_PORT : ON_PREM_SSL_PORT
      @user = params[:user]
      @timeout = params[:timeout]
      @timeout ||= DFT_TIMEOUT
      @base_url = URI.parse "https://#{@host}:#{@port}/#{RSRC_BASE}"
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

    # This is mainly a wrapper to ensure symbolize_names: true
    #
    # @param raw_json[String] the raw json
    #
    # @return [Hash,Array,String,Integer,Boolean,Float] the parsed json
    #
    def response_to_ruby(resp, symbolize: true )
      JSON.parse resp.body, symbolize_names: symbolize
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
  def self.connect(args)
    @active_connection = Connection.new args
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
  connect(name: :default) unless @active_connection

end # module Jamf
