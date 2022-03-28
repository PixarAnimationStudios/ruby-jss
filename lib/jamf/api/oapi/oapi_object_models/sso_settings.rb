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

    # API Object Model and Enums for: SsoSettings
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
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
    #  - '/v1/sso:GET', needs permissions: Read SSO Settings
    #  - '/v1/sso:PUT', needs permissions: Update SSO Settings
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::SsoSettings
    #
    module SsoSettings

      # These enums are used in the properties below

      USER_MAPPING_OPTIONS = [
        'USERNAME',
        'EMAIL'
      ]

      IDP_PROVIDER_TYPE_OPTIONS = [
        'ADFS',
        'OKTA',
        'GOOGLE',
        'SHIBBOLETH',
        'ONELOGIN',
        'PING',
        'CENTRIFY',
        'AZURE',
        'OTHER'
      ]

      METADATA_SOURCE_OPTIONS = [
        'URL',
        'FILE',
        'UNKNOWN'
      ]

      OAPI_PROPERTIES = {

        # @!attribute ssoForEnrollmentEnabled
        #   @return [Boolean]
        ssoForEnrollmentEnabled: {
          class: :boolean,
          required: true
        },

        # @!attribute ssoBypassAllowed
        #   @return [Boolean]
        ssoBypassAllowed: {
          class: :boolean,
          required: true
        },

        # @!attribute ssoEnabled
        #   @return [Boolean]
        ssoEnabled: {
          class: :boolean,
          required: true
        },

        # @!attribute ssoForMacOsSelfServiceEnabled
        #   @return [Boolean]
        ssoForMacOsSelfServiceEnabled: {
          class: :boolean,
          required: true
        },

        # @!attribute tokenExpirationDisabled
        #   @return [Boolean]
        tokenExpirationDisabled: {
          class: :boolean,
          required: true
        },

        # @!attribute userAttributeEnabled
        #   @return [Boolean]
        userAttributeEnabled: {
          class: :boolean,
          required: true
        },

        # @!attribute userAttributeName
        #   @return [String]
        userAttributeName: {
          class: :string
        },

        # @!attribute userMapping
        #   @return [String]
        userMapping: {
          class: :string,
          required: true,
          enum: USER_MAPPING_OPTIONS
        },

        # @!attribute groupEnrollmentAccessEnabled
        #   @return [Boolean]
        groupEnrollmentAccessEnabled: {
          class: :boolean,
          required: true
        },

        # @!attribute groupAttributeName
        #   @return [String]
        groupAttributeName: {
          class: :string,
          required: true
        },

        # @!attribute groupRdnKey
        #   @return [String]
        groupRdnKey: {
          class: :string,
          required: true
        },

        # @!attribute groupEnrollmentAccessName
        #   @return [String]
        groupEnrollmentAccessName: {
          class: :string
        },

        # @!attribute idpProviderType
        #   @return [String]
        idpProviderType: {
          class: :string,
          required: true,
          enum: IDP_PROVIDER_TYPE_OPTIONS
        },

        # @!attribute idpUrl
        #   @return [String]
        idpUrl: {
          class: :string
        },

        # @!attribute entityId
        #   @return [String]
        entityId: {
          class: :string,
          required: true
        },

        # @!attribute metadataFileName
        #   @return [String]
        metadataFileName: {
          class: :string
        },

        # @!attribute otherProviderTypeName
        #   @return [String]
        otherProviderTypeName: {
          class: :string
        },

        # @!attribute federationMetadataFile
        #   @return [String]
        federationMetadataFile: {
          class: :string
        },

        # @!attribute metadataSource
        #   @return [String]
        metadataSource: {
          class: :string,
          required: true,
          enum: METADATA_SOURCE_OPTIONS
        },

        # @!attribute sessionTimeout
        #   @return [Integer]
        sessionTimeout: {
          class: :integer
        }

      } # end OAPI_PROPERTIES

    end # module SsoSettings

  end # module OAPIObjectModels

end # module Jamf
