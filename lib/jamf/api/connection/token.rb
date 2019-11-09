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

# The module
module Jamf

  class Connection

    # A token used for a JSS connection
    class Token

      AUTH_RSRC = 'auth'.freeze

      NEW_TOKEN_RSRC = "#{AUTH_RSRC}/tokens".freeze

      KEEP_ALIVE_RSRC = "#{AUTH_RSRC}/keepAlive".freeze

      INVALIDATE_RSRC = "#{AUTH_RSRC}/invalidateToken".freeze

      # this string is prepended to the token data when used for
      # transaction authorization.
      AUTH_TOKEN_PFX = 'jamf-token '.freeze

      attr_reader :user
      attr_reader :token_data
      attr_reader :expires
      attr_reader :auth_token
      attr_reader :base_url

      def initialize(user, pw, base_url, timeout: Jamf::Connection::DFT_TIMEOUT)
        @user = user
        @base_url = base_url

        resp = token_connection(NEW_TOKEN_RSRC, pw: pw, timeout: timeout).post

        if  resp.success?
          parse_token_from_response resp
        else
          raise Jamf::AuthenticationError, 'Incorrect name or password' if resp.status == 401

          # TODO: better error reporting here
          raise 'An error occurred while authenticating'
        end
      end # init

      def expired?
        Time.now >= @expires
      end

      def secs_remaining
        @expires - Time.now
      end

      def valid?
        return false if expired?
        return false unless @auth_token

        token_connection(AUTH_RSRC, token: @token_data ).get.success?
      end

      # the Jamf::Account object assciated with this token
      def account
        resp = token_connection(AUTH_RSRC, token: @token).get
        return unless resp.success?

        Jamf::APIAccount.new resp.body
      end

      def host
        @base_url.host
      end

      def port
        @base_url.port
      end

      def secs_remaining
        @expires - Time.now
      end

      def keep_alive
        raise 'Token has expired' if expired?
        keep_alive_token_resp = token_connection(KEEP_ALIVE_RSRC, token: @auth_token).post
        # TODO: better error reporting here
        raise 'An error occurred while authenticating' unless keep_alive_token_resp.success?
        parse_token_from_response alive_token_resp
        # parse_token_from_response keep_alive_rsrc.post('')
      end

      def invalidate
        token_connection(INVALIDATE_RSRC, token: @auth_token).post.success?
      end

      # Remove large cached items from
      # the instance_variables used to create
      # pretty-print (pp) output.
      #
      # @return [Array] the desired instance_variables
      #
      def pretty_print_instance_variables
        vars = instance_variables.sort
        vars.delete :@parsed_token
        vars.delete :@token_data
        vars
      end

      # Private instance methods
      #################################
      public

      # a generic, one-time Faraday connection for token
      # acquision & manipulation
      #
      def token_connection(rsrc, token: nil, pw: nil, timeout: Jamf::Connection::DFT_TIMEOUT)
        # con = Faraday.new url: "#{@base_url}/#{rsrc}"
        # con.headers[Jamf::Connection::HTTP_ACCEPT_HEADER] = Jamf::Connection::MIME_JSON
        # con.response :json, parser_options: { symbolize_names: true }
        # con.options[:timeout] = timeout
        # con.options[:open_timeout] = timeout
        # if token
        #   con.token_auth token
        # else
        #   con.basic_auth @user, pw
        # end
        # con

        Faraday.new("#{@base_url}/#{rsrc}") do |con|
          con.headers[Jamf::Connection::HTTP_ACCEPT_HEADER] = Jamf::Connection::MIME_JSON
          con.response :json, parser_options: { symbolize_names: true }
          con.options[:timeout] = timeout
          con.options[:open_timeout] = timeout
          if token
            con.token_auth token
          else
            con.basic_auth @user, pw
          end
          con.use Faraday::Adapter::NetHttp
        end

      end

      def parse_token_from_response(resp)
        @token_response_body = resp.body
        @token_data = @token_response_body[:token]
        @auth_token = AUTH_TOKEN_PFX + @token_data
        @expires = Jamf::Timestamp.new @token_response_body[:expires]
      end

    end # class Token

  end # class Connection

end # module JSS
