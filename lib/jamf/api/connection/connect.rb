### Copyright 2025 Pixar
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

module Jamf

  class Connection

    # This module defines constants and methods used for processing the connection
    # parameters, acquiring passwords and tokens, and creating the connection
    # objects to the Classic and Jamf Pro APIs. It also defines the disconnection
    # methods
    #############################################
    module Connect

      # Connect to the both the Classic and Jamf Pro APIs
      #
      # IMPORTANT: http (non-SSL, unencrypted) connections are not allowed.
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
      #
      # The pw: parameter also accepts the symbols :prompt, and :stdin[X]
      #
      # If :prompt, the user is promted on the commandline to enter the password
      # for the :user.
      #
      # If :stdin, the password is read from the first line of stdin
      #
      # If :stdinX, (where X is an integer) the password is read from the Xth
      # line of stdin.see {Jamf.stdin}
      #
      # If omitted, and running from an interactive terminal, the user is
      # prompted as with :prompt
      #
      # ### Tokens
      # Instead of a user and password, you may specify a valid 'token:', which is
      # either:
      #
      # A Jamf::Connection::Token object, which can be extracted from an active
      # Jamf::Connection via its #token method
      #
      # or
      #
      # A valid token string e.g. "eyJhdXR...6EKoo" from any source can also be used.
      #
      # When using an existing token or token string, the username used to create
      # the token will be read from the server. However, if you don't also provide
      # the users password using the pw: parameter, then the pw_fallback option
      # will always be false.
      #
      # ### Default values
      #
      # Any values available via JSS.config will be used if they are not provided
      # in the parameters. See {Jamf::Configuration}. If there are no config values
      # then a built-in default is used if available.
      #
      # ### API Clients
      #
      # As of Jamf Pro 10.49, API connections can be made using "API Clients" which are
      # assigned to various "API Roles", as well  as regular Jamf Pro accounts.
      #
      # Connections made with API Client credentials are different from regular connections:
      #   - Their expiration period can vary based on the Client definition
      #   - The expirations are usually quite short, less than the default 30 min. session timeout
      #   - They cannot be kept alive, they will become invalid when the expiration time arrives.
      #   - The API endpoints and data exchange used for making API Client connections are
      #     different from those used by normal connections.
      #
      # To make a connection using an API Client, pass in the client_id: and client_secret: instead
      # of user: and pw:
      #
      #####################
      #
      # @param url[String] The URL to use for the connection. Must be 'https'.
      #   The host, port, and (if provided), user and spassword will be extracted.
      #   Any of those params explicitly provided will be ignored if present in
      #   the url
      #
      # @param params[Hash] the keyed parameters for connection.
      #
      # @option params :host[String] the hostname of the JSS API server, required
      #   if not defined in JSS.config
      #
      # @option params :server_path[String] If your JSS is not at the root of the
      #   server, e.g. if it's at
      #     https://myjss.myserver.edu:8443/dev_mgmt/jssweb
      #   rather than
      #     https://myjss.myserver.edu:8443/
      #   then use this parameter to specify the path below the root e.g:
      #     server_path: 'dev_mgmt/jssweb'
      #
      # @option params :user[String] a JSS user who has API privs, required if not
      #   defined in Jamf::CONFIG.
      #   NOTE: To use an API Client (Jamf pro 10.49 and up),
      #   provide client_id: instead of user:
      #
      # @option params :client_id[String] The Client ID of an "API Client"
      #   available in Jamf Pro 10.49 and up. Use this instead of user:
      #
      # @option params :client_secret[String] The Client Secret of an "API Client"
      #   available in Jamf Pro 10.49 and up. Use this instead of pw:
      #
      # @option params :pw[String, Symbol] The user's password, :prompt, or :stdin
      #   If :prompt, the user is promted on the commandline to enter the password
      #   If :stdin#, the password is read from a line of std in represented by
      #   the digit at #, so :stdin3 reads the passwd from the third line of
      #   standard input. Defaults to line 1, if no digit is supplied. see {JSS.stdin}
      #   NOTE: To use an API Client (Jamf pro 10.49 and up),
      #   provide client_secret: instead of pw:
      #
      # @option params :port[Integer] the port number to connect with, defaults
      #   to 443 for Jamf Cloud hosts, 8443 for on-prem hosts
      #
      # @option params :ssl_version[String, Symbol] The SSL version to use. Default
      #   is TLSv1_2
      #
      # @option params :verify_cert[Boolean] should SSL certificates be verified.
      #   Defaults to true.
      #
      # @option params :open_timeout[Integer] the number of seconds to wait for an
      #   initial response, defaults to 60
      #
      # @option params :timeout[Integer] the number of seconds before an API call
      #   times out, defaults to 60
      #
      # @option params :keep_alive[Boolean] Should the token for the connection
      #  for be automatically refreshed before it expires? Default is true
      #
      # @option params :token_refresh_buffer[Integer] If keep_alive, refresh the
      #   token this many seconds before it expires.
      #   Must be >= Jamf::Connection::Token::MIN_REFRESH_BUFFER, which is the default
      #
      # @option params :pw_fallback [Boolean] If keep_alive, should the passwd be
      #   cached in memory and used to create a new token, if there are problems
      #   with the normal token refresh process?
      #
      # @option params :sticky_session [Boolean] Use a 'sticky session'? Default is false.
      #   The hostname of Jamf Cloud urls does not point to a single https server,
      #   but any node of a cluster. Those nodes often take time to see changes
      #   made in other node. Sometimes, its important to perform a series of API
      #   actions to the same node, to avoid sync-timing problems between node. Setting
      #   sticky_session to true will cause all communication for this Connection to go
      #   through the one specific node it first connected ith.
      #   This is only relevant to Jamf Cloud connections, and will raise an exception
      #   is used with on-prem Jamf Pro servers.
      #   NOTE: It is not always appropriate to use this feature, and inapproriate use
      #   may negatively impact server performance. For more info, see
      #   https://developer.jamf.com/developer-guide/docs/sticky-sessions-for-jamf-cloud
      #
      # @return [String] connection description, the output of #to_s
      #
      #######################################################
      def connect(url = nil, **params)
        raise ArgumentError, 'No url or connection parameters provided' if url.nil? && params.empty?

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

        # it there's no @token yet, get one from a token string or a password
        create_token_if_needed(params)

        # We have to have a usable connection to do this, so it has to come after
        # all the stuff above
        verify_server_version

        @timeout = params[:timeout]
        @open_timeout = params[:open_timeout]

        @connect_time = Time.now
        @name ||= "#{user}@#{host}:#{port}"

        @c_base_url = base_url + Jamf::Connection::CAPI_RSRC_BASE
        @jp_base_url = base_url + Jamf::Connection::JPAPI_RSRC_BASE

        # the faraday connection objects
        @c_cnx = create_classic_connection
        @jp_cnx = create_jp_connection

        # set the connection objects to sticky if desired. enforce booleans
        self.sticky_session = params[:sticky_session] ? true : false

        @connected = true

        to_s
      end # connect
      alias login connect

      # If a sticky_session was requested when the connection was made, and
      # we are connected to a jamf cloud server, the token's http response
      # contains the cookie we need to send with every request to ensure a
      # stickey session.
      #################################
      def enable_sticky_session(headers)
        # commas separate the cookies
        raw_cookies = headers[Jamf::Connection::SET_COOKIE_HEADER].split(/\s*,\s*/)

        raw_cookies.each do |rc|
          # semicolons separate the attributes of the cookie,
          # with its name and value being the first pair.
          cookie_data = rc.split(/\s*;\s*/).first

          # attribute name and value are separated by '='
          cookie_name, cookie_value = cookie_data.split('=')
          next unless cookie_name == Jamf::Connection::STICKY_SESSION_COOKIE_NAME

          @sticky_session_cookie = "#{Jamf::Connection::STICKY_SESSION_COOKIE_NAME}=#{cookie_value}"
          jp_cnx.headers[Jamf::Connection::COOKIE_HEADER] = @sticky_session_cookie
          c_cnx.headers[Jamf::Connection::COOKIE_HEADER] = @sticky_session_cookie
          return @sticky_session_cookie
        end
        # be sure to return nil if there was no appropriate cookie,
        # which means we aren't using Jamf Cloud

        nil
      end

      # raise exception if not connected, and make sure we're using
      # the current token
      def validate_connected
        using_dft = 'Jamf.cnx' if self == Jamf.cnx
        raise Jamf::InvalidConnectionError, "Connection '#{@name}' Not Connected. Use #{using_dft}.connect first." unless connected?
      end

      # With a REST connection, there isn't any real "connection" to disconnect from
      # So to disconnect, we just unset all our credentials.
      #
      # @return [void]
      #
      #######################################################
      def disconnect
        flushcache
        @token&.stop_keep_alive

        @connect_time = nil
        @jp_cnx = nil
        @c_cnx = nil
        @c_base_url = nil
        @jp_base_url = nil
        @server_path = nil
        @token = nil
        @sticky_session_cookie = nil
        @sticky_session = nil
        @connected = false
        :disconnected
      end # disconnect

      # Same as disconnect, but invalidates the token on the server first
      #######################################################
      def logout
        @token&.invalidate
        disconnect
      end

      #####  Parsing Params & creating connections
      ######################################################
      private

      # Get host, port, & user from a Token object
      #######################################################
      def parse_token(params)
        return unless params[:token].is_a? Jamf::Connection::Token

        verify_token params[:token]
        @token = params[:token]
      end

      # Raise execeptions if we were given an unusable token object
      #
      # @param params[Hash] The params for #connect
      #
      # @return [void]
      #
      #######################################################
      def verify_token(token)
        raise Jamf::InvalidConnectionError, 'Cannot use token: it has expired' if token.expired?
        raise Jamf::InvalidConnectionError, 'Cannot use token: it is invalid' unless token.valid?
        return if token.secs_remaining >= Jamf::Connection::TOKEN_REUSE_MIN_LIFE

        raise Jamf::InvalidConnectionError, "Cannot use token: it expires in less than #{Jamf::Connection::TOKEN_REUSE_MIN_LIFE} seconds"
      end

      # Get host, port, user and pw from a URL, overriding any already in the params
      #
      # @return [String, nil] the pw if present
      #
      #######################################################
      def parse_url(url, params)
        return unless url

        url = URI.parse url.to_s
        raise ArgumentError, 'Invalid url, scheme must be https' unless url.scheme == Jamf::Connection::HTTPS_SCHEME

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
      #######################################################
      def apply_default_params(params)
        # must have a host, but accept legacy :server as well as :host
        params[:host] ||= params[:server]

        # if we have no port set by this point, set to cloud port
        # if host is a cloud host. But leave port nil for other hosts
        # (will be set via client defaults or module defaults)
        params[:port] ||= Jamf::Connection::JAMFCLOUD_PORT if params[:host].to_s.end_with?(Jamf::Connection::JAMFCLOUD_DOMAIN)

        # if we're using an API client, the id and secret are synonyms of the user and pw
        params[:user] ||= params[:client_id]
        params[:pw] ||= params[:client_secret]

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
      #######################################################
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
      #######################################################
      def apply_defaults_from_client(params)
        return unless Jamf::Client.installed?

        # these settings can come from the jamf binary config,
        # if this machine is a Jamf client.
        params[:host] ||= Jamf::Client.jss_server
        params[:port] ||= Jamf::Client.jss_port.to_i
      rescue
        nil
      end

      # Apply the module defaults to the params for the #connect method
      #
      # @param params[Hash] The params for #connect
      #
      # @return [Hash] The params with defaults applied
      #
      #######################################################
      def apply_module_defaults(params)
        # if we have no port set by this point, assume on-prem.
        params[:port] ||= Jamf::Connection::ON_PREM_SSL_PORT
        params[:timeout] ||= Jamf::Connection::DFT_TIMEOUT
        params[:open_timeout] ||= Jamf::Connection::DFT_OPEN_TIMEOUT
        params[:ssl_version] ||= Jamf::Connection::DFT_SSL_VERSION
        params[:token_refresh_buffer] ||= Jamf::Connection::Token::MIN_REFRESH_BUFFER
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
      #######################################################
      def verify_basic_params(params)
        # if given a Token object, it has host, port, user, and base_url
        # and is already parsed
        return if @token

        # must have a host, it could have come from a url, or a param
        raise Jamf::MissingDataError, 'No Jamf :host specified in params or configuration.' unless params[:host]

        # no need for user or pass if using a token string
        # (tho a pw might be given)
        return if params[:token].is_a? String

        # must have user and pw
        raise Jamf::MissingDataError, 'No Jamf :user specified in params or configuration.' unless params[:user]
        raise Jamf::MissingDataError, "No :pw specified for user '#{params[:user]}'" unless params[:pw]
      end

      # it there's no @token yet, get one from a token string or a password
      #######################################################
      def create_token_if_needed(params)
        return if @token

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

      # given a token string or a password, get a valid token
      # Token.new will raise an exception if the token string or
      # credentials are invalid
      #######################################################
      def token_from(type, params)
        token_params = {
          base_url: build_base_url(params),
          user: params[:user],
          client_id: params[:client_id],
          client_secret: params[:client_secret],
          timeout: params[:timeout],
          keep_alive: params[:keep_alive],
          refresh_buffer: params[:token_refresh_buffer],
          pw_fallback: params[:pw_fallback],
          ssl_version: params[:ssl_version],
          verify_cert: params[:verify_cert]
        }
        token_params[:token_string] = params[:token] if type == :token_string
        token_params[:pw] = params[:pw] unless params[:pw].is_a? Symbol

        self.class::Token.new(**token_params)
      end

      # Build the base URL for the API connection
      #
      # @param args[Hash] The args for #connect
      #
      # @return [String] The URI encoded URL
      #
      #######################################################
      def build_base_url(params)
        # if we parsed a URL directly from connect' first parameter, then use that.
        return params[:given_url] if params[:given_url]

        # trim any potential leading & trailing slash on server_path,
        # ensure a trailing slash below
        server_path = params[:server_path].to_s.delete_prefix '/'
        server_path.delete_suffix! '/'

        # and here's the URL
        "#{Jamf::Connection::HTTPS_SCHEME}://#{params[:host]}:#{params[:port]}/#{server_path}/"
      end

      # From whatever was given in args[:pw], figure out the real password
      #
      # @param args[Hash] The args for #connect
      #
      # @return [String] The password for the connection
      #
      #######################################################
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
      #######################################################
      def verify_server_version
        return if jamf_version >= Jamf::Connection::MIN_JAMF_VERSION

        raise(
          Jamf::InvalidConnectionError,
          "This version of ruby-jss requires Jamf server version #{Jamf::Connection::MIN_JAMF_VERSION} or higher. #{host} is running #{jamf_version}"
        )
      end

    end # module

  end # class

end # module Jamf
