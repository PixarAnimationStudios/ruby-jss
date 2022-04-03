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
#


module Jamf

  # This class is the superclass AND the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  class OAPIObject


    # OAPI Object Model and Enums for: CloudLdapServerRequest
    #
    # Description of this class from the OAPI Schema:
    #   A Cloud Identity Provider LDAP server configuration for requests
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.36.1-t1645562643
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
    #  - Jamf::OAPIObject::LdapConfigurationRequest
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::CloudLdapKeystoreFile
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class CloudLdapServerRequest < OAPIObject

      # Enums used by this class or others

      CONNECTION_TYPE_OPTIONS = [
        'LDAPS',
        'START_TLS'
      ]

      OAPI_PROPERTIES = {

        # @!attribute serverUrl
        #   @return [String]
        serverUrl: {
          class: :string,
          required: true
        },

        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean,
          required: true
        },

        # @!attribute domainName
        #   @return [String]
        domainName: {
          class: :string,
          required: true
        },

        # @!attribute port
        #   @return [Integer]
        port: {
          class: :integer,
          minimum: 1,
          maximum: 65535,
          required: true
        },

        # Request with the Base64-encoded keystore file
        # @!attribute keystore
        #   @return [Hash{Symbol: Object}]
        keystore: {
          class: :hash,
          required: true
        },

        # @!attribute connectionTimeout
        #   @return [Integer]
        connectionTimeout: {
          class: :integer,
          minimum: 5,
          maximum: 600.0,
          required: true
        },

        # @!attribute searchTimeout
        #   @return [Integer]
        searchTimeout: {
          class: :integer,
          minimum: 5,
          maximum: 600.0,
          required: true
        },

        # @!attribute useWildcards
        #   @return [Boolean]
        useWildcards: {
          class: :boolean,
          required: true
        },

        # @!attribute connectionType
        #   @return [String]
        connectionType: {
          class: :string,
          required: true,
          enum: CONNECTION_TYPE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class CloudLdapServerRequest

  end # class OAPIObject

end # module Jamf
