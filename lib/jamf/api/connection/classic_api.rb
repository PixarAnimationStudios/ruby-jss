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

# THe main module
module Jamf

  # The connection class
  class Connection

    # This module defines methods used for interacting with the Classic API.
    # This includes creating the Faraday connection, sending HTTP requests and
    # handling responses
    module ClassicAPI

      # Get a Classic API resource via GET
      #
      # The first argument is the resource to get (the part of the API url
      # after the 'JSSResource/' ) The resource must be properly URL escaped
      # beforehand. Note: URL.encode is deprecated, use CGI.escape
      #
      # By default we get the data in JSON, and parse it into a ruby Hash
      # with symbolized Hash keys.
      #
      # If the second parameter is :xml then the XML version is retrieved and
      # returned as a String.
      #
      # To get the raw JSON string as it comes from the API, pass raw_json: true
      #
      # @param rsrc[String] the resource to get
      #   (the part of the API url after the 'JSSResource/' )
      #
      # @param format[Symbol] either ;json or :xml
      #   If the second argument is :xml, the XML data is returned as a String.
      #
      # @param raw_json[Boolean] When GETting JSON, return the raw unparsed string
      #   (the XML is always returned as a raw string)
      #
      # @return [Hash,String] the result of the get
      #
      def c_get(rsrc, format = :json, raw_json: false)
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH

        validate_connected @c_cnx
        raise Jamf::InvalidDataError, 'format must be :json or :xml' unless Jamf::Connection::GET_FORMATS.include?(format)

        resp =
          @c_cnx.get(rsrc) do |req|
            req.headers[Jamf::Connection::HTTP_ACCEPT_HEADER] = format == :json ? Jamf::Connection::MIME_JSON : Jamf::Connection::MIME_XML
            # puts "Classic API Cookie is: #{req.headers['Cookie']}"
          end
        @last_http_response = resp
        unless resp.success?
          handle_classic_http_error resp
          return
        end

        return JSON.parse(resp.body, symbolize_names: true) if format == :json && !raw_json

        # the raw body, either json or xml
        resp.body
      end # c_get
      # backward compatibility
      alias get_rsrc c_get

      # Create a new Classic API resource via POST
      #
      # @param rsrc[String] the API resource being created, the URL part after 'JSSResource/'
      #
      # @param xml[String] the xml specifying the new object.
      #
      # @return [String] the xml response from the server.
      #
      def c_post(rsrc, xml)
        validate_connected @c_cnx

        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH

        # convert CRs & to &#13;
        xml&.gsub!(/\r/, '&#13;')

        # send the data
        resp =
          @c_cnx.post(rsrc) do |req|
            req.headers[Jamf::Connection::HTTP_CONTENT_TYPE_HEADER] = Jamf::Connection::MIME_XML
            req.headers[Jamf::Connection::HTTP_ACCEPT_HEADER] = Jamf::Connection::MIME_XML
            req.body = xml
          end
        @last_http_response = resp

        unless resp.success?
          handle_classic_http_error resp
          return
        end

        resp.body
      end # c_post
      # backward compatibility
      alias post_rsrc c_post

      # Update an existing Classic API resource
      #
      # @param rsrc[String] the API resource being changed, the URL part after 'JSSResource/'
      #
      # @param xml[String] the xml specifying the changes.
      #
      # @return [String] the xml response from the server.
      #
      def c_put(rsrc, xml)
        validate_connected @c_cnx

        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH

        # convert CRs & to &#13;
        xml.gsub!(/\r/, '&#13;')

        # send the data
        resp =
          @c_cnx.put(rsrc) do |req|
            req.headers[Jamf::Connection::HTTP_CONTENT_TYPE_HEADER] = Jamf::Connection::MIME_XML
            req.headers[Jamf::Connection::HTTP_ACCEPT_HEADER] = Jamf::Connection::MIME_XML
            req.body = xml
          end
        @last_http_response = resp

        unless resp.success?
          handle_classic_http_error resp
          return
        end

        resp.body
      end
      # backward compatibility
      alias put_rsrc c_put

      # Delete a resource from the Classic API
      #
      # @param rsrc[String] the resource to create, the URL part after 'JSSResource/'
      #
      # @return [String] the xml response from the server.
      #
      def c_delete(rsrc)
        validate_connected @c_cnx
        raise MissingDataError, 'Missing :rsrc' if rsrc.nil?

        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH

        # delete the resource
        resp =
          @c_cnx.delete(rsrc) do |req|
            req.headers[Jamf::Connection::HTTP_CONTENT_TYPE_HEADER] = Jamf::Connection::MIME_XML
            req.headers[Jamf::Connection::HTTP_ACCEPT_HEADER] = Jamf::Connection::MIME_XML
          end
        @last_http_response = resp

        unless resp.success?
          handle_classic_http_error resp
          return
        end

        resp.body
      end # delete_rsrc
      # backward compatibility
      alias delete_rsrc c_delete

      # Upload a file. This is really only used for the
      # 'fileuploads' endpoint of the classic API, as implemented in the
      # Uploadable mixin module, q.v.
      #
      # @param rsrc[String] the API resource being uploadad-to,
      #   the URL part after 'JSSResource/'
      #
      # @param local_file[String, Pathname] the local file to upload
      #
      # @return [String] the xml response from the server.
      #
      def upload(rsrc, local_file)
        validate_connected @c_cnx
        rsrc = rsrc.delete_prefix Jamf::Connection::SLASH

        # the upload file object for faraday
        local_file = Pathname.new local_file
        upfile = Faraday::UploadIO.new(
          local_file.to_s,
          'application/octet-stream',
          local_file.basename.to_s
        )

        # send it and get the response
        resp =
          @c_cnx.post rsrc do |req|
            req.headers['Content-Type'] = 'multipart/form-data'
            req.body = { name: upfile }
          end
        @last_http_response = resp

        unless resp.success?
          handle_classic_http_error resp
          return false
        end

        true
      end # upload

      #############################
      private

      # create the faraday CAPI connection object
      def create_classic_connection
        Faraday.new(@c_base_url, ssl: ssl_options) do |cnx|
          cnx.authorization :Bearer, @token.token

          cnx.options[:timeout] = @timeout
          cnx.options[:open_timeout] = @open_timeout

          cnx.request :multipart
          cnx.request :url_encoded

          cnx.adapter Faraday::Adapter::NetHttp
        end
      end

      # Parses the given http response
      # and raises a Jamf::APIError with a useful error message.
      #
      # @return [void]
      #
      def handle_classic_http_error(resp)
        return if resp.success?

        case resp.status
        when 404
          err = Jamf::NoSuchItemError
          msg = 'Not Found'
        when 409
          err = Jamf::ConflictError

          # TODO: Clean this up
          resp.body =~ /<p>(The server has not .*?)(<|$)/m
          msg = Regexp.last_match(1)

          unless msg
            resp.body =~ %r{<p>Error: (.*?)</p>}
            msg = Regexp.last_match(1)
          end

          unless msg
            resp.body =~ /<p>(Unable to complete file upload.*?)(<|$)/m
            msg = Regexp.last_match(1)
          end
        when 400
          err = Jamf::BadRequestError
          resp.body =~ %r{>Bad Request</p>\n<p>(.*?)</p>\n<p>You can get technical detail}m
          msg = Regexp.last_match(1)
        when 401
          if resp.body.include? 'INVALID_TOKEN'
            err = Jamf::InvalidConnectionError
            msg = 'Connection token is not valid'
          else
            err = Jamf::AuthorizationError
            msg = 'You are not authorized to do that.'
          end
        when (500..599)
          err = Jamf::APIRequestError
          msg = 'There was an internal server error'
        else
          err = Jamf::APIRequestError
          msg = "There was a error processing your request, status: #{resp.status}"
        end
        raise err, msg
      end

    end # module

  end # class

end # module Jamf
