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


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: SsoSettings
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.40.0-t1657115323
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
    #  - '/v1/sso:GET' needs permissions:
    #    - Read SSO Settings
    #  - '/v1/sso:PUT' needs permissions:
    #    - Update SSO Settings
    #
    #
    class SsoSettings < Jamf::OAPIObject

      # Enums used by this class or others

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
          class: :string,
          format: 'byte',
          pattern: Regexp.new('^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$')
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
          class: :integer,
          format: 'int32'
        }

      } # end OAPI_PROPERTIES

    end # class SsoSettings

  end # module OAPISchemas

end # module Jamf
