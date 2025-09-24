# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# The module
module Jamf

  class Connection

    # An exception class that's a wrapper around Jamf::OAPIObject::ApiError
    #
    class JamfProAPIError < RuntimeError

      RSRC_NOT_FOUND = 'Resource Not Found'.freeze

      # @return [Faraday::Response]
      attr_reader :http_response

      # @return [Jamf::OAPIObject::ApiError]
      attr_reader :api_error

      # @param http_response [Faraday::Response]
      def initialize(http_response)
        @http_response = http_response
        @api_error = Jamf::OAPISchemas::ApiError.new @http_response.body

        add_common_basic_error_causes if @api_error.errors.empty?
        super
      end

      # If no actual errors causes came with the APIError, try to add
      # some common basic ones
      def add_common_basic_error_causes
        return unless api_error.errors.empty?

        case http_response.status
        when 403
          code = 'INVALID_PRIVILEGE'
          desc = 'Forbidden'
          id = nil
          field = ''
        when 404
          code = 'NOT_FOUND'
          desc = "'#{http_response.env.url.path}' was not found on the server"
          id = nil
          field = ''
        else
          return
        end # case

        api_error.errors_append Jamf::OAPISchemas::ApiErrorCause.new(field: field, code: code, description: desc, id: id)
      end

      # http status, from the server http response
      def http_status
        http_response.status
      end

      # http status, from the API error
      def api_status
        api_error.httpStatus
      end

      # @return [Array<Jamf::OAPIObject::ApiErrorCause>] the causes of the error
      def errors
        api_error.errors
      end

      # To string, this shows up as the exception msg when raising the exception
      def to_s
        msg = +"HTTP #{http_status}"
        msg << ':' unless errors.empty?
        msg << errors.map do |err|
          err_str = +''
          err_str << " Field: #{err.field}" unless err.field.to_s.empty?
          err_str << ', Error:' if err.code || err.description
          err_str << ", #{err.code}" if err.code
          err_str << ", #{err.description}" if err.description
          err_str << ", Object ID: '#{err.id}'" if err.id
          err_str
        end.join('; ')
        msg
      end

    end # class APIError

  end # class Connection

end # module Jamf
