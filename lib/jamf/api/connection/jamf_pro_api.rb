# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
      def create_jp_connection(parse_json: true, upload: false)
        Faraday.new(@jp_base_url, ssl: ssl_options) do |cnx|
          # use a proc for the token value, so its looked up on every request
          # meaning we don't have to validate that the token is still valid before every request
          # because the Token instance will (usually) refresh it automatically.
          cnx.request :authorization, 'Bearer', -> { @token.token }

          cnx.options[:timeout] = @timeout
          cnx.options[:open_timeout] = @open_timeout

          cnx.request :multipart if upload

          if parse_json
            cnx.request :json unless upload
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

      # @param rsrc[String] the API resource being uploadad-to,
      #   the URL part after 'JSSResource/'
      #
      # @param local_file[String, Pathname] the local file to upload
      #
      # @return [String] the xml response from the server.
      #
      def jp_upload(rsrc, local_file)
        upload_cnx = create_jp_connection upload: true

        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH

        payload = {}
        payload[:file] = Faraday::Multipart::FilePart.new(local_file.to_s, 'application/octet-stream')

        resp = upload_cnx.post rsrc, payload

        @last_http_response = resp

        return resp.body if resp.success?

        raise Jamf::Connection::JamfProAPIError, resp
      end # upload

    end # module

  end # class

end # module Jamf
