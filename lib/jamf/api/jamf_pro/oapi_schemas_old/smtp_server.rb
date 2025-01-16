# Copyright 2025 Pixar
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

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: SmtpServer
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.6.1-t1718634702
    #
    # This class may be used directly, e.g instances of other classes may
    # use instances of this class as one of their own properties/attributes.
    #
    # It may also be used as a superclass when implementing Jamf Pro API
    # Resources in ruby-jss. The subclasses include appropriate mixins, and
    # should expand on the basic functionality provided here.
    #
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/smtp-server:GET' needs permissions:
    #    - Read SMTP Server
    #  - '/v1/smtp-server:PUT' needs permissions:
    #    - Update SMTP Server
    #
    #
    class SmtpServer < Jamf::OAPIObject

      # Enums used by this class or others

      ENCRYPTION_TYPE_OPTIONS = %w[
        NONE
        SSL
        TLS_1_3
        TLS_1_2
        TLS_1_1
        TLS_1
      ]

      OAPI_PROPERTIES = {

        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean,
          required: true
        },

        # @!attribute server
        #   @return [String]
        server: {
          class: :string,
          required: true
        },

        # @!attribute port
        #   @return [Integer]
        port: {
          class: :integer,
          required: true
        },

        # @!attribute encryptionType
        #   @return [String]
        encryptionType: {
          class: :string,
          required: true,
          enum: ENCRYPTION_TYPE_OPTIONS
        },

        # @!attribute connectionTimeout
        #   @return [Integer]
        connectionTimeout: {
          class: :integer,
          required: true
        },

        # @!attribute senderDisplayName
        #   @return [String]
        senderDisplayName: {
          class: :string,
          required: true
        },

        # @!attribute senderEmailAddress
        #   @return [String]
        senderEmailAddress: {
          class: :string,
          required: true
        },

        # @!attribute requiresAuthentication
        #   @return [Boolean]
        requiresAuthentication: {
          class: :boolean,
          required: true
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute password
        #   @return [String]
        password: {
          class: :string,
          format: 'password',
          writeonly: true
        }

      } # end OAPI_PROPERTIES

    end # class SmtpServer

  end # module OAPISchemas

end # module Jamf
