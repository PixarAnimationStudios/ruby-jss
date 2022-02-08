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
#
# require 'connection/constants'
# require 'connection/token'
# require 'connection/classic_api'
# require 'connection/jamf_pro_api'
# require 'connection/api_error'
# require 'connection/connect'

#
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

    # This file defines


    # Attributes
    #####################################

    # These come from the token:
    # base_url, host, port, user, keep_alive?, ssl_version, verify_cert?, ssl_options,
    # pw_fallback?, jamf_version, jamf_build

    # @return [Integer] Seconds before an http request times out
    attr_reader :timeout

    # @return [Integer] Seconds before an http connection open times out
    attr_reader :open_timeout

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



    #####  Getters & Setters
    ######################################################

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      @connected ? "Using #{base_url} as user #{@user}" : 'not connected'
    end

    # Reset the response timeout for the rest connection
    #
    # @param timeout[Integer] the new timeout in seconds
    #
    # @return [void]
    #
    def timeout=(new_timeout)
      @timeout = new_timeout.to_i
      @c_cnx.options[:timeout] = @timeout
      @jp_cnx.options[:timeout] = @timeout
    end

    # Reset the open-connection timeout for the rest connection
    #
    # @param timeout[Integer] the new timeout in seconds
    #
    # @return [void]
    #
    def open_timeout=(new_timeout)
      @open_timeout = new_timeout.to_i
      @c_cnx.options[:open_timeout] = @open_timeout
      @jp_cnx.options[:open_timeout] = @open_timeout
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
    alias hostname host

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

    #####  API access
    ######################################################

    # raise exception if not connected
    def validate_connected
      raise JSS::InvalidConnectionError, "Connection '#{@name}' Not Connected. Use .connect first." unless connected?
    end


























    ##########################################################
    ##########################################################
    ############# C API BELOW HERE ##############################





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
