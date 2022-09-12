# Copyright 2022 Pixar

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

require 'base64'

module Jamf

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
      JAMF_TRYITOUT_HOST = "tryitout#{Jamf::Connection::JAMFCLOUD_DOMAIN}".freeze

      JAMF_TRYITOUT_TOKEN_BODY = {
        token: 'This is a fake token, tryitout.jamfcloud.com uses internal tokens',
        expires: 2_000_000_000_000
      }.freeze

      # Minimum seconds before expiration that the token will automatically
      # refresh. Used as the default if :refresh is not provided in the init
      # params
      MIN_REFRESH_BUFFER = 300

      # Used bu the last_refresh_result method
      REFRESH_RESULTS = {
        refreshed: 'Refreshed',
        refreshed_pw: 'Refresh failed, but new token created with cached pw',
        refresh_failed: 'Refresh failed, could not create new token with cached pw',
        refresh_failed_no_pw_fallback: 'Refresh failed, but pw_fallback was false',
        expired_refreshed: 'Expired, but new token created with cached pw',
        expired_failed: 'Expired, could not create new token with cached pw',
        expired_no_pw_fallback: 'Expired, but pw_fallback was false'
      }.freeze

      # @return [String] The user who generated this token
      attr_reader :user

      # @return [String] the SSL version being used
      attr_reader :ssl_version

      # @return [Boolean] are we verifying SSL certs?
      attr_reader :verify_cert
      alias verify_cert? verify_cert

      # @return [Hash] the ssl version and verify cert, to pass into faraday connections
      attr_reader :ssl_options

      # @return [String] The token data
      attr_reader :token
      alias token_string token
      alias auth_token token

      # @return [URI] The base API url, e.g. https://myjamf.jamfcloud.com/
      attr_reader :base_url

      # @return [Time] when was this Jamf::Connection::Token originally created?
      attr_reader :creation_time
      alias login_time creation_time

      # @return [Time] when was this token last refreshed?
      attr_reader :last_refresh

      # @return [Time]
      attr_reader :expires
      alias expiration expires

      # @return [Boolean] does this token automatically refresh itself before
      #   expiring?
      attr_reader :keep_alive
      alias keep_alive? keep_alive

      # @return [Boolean] Should the provided passwd be cached in memory, to be
      #   used to generate a new token, if a normal refresh fails?
      attr_reader :pw_fallback
      alias pw_fallback? pw_fallback

      # @return [Faraday::Response] The response object from instantiating
      #   a new Token object by creating a new token or validating a token 
      #   string. This is not updated when refreshing a token, only when
      #   calling Token.new
      attr_reader :creation_http_response

      # @param params [Hash] The data for creating and maintaining the token
      #
      # @option params [String] :token_string An existing valid token string.
      #   If pw_fallback is true (the default) you will also need to provide
      #   the password for the original user in the pw: parameter. If you don't,
      #   pw_fallback will be false even if you set it to true explicitly.
      #
      # @option params [String, URI] :base_url The url for the Jamf Pro server
      #   including host and port, e.g. 'https://myjss.school.edu:8443/'
      #
      # @option params [String] :user (see Connection#initialize)
      #
      # @option params [String] :pw (see Connection#initialize)
      #
      # @option params [Integer] :timeout The timeout for creating or refreshing
      #   the token
      #
      # @option params [Boolean] :keep_alive (see Connection#connect)
      #
      # @option params [Integer] :refresh_buffer (see Connection#connect)
      #
      # @option params [Boolean] :pw_fallback (see Connection#connect)
      #
      # @option params [String, Symbol] :ssl_version (see Connection#connect)
      #
      # @option params [Boolean] :verify_cert (see Connection#connect)
      #
      ###########################################
      def initialize(**params)
        @valid = false
        parse_params(**params)

        if params[:token_string]
          @pw_fallback = false unless @pw
          init_from_token_string params[:token_string]

        elsif @user && @pw
          init_from_pw

        else
          raise ArgumentError, 'Must provide either user: & pw: or token:'
        end

        start_keep_alive if @keep_alive
        @creation_time = Time.now
      end # init

      # Initialize from password
      #################################
      def init_from_pw
        resp = token_connection(NEW_TOKEN_RSRC).post
        
        if resp.success?
          parse_token_from_response resp
          @last_refresh = Time.now
          @creation_http_response = resp
        elsif resp.status == 401
          raise Jamf::AuthenticationError, 'Incorrect name or password'
        else
          # TODO: better error reporting here
          raise Jamf::AuthenticationError, "An error occurred while authenticating: #{resp.body}"
        end
      ensure
        @pw = nil unless @pw_fallback
      end # init_from_pw

      # Initialize from token string
      #################################
      def init_from_token_string(str)
        resp = token_connection(AUTH_RSRC, token: str).get
        raise Jamf::InvalidDataError, 'Token is not valid' unless resp.success?

        @creation_http_response = resp
        @token = str
        @user = resp.body.dig :account, :username

        # if we were given a pw for the user, and expect to use it, validate it now
        if @pw && @pw_fallback
          resp = token_connection(NEW_TOKEN_RSRC).post
          raise Jamf::AuthenticationError, "Incorrect password provided for token string (user: #{@user})" unless resp.success?
        end

        # use this token to get a fresh one with a known expiration
        refresh
      end # init_from_token_string

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

      # when is the next rerefresh going to happen, if we are set to keep alive?
      #
      # @return [Time, nil] the time of the next scheduled refresh, or nil if not keep_alive?
      def next_refresh
        return unless keep_alive?

        @expires - @refresh_buffer
      end

      # how many secs until the next refresh?
      # will return 0 during the actual refresh process.
      #
      # @return [Float, nil] Seconds until the next scheduled refresh, or nil if not keep_alive?
      #
      def secs_to_refresh
        return unless keep_alive?

        secs = next_refresh - Time.now
        secs.negative? ? 0 : secs
      end

      # Returns e.g. "1 week 6 days 23 hours 49 minutes 56 seconds"
      #
      # @return [String, nil]
      def time_to_refresh
        return unless keep_alive?

        Jamf.humanize_secs secs_to_refresh
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

      # the Jamf::Account object assciated with this token
      #################################
      def account
        return @account if @account

        resp = token_connection(AUTH_RSRC, token: @token).get
        return unless resp.success?

        @account = Jamf::APIAccount.new resp.body
      end

      # Use this token to get a fresh one. If a pw is provided
      # try to use it to get a new token if a proper refresh fails.
      #
      # @param pw [String] Optional password to use if token refresh fails.
      #   Must be the correct passwd or the token's user (obviously)
      #
      # @return [Time] the new expiration time
      #
      #################################
      def refresh
        # already expired?
        if expired?
          # try the passwd if we have it
          return refresh_with_pw(:expired_refreshed, :expired_failed) if @pw

          # no passwd fallback? no chance!
          @last_refresh_result = :expired_no_pw_fallback
          raise Jamf::InvalidTokenError, 'Token has expired'
        end

        # Now try a normal refresh of our non-expired token
        keep_alive_token_resp = token_connection(KEEP_ALIVE_RSRC, token: @token).post

        if keep_alive_token_resp.success?
          parse_token_from_response keep_alive_token_resp
          @last_refresh_result = :refreshed
          @last_refresh = Time.now
          return expires
        end

        # if we're here, the normal refresh failed, so try the pw
        return refresh_with_pw(:refreshed_pw, :refresh_failed) if @pw

        # if we're here, no pw? no chance!
        @last_refresh_result = :refresh_failed_no_pw_fallback
        raise 'An error occurred while refreshing the token'
      end
      alias keep_alive refresh

      # Make this token invalid
      #################################
      def invalidate
        @valid = !token_connection(INVALIDATE_RSRC, token: @token).post.success?
        @pw = nil
        stop_keep_alive
      end
      alias destroy invalidate

      # creates a thread that loops forever, sleeping most of the time, but
      # waking up every 60 seconds to see if the token is expiring in the
      # next @refresh_buffer seconds.
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
                next if secs_remaining > @refresh_buffer

                refresh
              rescue
                # TODO: Some kind of error reporting
                next
              end
            end # loop
          end # thread
      end # start_keep_alive

      # Kills the @keep_alive_thread, if it exists, and sets
      # @keep_alive_thread to nil
      #
      # @return [void]
      #
      def stop_keep_alive
        return unless @keep_alive_thread

        @keep_alive_thread.kill if @keep_alive_thread.alive?
        @keep_alive_thread = nil
      end

      # Private instance methods
      #################################
      private

      # set values from params & defaults
      ###########################################
      def parse_params(**params)
        # This process of deleting suffixes will leave in place any
        # URL paths before the the CAPI_RSRC_BASE or JPAPI_RSRC_BASE
        # e.g.  https://my.jamf.server:8443/some/path/before/api
        # as is the case at some on-prem sites.
        baseurl = params[:base_url].to_s.dup
        baseurl.delete_suffix! '/'
        baseurl.delete_suffix! Jamf::Connection::CAPI_RSRC_BASE
        baseurl.delete_suffix! Jamf::Connection::JPAPI_RSRC_BASE
        baseurl.delete_suffix! '/'
        @base_url = URI.parse baseurl

        @timeout = params[:timeout] || Jamf::Connection::DFT_TIMEOUT

        @user = params[:user]

        # @pw will be deleted after use if pw_fallback is false
        # It is stored as base64 merely for visual security in irb sessions
        # and the like.
        @pw = params[:pw] ? Base64.encode64(params[:pw]) : nil
        @pw_fallback = params[:pw_fallback].instance_of?(FalseClass) ? false : true

        # backwards compatibility
        params[:refresh_buffer] ||= params[:refresh]
        params[:refresh_buffer] = params[:refresh_buffer].to_i
        @refresh_buffer = params[:refresh_buffer] > MIN_REFRESH_BUFFER ? params[:refresh_buffer] : MIN_REFRESH_BUFFER

        @ssl_version = params[:ssl_version] || Jamf::Connection::DFT_SSL_VERSION
        @verify_cert = params[:verify_cert].instance_of?(FalseClass) ? false : true
        @ssl_options = { version: @ssl_version, verify: @verify_cert }

        @keep_alive = params[:keep_alive].instance_of?(FalseClass) ? false : true
      end

      # refresh a token using the pw cached when @pw_fallback is true
      #
      # @param success [Sumbol] the key from REFRESH_RESULTS to use when successful
      # @param failure [Sumbol] the key from REFRESH_RESULTS to use when not successful
      # @return [Time] the new expiration
      #################################
      def refresh_with_pw(success, failure)
        init_from_pw
        @last_refresh_result = success
        expires
      rescue => e
        @last_refresh_result = failure
        raise e, "#{e}. Status: :#{REFRESH_RESULTS[failure]}"
      end

      # @return [void]
      #################################
      def fetch_jamf_version
        resp = token_connection(JAMF_VERSION_RSRC, token: @token).get
        if resp.success?
          jamf_version, @jamf_build = resp.body[:version].split('-')
          @jamf_version = Gem::Version.new jamf_version
          return
        end

        raise Jamf::InvalidConnectionError, 'Unable to read Jamf version from the API'
      end

      # a generic, one-time Faraday connection for token
      # acquision & manipulation
      #################################
      def token_connection(rsrc, token: nil)
        Faraday.new("#{@base_url}/#{Jamf::Connection::JPAPI_RSRC_BASE}/#{rsrc}", ssl: @ssl_options) do |con|
          con.headers[:accept] = Jamf::Connection::MIME_JSON
          con.response :json, parser_options: { symbolize_names: true }
          con.options[:timeout] = @timeout
          con.options[:open_timeout] = @timeout
          if token
            con.authorization :Bearer, token
          else
            con.basic_auth @user, Base64.decode64(@pw)
          end
          con.adapter Faraday::Adapter::NetHttp
        end # Faraday.new
      end # token_connection

      # Parse the API token data into instance vars.
      #################################
      def parse_token_from_response(resp)
        @token_response_body = resp.body
        @token = @token_response_body[:token]
        @expires = Jamf.parse_time(@token_response_body[:expires]).localtime
        @valid = true
      end

    end # class Token

  end # class Connection

end # module Jamf
