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


    # OAPI Object Model and Enums for: MobileDeviceDetails
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
    #  - Jamf::OAPISchemas::IdAndName
    #  - Jamf::OAPISchemas::ExtensionAttribute
    #  - Jamf::OAPISchemas::Location
    #  - Jamf::OAPISchemas::IosDetails
    #  - Jamf::OAPISchemas::AppleTvDetails
    #  - Jamf::OAPISchemas::AndroidDetails
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/mobile-devices/{id}:PATCH' needs permissions:
    #    - Update Mobile Devices
    #  - '/v1/mobile-devices/{id}/detail:GET' needs permissions:
    #    - Read Mobile Devices
    #
    #
    class MobileDeviceDetails < Jamf::OAPIObject

      # Enums used by this class or others

      TYPE_OPTIONS = [
        'ios',
        'appleTv',
        'android',
        'unknown'
      ]

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [Integer]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string
        },

        # @!attribute lastInventoryUpdateTimestamp
        #   @return [Jamf::Timestamp]
        lastInventoryUpdateTimestamp: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute osVersion
        #   @return [String]
        osVersion: {
          class: :string
        },

        # @!attribute osBuild
        #   @return [String]
        osBuild: {
          class: :string
        },

        # @!attribute softwareUpdateDeviceId
        #   @return [String]
        softwareUpdateDeviceId: {
          class: :string
        },

        # @!attribute serialNumber
        #   @return [String]
        serialNumber: {
          class: :string
        },

        # @!attribute udid
        #   @return [String]
        udid: {
          class: :string
        },

        # @!attribute ipAddress
        #   @return [String]
        ipAddress: {
          class: :string
        },

        # @!attribute wifiMacAddress
        #   @return [String]
        wifiMacAddress: {
          class: :string
        },

        # @!attribute bluetoothMacAddress
        #   @return [String]
        bluetoothMacAddress: {
          class: :string
        },

        # @!attribute isManaged
        #   @return [Boolean]
        isManaged: {
          class: :boolean
        },

        # @!attribute initialEntryTimestamp
        #   @return [Jamf::Timestamp]
        initialEntryTimestamp: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute lastEnrollmentTimestamp
        #   @return [Jamf::Timestamp]
        lastEnrollmentTimestamp: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute deviceOwnershipLevel
        #   @return [String]
        deviceOwnershipLevel: {
          class: :string
        },

        # @!attribute site
        #   @return [Jamf::OAPISchemas::IdAndName]
        site: {
          class: Jamf::OAPISchemas::IdAndName
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPISchemas::ExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::ExtensionAttribute,
          multi: true
        },

        # @!attribute location
        #   @return [Jamf::OAPISchemas::Location]
        location: {
          class: Jamf::OAPISchemas::Location
        },

        # Based on the value of this either ios, appleTv, android objects will be populated.
        # @!attribute type
        #   @return [String]
        type: {
          class: :string,
          enum: TYPE_OPTIONS
        },

        # @!attribute ios
        #   @return [Jamf::OAPISchemas::IosDetails]
        ios: {
          class: Jamf::OAPISchemas::IosDetails
        },

        # @!attribute appleTv
        #   @return [Jamf::OAPISchemas::AppleTvDetails]
        appleTv: {
          class: Jamf::OAPISchemas::AppleTvDetails
        },

        # @!attribute android
        #   @return [Jamf::OAPISchemas::AndroidDetails]
        android: {
          class: Jamf::OAPISchemas::AndroidDetails
        }

      } # end OAPI_PROPERTIES

    end # class MobileDeviceDetails

  end # module OAPISchemas

end # module Jamf
