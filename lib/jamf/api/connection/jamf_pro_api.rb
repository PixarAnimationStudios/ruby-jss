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

# The main module
module Jamf

  # The connection class
  class Connection

    # This Module defines methods used for interacting with the Jamf Pro API.
    # This includes creating the Faraday connection, sending HTTP requests and
    # handling responses
    module JamfProAPI

      # create the faraday JPAPI connection object
      #######################################################
      def create_jp_connection(parse_json: true)
        Faraday.new(@jp_base_url, ssl: ssl_options) do |cnx|
          # use a proc for the token value, so its looked up on every request
          # meaning we don't have to validate that the token is still valid before every request
          # because the Token instance will (usually) refresh it automatically.
          cnx.request :authorization, 'Bearer', -> { @token.token }

          cnx.options[:timeout] = @timeout
          cnx.options[:open_timeout] = @open_timeout

          if parse_json
            cnx.request :json
            cnx.response :json, parser_options: { symbolize_names: true }
          end

          cnx.adapter :net_http
        end
      end

      # @param rsrc[String] the resource to get
      #   (the part of the API url after the '/api/' )

      # @return [Hash] the result of the get
      #######################################################
      def jp_get(rsrc)
        validate_connected
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH
        resp = @jp_cnx.get(rsrc) do |req|
          # Modify the request here if needed.
          # puts "JPAPI Cookie is: #{req.headers['Cookie']}"
        end
        @last_http_response = resp

        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end
      # backward compatibility
      alias get jp_get

      # Create a JPAPI resource via POST
      #
      # @param rsrc[String] the resource to POST
      #   (the part of the API url after the '/api/' )
      #
      # @param data[String] the JSON data to POST
      #
      # @return [String] the response body
      #######################################################
      def jp_post(rsrc, data)
        validate_connected
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH
        resp = @jp_cnx.post(rsrc) do |req|
          req.body = data
        end
        @last_http_response = resp
        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end
      # backward compatibility
      alias post jp_post

      # Replace an existing Jamf Pro API resource
      #
      # @param rsrc[String] the API resource being changed, the URL part after 'api/'
      #
      # @param data[String] the json specifying the changes.
      #
      # @return [String] the response from the server.
      #
      #######################################################
      def jp_put(rsrc, data)
        validate_connected
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH
        resp = @jp_cnx.put(rsrc) do |req|
          req.body = data
        end
        @last_http_response = resp
        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end
      # backward compatibility
      alias put jp_put

      # Update an existing Jamf Pro API resource
      #
      # @param rsrc[String] the API resource being changed, the URL part after 'api/'
      #
      # @param data[String] the json specifying the changes.
      #
      # @return [String] the response from the server.
      #
      #######################################################
      def jp_patch(rsrc, data)
        validate_connected
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH
        resp = @jp_cnx.patch(rsrc) do |req|
          # Patch requests must use this content type!
          req.headers['Content-Type'] = 'application/merge-patch+json'
          req.body = data
        end
        @last_http_response = resp
        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end
      # backward compatibility
      alias patch jp_patch

      # Delete an existing Jamf Pro API resource
      #
      # @param rsrc[String] the API resource being deleted, the URL part after 'api/'
      #
      # @return [String] the response from the server.
      #
      #######################################################
      def jp_delete(rsrc)
        validate_connected
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH
        resp = @jp_cnx.delete rsrc
        @last_http_response = resp
        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end
      # backward compatibility
      alias delete jp_delete

      # GET a rsrc without doing any JSON parsing, using
      # a temporary Faraday connection object
      #######################################################
      def jp_download(rsrc)
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH
        temp_cnx = create_jp_connection(parse_json: false)
        resp = temp_cnx.get rsrc
        @last_http_response = resp
        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end

    end # module

  end # class

end # module Jamf
