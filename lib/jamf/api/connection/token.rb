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

      def initialize(user, pw, base_url, timeout: Jamf::Conection::DFT_TIMEOUT)
        @user = user
        @base_url = base_url
        parse_new_token_response new_token_rsrc(pw, timeout).post('')
      end # init

      def expired?
        Time.now >= @expires
      end

      def valid?
        auth_rsrc.get
        true
      rescue RestClient::Unauthorized
        false
      end

      # the Jamf::Account object assciated with this token
      def account
        cooked_json = JSON.parse auth_rsrc.get.body, symbolize_names: true
        Jamf::APIAccount.new cooked_json
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
        parse_new_token_response keep_alive_rsrc.post('')
      end

      def invalidate
        return unless valid?
        invalidate_rsrc.post ''
        @valid = false
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

      private

      def new_token_rsrc(pw, timeout)
        RestClient::Resource.new(
          "#{@base_url}/#{NEW_TOKEN_RSRC}",
          user: @user,
          password: pw,
          accept: :json,
          content_type: :json,
          timeout: timeout
        )
      end

      def auth_rsrc
        RestClient::Resource.new(
          "#{@base_url}/#{AUTH_RSRC}",
          accept: :json,
          content_type: :json,
          headers: { authorization: @auth_token }
        )
      end

      def keep_alive_rsrc
        RestClient::Resource.new(
          "#{@base_url}/#{KEEP_ALIVE_RSRC}",
          accept: :json,
          content_type: :json,
          headers: { authorization: @auth_token }
        )
      end

      def invalidate_rsrc
        RestClient::Resource.new(
          "#{@base_url}/#{INVALIDATE_RSRC}",
          accept: :json,
          content_type: :json,
          headers: { authorization: @auth_token }
        )
      end

      def parse_new_token_response(resp)
        @parsed_token = JSON.parse resp.body, symbolize_names: true
        @token_data = @parsed_token[:token]
        @auth_token = AUTH_TOKEN_PFX + @token_data
        @expires = Time.strptime @parsed_token[:expires].to_s[0..-4], '%s'
        @valid = true
      end

    end # class Token

  end # class Connection

end # module JSS
