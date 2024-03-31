### Copyright 2023 Pixar
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

require 'faraday'
require 'faraday/multipart'

# The main module
module Jamf

  # Instances of this class represent a connection to a Jamf Pro server, using
  # both the Classic and Jamf Pro APIs.
  #
  # For most cases, a single connection to a single JSS is all you need, and
  # ruby-jss automatically creates and uses a default connection. See
  # {Jamf.connect}
  #
  # If needed, multiple connection objects can be made and used sequentially or
  # simultaneously.
  #
  # NOTE: Individual connection instances are not thread-safe and should not be
  # shared by multple simultaneous threads (such as with a multi-threaded http
  # server like 'thin') or used for concurrent API access. In those cases, do not
  # use the default connection, but be sure to design your application to create
  # different API connections for each thread, and pass them into method calls as
  # needed
  #
  # == Using the default connection
  #
  # When ruby-jss is loaded, a not-yet-connected default instance of
  # Jamf::Connection is created and available using {JSS.cnx}.
  #
  # This connection is used as the initial default connection so all methods
  # that make API calls will use it by default.
  # For most uses where you're only going to be working with one connection to
  # one JSS, the default connection is all you need.
  #
  # Before using it you must call its {#connect} method, passing in appropriate
  # connection details and credentials.
  #
  # Example:
  #
  #    require 'ruby-jss'
  #    Jamf.connect host: 'server.address.edu', user: 'jss-api-user', pw: :prompt
  #    # (see {Jamf::Connection#connect} for all the connection options)
  #
  #    a_phone = Jamf::MobileDevice.fetch id: 8743
  #
  #    # the mobile device was fetched through the default connection
  #
  # If needed, you can re-login to the default connection by calling Jamf.connect
  # with new connection parameters. You can also call JSS.disconnect to close the
  # connection
  #
  # == Using standalone Connections
  #
  # Sometimes you need to connect simultaneously to more than one JSS.
  # or to the same JSS with different credentials, or you just need multiple
  # concurrent connections for asyncronous, thread-safe use. ruby-jss allows you
  # to create as many connections as needed, and pass them into the methods that
  # communication with the API via the `cnx:` parameter (the older `api:`
  # parameter is deprecated and will eventually not be recognized)
  #
  #  Example:
  #    my_connection = Jamf::Connection.new(params: go, in: here)
  #    a_computer = Jamf::Computer.fetch id: 1234, cnx: my_connection
  #
  #    # the Jamf::Computer with id 1234 is fetched from the connection
  #    # stored in the variable 'my_connection'. The computer is
  #    # then stored in the variable 'a_computer'
  #
  # NOTE:
  # When an obbject is retrieved or created it stores an internal
  # reference to the Connection object that it was made with, and uses that when making
  # future API calls.
  #
  # So in the example above, when saving any changes to a_computer, the Connection
  # object 'my_connection' will (and must) be used.
  #
  # Similiarly, each Connection object maintains its own caches for the data
  # used by the `list` methods (e.g. Jamf::Computer.all, .all_names, and so on)
  #
  # == Making new APIConnection instances
  #
  # New connections can be created using the standard ruby 'new' method.
  #
  # If you provide connection details when calling 'new', they will be passed
  # to the {#connect} method immediately. Otherwise you can call {#connect} later.
  #
  #   production_server = Jamf::Connection.new(
  #     'https://produser@prodserver.address.org:8443/'
  #     name: 'prod',
  #     pw: :prompt
  #   )
  #
  #   # the new connection is now stored in the variable 'production_api'.
  #
  # == Passing an APIConnection object to API-related methods
  #
  # All methods that use the API can take an 'cnx:' parameter which
  # takes a Connection object. When provided, that connection is
  # used rather than the active connection. The older, deprecated synonym 'api:'
  # will eventually be removed.
  #
  # For example:
  #
  #   prod2_computer_sns = Jamf::Computer.all_serial_numbers, cnx: production_api2
  #
  #   # the list of all computer serial numbers is read from the connection in
  #   # the variable 'production_api2' and stored in 'prod2_computer_sns'
  #
  #   prod2_victim_md = Jamf::MobileDevice.fetch id: 832, cnx: production_api2
  #
  #   # the variable 'prod2_victim_md' now contains a Jamf::MobileDevice queried
  #   # through the connection 'production_api2'.
  #
  # == Low-level use of Connection instances.
  #
  # For most cases, using Connection instances as mentioned above
  # is all you'll need. However to access API resources that aren't yet
  # implemented in other parts of ruby-jss, you can use the methods
  # {#c_get}, {#c_put}, {#c_post}, {#c_delete} for accessing the Classic API
  # and {#jp_get}, {#jp_post}, {#jp_put}, {#jp_patch}, {#jp_delete} for
  # accessing the Jamf Pro API
  #
  # For even lower-level work, you can access the underlying Faraday::Connection
  # objects via the connection's {#c_cnx} and {#jp_cnx}
  # attributes.
  #
  #
  class Connection

    # the code for this class is broken into multiple files
    # as modules, to play will with the zeitwerk loader
    include Jamf::Connection::Constants
    include Jamf::Connection::Attributes
    include Jamf::Connection::Cache
    include Jamf::Connection::Connect
    include Jamf::Connection::ClassicAPI
    include Jamf::Connection::JamfProAPI

    # Constructor
    #####################################

    # Instantiate a connection object.
    #
    # If name: is provided it will be stored as the Connection's name attribute.
    #
    # if no url is provided and params are empty, or contains only
    # a :name key, then you must call #connect with all the connection
    # parameters before accessing a server.
    #
    # See {#connect} for the parameters
    #
    def initialize(url = nil, **params)
      @name = params.delete :name
      @connected = false

      # initialize the data caches
      # see cache.rb
      @c_object_list_cache = {}
      @c_ext_attr_definition_cache = {}
      # @jp_singleton_cache = {}
      # @jp_collection_cache = {}
      # @jp_ext_attr_cache = {}

      return if url.nil? && params.empty?

      connect url, **params
    end # init

    # Instance methods
    #####################################

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      return 'not connected' unless connected?

      if name.to_s.start_with? "#{user}@"
        name
      else
        "#{user}@#{host}:#{port}, name: #{name}"
      end
    end

    # Only selected items are displayed with prettyprint
    # otherwise its too much data in irb.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      PP_VARS
    end

    # @deprecated, use .token.next_refresh
    def next_refresh
      @token.next_refresh
    end

    # @deprecated, use .token.secs_to_refresh
    def secs_to_refresh
      @token.secs_to_refresh
    end

    # @deprecated, use .token.time_to_refresh
    def time_to_refresh
      @token.time_to_refresh
    end

  end # class Connection

end # module
