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

# THe main module
module JSS

  # The connection class
  class Connection

    # This file defines constants and methods used for processing the connection
    # parameters, acquiring passwords and tokens, and creating the connection
    # objects to the Classic and Jamf Pro APIs

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
    # @return [String] connection description, the output of #to_s
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

      @timeout = params[:timeout]
      @open_timeout = params[:open_timeout]

      @login_time = Time.now
      @name ||= "#{user}@#{host}:#{port}"

      @c_base_url = base_url + CAPI_RSRC_BASE
      @jp_base_url = base_url + JPAPI_RSRC_BASE

      # the faraday connection objects
      @c_cnx = create_classic_connection
      @jp_cnx = create_jp_connection

      @connected = true

      to_s
    end # connect

    # With a REST connection, there isn't any real "connection" to disconnect from
    # So to disconnect, we just unset all our credentials.
    #
    # @return [void]
    #
    def disconnect
      flushcache
      @token&.stop_keep_alive

      @login_time = nil
      @jp_cnx = nil
      @c_cnx = nil
      @c_base_url = nil
      @jp_base_url = nil
      @server_path = nil
      @token = nil
      @connected = false
      :disconnected
    end # disconnect

    # Same as disconnect, but invalidates the token on the server first
    def logout
      @token&.invalidate
      disconnect
    end

    #####  Parsing Params & creating connections
    ######################################################
    private

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
      return if token.secs_remaining >=  TOKEN_REUSE_MIN_LIFE

      raise JSS::InvalidConnectionError, "Cannot use token: it expires in less than #{TOKEN_REUSE_MIN_LIFE} seconds"
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
      raise Jamf::MissingDataError, 'No Jamf :host specified in params or configuration.' unless params[:host]

      # no need for user or pass if using a token string
      # (tho a pw might be given)
      return if params[:token].is_a? String

      # must have user and pw
      raise Jamf::MissingDataError, 'No Jamf :user specified in params or configuration.' unless params[:user]
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
      # if we parsed a URL directly from connect' first parameter, then use that.
      return params[:given_url] if params[:given_url]

      # trim any potential leading & trailing slash on server_path,
      # ensure a trailing slash below
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

  end # class

end # module JSS
