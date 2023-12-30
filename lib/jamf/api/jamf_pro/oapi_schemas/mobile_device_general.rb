# Copyright 2023 Pixar
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


    # OAPI Object Model and Enums for: MobileDeviceGeneral
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.50.0-t1693149930
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
    #  - Jamf::OAPISchemas::EnrollmentMethodPrestage
    #  - Jamf::OAPISchemas::MobileDeviceExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class MobileDeviceGeneral < Jamf::OAPIObject

      # Enums used by this class or others

      DEVICE_OWNERSHIP_TYPE_OPTIONS = [
        'Institutional',
        'PersonalDeviceProfile',
        'UserEnrollment',
        'AccountDrivenUserEnrollment'
      ]

      OAPI_PROPERTIES = {

        # @!attribute udid
        #   @return [String]
        udid: {
          class: :string
        },

        # @!attribute displayName
        #   @return [String]
        displayName: {
          class: :string
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string
        },

        # @!attribute siteId
        #   @return [String]
        siteId: {
          class: :string
        },

        # @!attribute lastInventoryUpdateDate
        #   @return [Jamf::Timestamp]
        lastInventoryUpdateDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute osVersion
        #   @return [String]
        osVersion: {
          class: :string
        },

        # @!attribute osRapidSecurityResponse
        #   @return [String]
        osRapidSecurityResponse: {
          class: :string
        },

        # @!attribute osBuild
        #   @return [String]
        osBuild: {
          class: :string
        },

        # @!attribute osSupplementalBuildVersion
        #   @return [String]
        osSupplementalBuildVersion: {
          class: :string
        },

        # @!attribute softwareUpdateDeviceId
        #   @return [String]
        softwareUpdateDeviceId: {
          class: :string
        },

        # @!attribute ipAddress
        #   @return [String]
        ipAddress: {
          class: :string
        },

        # @!attribute managed
        #   @return [Boolean]
        managed: {
          class: :boolean
        },

        # @!attribute supervised
        #   @return [Boolean]
        supervised: {
          class: :boolean
        },

        # @!attribute deviceOwnershipType
        #   @return [String]
        deviceOwnershipType: {
          class: :string,
          enum: DEVICE_OWNERSHIP_TYPE_OPTIONS
        },

        # @!attribute enrollmentMethodPrestage
        #   @return [Jamf::OAPISchemas::EnrollmentMethodPrestage]
        enrollmentMethodPrestage: {
          class: Jamf::OAPISchemas::EnrollmentMethodPrestage
        },

        # @!attribute enrollmentSessionTokenValid
        #   @return [Boolean]
        enrollmentSessionTokenValid: {
          class: :boolean
        },

        # @!attribute lastEnrolledDate
        #   @return [Jamf::Timestamp]
        lastEnrolledDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute mdmProfileExpirationDate
        #   @return [Jamf::Timestamp]
        mdmProfileExpirationDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # IANA time zone database name
        # @!attribute timeZone
        #   @return [String]
        timeZone: {
          class: :string
        },

        # @!attribute declarativeDeviceManagementEnabled
        #   @return [Boolean]
        declarativeDeviceManagementEnabled: {
          class: :boolean
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPISchemas::MobileDeviceExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::MobileDeviceExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class MobileDeviceGeneral

  end # module OAPISchemas

end # module Jamf
