# Copyright 2020 Pixar

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

module JSS

  class Connection

    # A token used for a connection to either API
    class Token

      AUTH_RSRC_VERSION = 'v1'.freeze

      AUTH_RSRC = 'auth'.freeze

      NEW_TOKEN_RSRC = "#{AUTH_RSRC_VERSION}/#{AUTH_RSRC}/token".freeze

      KEEP_ALIVE_RSRC = "#{AUTH_RSRC_VERSION}/#{AUTH_RSRC}/keep-alive".freeze

      INVALIDATE_RSRC = "#{AUTH_RSRC_VERSION}/#{AUTH_RSRC}/invalidate-token".freeze

      JAMF_VERSION_RSRC_VERSION = 'v1'.freeze

      JAMF_VERSION_RSRC = "#{JAMF_VERSION_RSRC_VERSION}/jamf-pro-version".freeze

      # Recognize the tryitout server, cuz its /auth endpoint
      # is disabled, and it needs no tokens
      # TODO: MOVE THIS TO THE CONNECTION CLASS
      JAMF_TRYITOUT_HOST = "tryitout#{JSS::Connection::JAMFCLOUD_DOMAIN}".freeze

      JAMF_TRYITOUT_TOKEN_BODY = {
        token: 'This is a fake token, tryitout.jamfcloud.com uses internal tokens',
        expires: 2_000_000_000_000
      }.freeze

      # Minimum seconds before expiration that the token will automatically
      # refresh. Used as the default if :refresh is not provided in the init
      # params
      MIN_REFRESH = 300

      # Used bu the last_refresh_result method
      REFRESH_RESULTS = {
        refreshed: 'Refreshed',
        refreshed_pw: 'Refresh failed, but new token created with cached pw',
        refresh_failed: 'Refresh failed, could not create new token with cached pw',
        refresh_failed_no_pw_fallback: 'Refresh failed, but pw_fallback was false',
        expired_refreshed: 'Expired, but new token created with cached pw',
        expired_failed: 'Expired, could not create new token with cached pw',
        expired_no_pw_fallback: 'Expired, but pw_fallback was false'
      }

      # @return [String] The user who generated this token
      attr_reader :user

      # @return [String] The token data
      attr_reader :token

      # @return [URI] The base API url, e.g. https://myjamf.jamfcloud.com/uapi
      attr_reader :base_url

      # @return [JSS::Timestamp] when was this token originally created?
      attr_reader :login_time

      # @return [JSS::Timestamp] when was this token last refreshed?
      attr_reader :last_refresh

      # @return [JSS::Timestamp]
      attr_reader :expires
      alias expiration expires

      # @param [Hash] params The data for creating and maintaining the token
      #
      # @option params [String] :token_string An existing valid token string.
      #   When pw_fallback is true, (the default) you will also need to provide
      #   the password for the original user in the pw: parameter. If you don't
      #   have the pw for the token user, be sure to set pw_fallback to false.
      #
      # @option params [String] :user (see Connection#initialize)
      #
      # @option params [String] :pw The password for the :user
      #
      # @option params [String, URI] :base_url The url for the Jamf Pro server
      #   including host and port, e.g. 'https://myjss.school.edu:8443/'
      #
      # @option params [Integer] :timeout The timeout for creating or refreshing
      #   the token
      #
      # @option params [Integer] :refresh Refresh the token this many seconds before
      #   it expires. Must be >= MIN_REFRESH
      #
      # @option params [String] :pw_fallback (see Connection#initialize)
      #
      # @option params [String, Symbol] :ssl_version (see Connection#initialize)
      #
      # @option params [Boolean] :verify_cert (see Connection#initialize)
      #
      ###########################################
      def initialize(**params)
        @valid = false
        parse_params(params)

        if @base_url.host == JSS::Connection::JAMF_TRYITOUT_HOST
          init_jamf_tryitout
        elsif @user && params[:pw]
          init_from_pw params[:pw]
        elsif params[:token_string]
          init_from_token_string params[:token_string]
        else
          raise ArgumentError, 'Must provide either user: & pw: or token:'
        end
        @pw = nil unless @pw_fallback
      end # init

      # Initialize from tryitout
      #################################
      def init_jamf_tryitout
        @token_response_body = JAMF_TRYITOUT_TOKEN_BODY
        @token = @token_response_body[:token]
        @expires = JSS::Timestamp.new @token_response_body[:expires]
        @login_time = JSS::Timestamp.new Time.now
        @valid = true
      end # init_from_pw

      # Initialize from password
      #################################
      def init_from_pw
        resp = token_connection(NEW_TOKEN_RSRC).post

        if  resp.success?
          parse_token_from_response resp
        elsif resp.status == 401
          raise JSS::AuthenticationError, 'Incorrect name or password'
        else
          # TODO: better error reporting here
          raise JSS::AuthenticationError, "An error occurred while authenticating: #{resp.body}"
        end
      end # init_from_pw

      # Initialize from token string
      #################################
      def init_from_token_string(str)
        resp = token_connection(AUTH_RSRC, token: str).get
        raise JSS::InvalidDataError, 'Token is not valid' unless resp.success?

        @token = str
        @user = resp.body.dig :account, :username

        # use this token to get a fresh one with a known expiration
        refresh
      end # init_from_token_string

      # @return [String]
      #################################
      def host
        @base_url.host
      end

      # @return [Integer]
      #################################
      def port
        @base_url.port
      end

      # @return [Gem::Version]
      #################################
      def jamf_version
        fetch_jamf_version unless @jamf_version
        @jamf_version
      end

      # @return [String]
      #################################
      def jamf_build
        fetch_jamf_version unless @jamf_build
        @jamf_build
      end

      # @return [Boolean]
      #################################
      def expired?
        return unless @expires

        Time.now >= @expires
      end

      # @return [Float]
      #################################
      def secs_remaining
        return unless @expires

        @expires - Time.now
      end

      # @return [String] e.g. "1 week 6 days 23 hours 49 minutes 56 seconds"
      #################################
      def time_remaining
        return unless @expires

        # TODO: Move this method into JSS from Jamf
        JSS.humanize_secs secs_remaining
      end

      # @return [Boolean]
      #################################
      def valid?
        @valid =
          if expired?
            false
          elsif !@token
            false
          else
            token_connection(AUTH_RSRC, token: @token).get.success?
          end
      end

      # What happened the last time we tried to refresh?
      # See REFRESH_RESULTS
      #
      # @return [String, nil] result or nil if never refreshed
      #################################
      def last_refresh_result
        REFRESH_RESULTS[@last_refresh_result]
      end

      # the JSS::Account object assciated with this token
      #################################
      def account
        return @account if @account

        resp = token_connection(AUTH_RSRC, token: @token).get
        return unless resp.success?

        @account = JSS::APIAccount.new resp.body
      end

      # Use this token to get a fresh one. If a pw is provided
      # try to use it to get a new token if a proper refresh fails.
      #
      # @param pw [String] Optional password to use if token refresh fails.
      #   Must be the correct passwd or the token's user (obviously)
      #
      # @return [JSS::Timestamp] the new expiration time
      #
      #################################
      def refresh
        # gotta have a pw if expired
        if expired?
          # try the passwd
          return refresh_with_passwd(:expired_refreshed, :expired_failed) if @pw

          # no passwd fallback? no chance!
          @last_refresh_result = :expired_no_pw_fallback
          raise JSS::InvalidTokenError, 'Token has expired'
        end

        # Now try a normal refresh of our non-expired token
        keep_alive_token_resp = token_connection(KEEP_ALIVE_RSRC, token: @token).post

        if keep_alive_token_resp.success?
          parse_token_from_response keep_alive_token_resp
          @last_refresh_result = :refreshed
          return expires
        end

        # if we're here, the normal refresh failed, so try the pw
        return refresh_with_passwd(:refreshed_pw, :refresh_failed) if @pw

        # if we're here, no pw? no chance!
        @last_refresh_result = :refresh_failed_no_pw_fallback
        raise 'An error occurred while refreshing the token'
      end
      alias keep_alive refresh

      # Make this token invalid
      #################################
      def invalidate
        @valid = !token_connection(INVALIDATE_RSRC, token: @token).post.success?
      end
      alias destroy invalidate

      # Private instance methods
      #################################
      private

      # set values from params & defaults
      ###########################################
      def parse_params(params)
        params[:base_url] = params[:base_url].to_s
        @base_url =
          if params[:base_url].end_with? JSS::Connection::JPAPI_RSRC_BASE
            URI.parse params[:base_url]
          else
            URI.parse "#{params[:base_url]}/#{JSS::Connection::JPAPI_RSRC_BASE}"
          end
        @timeout = params[:timeout] || JSS::Connection::DFT_TIMEOUT

        # this will be deleted after use if pw_fallback is false
        @pw = params[:pw]
        @user = params[:user]
        @pw_fallback = params[:pw_fallback].instance_of?(FalseClass) ? false : true

        params[:refresh] = params[:refresh].to_i
        @refresh = params[:refresh] > MIN_REFRESH ? params[:refresh] : MIN_REFRESH

        @ssl_version = params[:ssl_version] || JSS::Connection::DFT_SSL_VERSION
        @verify_cert = params[:verify_cert].instance_of?(FalseClass) ? false : true
        @ssl_options = { version: @ssl_version, verify: @verify_cert }
      end

      # refresh a token using a password, return a result
      # @param pw[String] the password to use
      # @return [JamfTimestamp] the new expiration
      #################################
      def refresh_with_passwd(success, failure)
        init_from_pw
        @last_refresh_result = success
        expires
      rescue => e
        @last_refresh_result = failure
        raise e, "#{e}. Status: :#{failure}"
      end

      # @return [void]
      #################################
      def fetch_jamf_version
        resp = token_connection(JAMF_VERSION_RSRC, token: @token).get
        if resp.success?
          jamf_version, @jamf_build = resp.body[:version].split('-')
          @jamf_version = Gem::Version jamf_version
          return
        end

        raise JSS::InvalidConnectionError, 'Unable to read Jamf version from the API'
      end

      # a generic, one-time Faraday connection for token
      # acquision & manipulation
      #################################
      def token_connection(rsrc, token: nil)
        Faraday.new("#{@base_url}/#{rsrc}", ssl: ssl_opts) do |con|
          con.headers[:accept] = JSS::Connection::MIME_JSON
          con.response :json, parser_options: { symbolize_names: true }
          con.options[:timeout] = @timeout
          con.options[:open_timeout] = @timeout
          if token
            con.authorization = :Bearer, token
          else
            con.basic_auth @user, @pw
          end
          con.adapter Faraday::Adapter::NetHttp
        end # Faraday.new
      end # token_connection

      # Parse the API token data into instance vars.
      #################################
      def parse_token_from_response(resp)
        @token_response_body = resp.body
        @token = @token_response_body[:token]
        @expires = JSS::Timestamp.new @token_response_body[:expires]
        @login_time = JSS::Timestamp.new Time.now
        @valid = true
      end

      # creates a thread that loops forever, sleeping most of the time, but
      # waking up every 60 seconds to see if the token is expiring in the
      # next @refresh seconds.
      #
      # If so, the token is refreshed, and we keep looping and sleeping.
      #
      # Sets @keep_alive_thread to the Thread object
      #
      # @return [void]
      #################################
      def start_keep_alive
        return if @keep_alive_thread
        raise 'Token expired, cannot refresh' if expired?

        @keep_alive_thread =
          Thread.new do
            loop do
              sleep 60
              begin
                next if secs_remaining > @refresh

                refresh @pw
              rescue
                # TODO: Some kind of error reporting
                next
              end
            end # loop
          end # thread
      end # start_keep_alive

    end # class Token

  end # class Connection

end # module JSS
