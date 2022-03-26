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

# The module
module Jamf

  class Connection

    # TODO: figure out what to do with
    # ConflictError, BadRequestError, APIRequestError
    # and maybe AuthenticationError
    class JamfProAPIError < RuntimeError

      RSRC_NOT_FOUND = 'Resource Not Found'.freeze

      # @return [Faraday::Response]
      attr_reader :http_response

      # @return [integer]
      #
      attr_reader :httpStatus
      alias status httpStatus

      # @return [Array<ErrorInfo>] see  ErrorInfo above
      #
      attr_reader :errors

      # @return [RestClient::ExceptionWithResponse] the original RestClient error
      attr_reader :rest_error

      # @param rest_error [RestClient::ExceptionWithResponse]
      def initialize(http_response)
        @http_response = http_response
        @httpStatus = http_response.status
        @errors =
          case @http_response.body
          when String
            JSON.parse(@http_response.body)[:errors]
          when Hash
            @http_response.body[:errors]
          end
        @errors &&= @errors.map { |e| ErrorInfo.new e }

        unless @errors
          code = @httpStatus
          desc = code == 404 ? RSRC_NOT_FOUND : @http_response.reason_phrase
          @errors = [ErrorInfo.new(code: code, field: nil, description: desc, id: nil)]
        end

        super
      end

      # To string
      def to_s
        @errors.map(&:to_s).join '; '
      end

    end # class APIError

  end # class Connection

end # module Jamf
