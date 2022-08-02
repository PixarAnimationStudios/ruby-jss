### Copyright 2022 Pixar
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

    # This module defines general attributes of a connection object
    #
    # These attributes actually come from the token:
    #   base_url, host, port, user, keep_alive?, ssl_version, verify_cert?,
    #   ssl_options, pw_fallback?, jamf_version, jamf_build
    # There are convience getters defined for them below
    #############################################################

    module Attributes

      # @return [String,Symbol] an arbitrary name that can be given to this
      #   connection during initialization, using the name: parameter.
      #   defaults to user@hostname:port
      attr_reader :name

      # @return [Boolean] are we connected right now?
      attr_reader :connected
      alias connected? connected

      # @return [Integer] Seconds before an http request times out
      attr_reader :timeout

      # @return [Integer] Seconds before an http connection open times out
      attr_reader :open_timeout

      # @return [Faraday::Connection] the underlying C-API connection object
      attr_reader :c_cnx

      # @return [Faraday::Connection] the underlying JPAPI connection object
      attr_reader :jp_cnx

      # @return [Jamf::Connection::Token] the token used for connecting
      attr_reader :token

      # @return [String] any path in the URL below the hostname. See {#connect}
      attr_reader :server_path

      # @return [Faraday::Response] The response from the most recent API call
      attr_reader :last_http_response

      # @return [Time] when this connection was connected
      attr_reader :connect_time
      alias login_time connect_time

      # @return [Boolean] are we using a sticky session?
      attr_reader :sticky_session
      alias sticky_session? sticky_session
      alias sticky? sticky_session
      
      # @return [String, nil] The current sticky_session cookie. nil unless
      #   sticky_session is set to true, either as a param to 'connect' or via
      #   #sticky_session=
      #
      #   When set via .connect, the cookie is gleaned from the token creation 
      #   reponse. When set via #sticky_session=, a HEAD request is made, and the
      #   cookie will be in the response.
      #   
      #    Only valid when the connection is to a Jamf Cloud server.
      attr_reader :sticky_session_cookie

      ##########################################

      # Turn sticky-sessions on or off. If turning on, host must be a Jamf Cloud
      # server, with a hostname ending with Jamf::Connection::JAMFCLOUD_DOMAIN
      #
      # @param value [Boolean] should we use a sticky session?
      #
      # @return [void]
      #
      def sticky_session=(value)
        if value
          raise Jamf::UnsupportedError, 'Sticky Sessions may only be used with Jamf Cloud servers.' unless host.end_with? Jamf::Connection::JAMFCLOUD_DOMAIN

          @sticky_session = true
          enable_sticky_session Jamf.cnx.jp_cnx.head.headers

        else
          @sticky_session = false
          @sticky_session_cookie = nil
          @c_cnx&.headers&.delete Jamf::Connection::COOKIE_HEADER
          @jp_cnx&.headers&.delete Jamf::Connection::COOKIE_HEADER
        end
      end

      # Reset the response timeout for the rest connection
      #
      # @param timeout[Integer] the new timeout in seconds
      #
      # @return [void]
      #
      def timeout=(new_timeout)
        @timeout = new_timeout.to_i
        @c_cnx&.options[:timeout] = @timeout 
        @jp_cnx&.options[:timeout] = @timeout 
      end

      # Reset the open-connection timeout for the rest connection
      #
      # @param timeout[Integer] the new timeout in seconds
      #
      # @return [void]
      #
      def open_timeout=(new_timeout)
        @open_timeout = new_timeout.to_i
        @c_cnx&.options[:open_timeout] = @open_timeout
        @jp_cnx&.options[:open_timeout] = @open_timeout 
      end

      # @return [URI::HTTPS] the base URL to the server
      def base_url
        validate_token
        @token.base_url
      end

      # @return [String] the hostname of the Jamf Pro server API connection
      def host
        validate_token
        @token.host
      end
      alias server host
      alias hostname host

      # @return [Integer] The port of the Jamf Pro server API connection
      def port
        validate_token
        @token.port
      end

      # @return [String] the username who's connected to the JSS API
      def user
        validate_token
        @token.user
      end

      # @return [Boolean] Is the connection token being automatically refreshed?
      def keep_alive?
        validate_token
        @token.keep_alive?
      end

      # @return [Boolean] If keep_alive is true, is the password Cached in memory
      #   to use if the refresh fails?
      def pw_fallback?
        validate_token
        @token.pw_fallback?
      end

      # @return [String] SSL version used for the connection
      def ssl_version
        validate_token
        @token.ssl_version
      end

      # @return [Boolean] Should the SSL certifcate from the server be verified?
      def verify_cert?
        validate_token
        @token.verify_cert?
      end
      alias verify_cert verify_cert?

      # @return [Hash] the ssl version and verify cert, to pass into faraday connections
      def ssl_options
        validate_token
        @token.ssl_options
      end

      # @return [Gem::Version] the version of the Jamf Pro server
      def jamf_version
        validate_token
        @token.jamf_version
      end

      # @return [String] the build of the Jamf Pro server
      def jamf_build
        validate_token
        @token.jamf_build
      end

      # raise an error if no token yet
      # @return [void]
      def validate_token
        raise Jamf::InvalidConnectionError, 'No token available, use #connect first' unless @token
      end

    end # module

  end # class Connection

end # module
