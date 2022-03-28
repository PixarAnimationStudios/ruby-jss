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

  # This module contains Object Model and Enum Constants for all JSONObjects
  # defined in the Jamf Pro API.
  #
  # Generated automatically from the OAPI schema available from the
  # 'api/schema' endpoint of any Jamf Pro server.
  #
  # This file was generated from Jamf Pro version 10.36.1
  #
  module OAPIObjectModels

    # API Object Model and Enums for: CloudLdapServerResponse
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::LdapConfigurationResponse
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::CloudLdapKeystore
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/cloud-ldaps/defaults/{provider}/server-configuration:GET', needs permissions: Read LDAP Servers
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::CloudLdapServerResponse
    #
    module CloudLdapServerResponse

      # These enums are used in the properties below

      CONNECTION_TYPE_OPTIONS = [
        'LDAPS',
        'START_TLS'
      ]

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean
        },

        # @!attribute serverUrl
        #   @return [String]
        serverUrl: {
          class: :string
        },

        # @!attribute domainName
        #   @return [String]
        domainName: {
          class: :string
        },

        # @!attribute port
        #   @return [Integer]
        port: {
          class: :integer
        },

        # @!attribute keystore
        #   @return [Jamf::CloudLdapKeystore]
        keystore: {
          class: Jamf::CloudLdapKeystore
        },

        # @!attribute connectionTimeout
        #   @return [Integer]
        connectionTimeout: {
          class: :integer
        },

        # @!attribute searchTimeout
        #   @return [Integer]
        searchTimeout: {
          class: :integer
        },

        # @!attribute useWildcards
        #   @return [Boolean]
        useWildcards: {
          class: :boolean
        },

        # @!attribute connectionType
        #   @return [String]
        connectionType: {
          class: :string,
          enum: CONNECTION_TYPE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # module CloudLdapServerResponse

  end # module OAPIObjectModels

end # module Jamf
