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

    # API Object Model and Enums for: MobileDeviceDetailsV2
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
    #  - OAPIObjectModels::V1Site
    #  - OAPIObjectModels::ExtensionAttributeV2
    #  - OAPIObjectModels::LocationV2
    #  - OAPIObjectModels::IosDetailsV2
    #  - OAPIObjectModels::TvOsDetails
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/mobile-devices/{id}:PATCH', needs permissions: Update Mobile Devices
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::MobileDeviceDetailsV2
    #
    module MobileDeviceDetailsV2

      # These enums are used in the properties below

      TYPE_OPTIONS = [
        'ios',
        'tvos',
        'unknown'
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # Mobile device name.
        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # Enforce the mobile device name. Device must be supervised. If set to true, Jamf Pro will revert the Mobile Device Name to the ‘name’ value each time the device checks in.
        # @!attribute enforceName
        #   @return [Boolean]
        enforceName: {
          class: :boolean
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string
        },

        # @!attribute lastInventoryUpdateTimestamp
        #   @return [Jamf::Timestamp]
        lastInventoryUpdateTimestamp: {
          class: Jamf::Timestamp
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

        # @!attribute managed
        #   @return [Boolean]
        managed: {
          class: :boolean
        },

        # @!attribute timeZone
        #   @return [String]
        timeZone: {
          class: :string
        },

        # @!attribute initialEntryTimestamp
        #   @return [Jamf::Timestamp]
        initialEntryTimestamp: {
          class: Jamf::Timestamp
        },

        # @!attribute lastEnrollmentTimestamp
        #   @return [Jamf::Timestamp]
        lastEnrollmentTimestamp: {
          class: Jamf::Timestamp
        },

        # @!attribute mdmProfileExpirationTimestamp
        #   @return [Jamf::Timestamp]
        mdmProfileExpirationTimestamp: {
          class: Jamf::Timestamp
        },

        # @!attribute deviceOwnershipLevel
        #   @return [String]
        deviceOwnershipLevel: {
          class: :string
        },

        # @!attribute enrollmentMethod
        #   @return [String]
        enrollmentMethod: {
          class: :string
        },

        # @!attribute site
        #   @return [Jamf::V1Site]
        site: {
          class: Jamf::V1Site
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::ExtensionAttributeV2>]
        extensionAttributes: {
          class: Jamf::ExtensionAttributeV2,
          multi: true
        },

        # @!attribute location
        #   @return [Jamf::LocationV2]
        location: {
          class: Jamf::LocationV2
        },

        # Based on the value of this either ios, appleTv, android objects will be populated.
        # @!attribute type
        #   @return [String]
        type: {
          class: :string,
          enum: TYPE_OPTIONS
        },

        # @!attribute ios
        #   @return [Jamf::IosDetailsV2]
        ios: {
          class: Jamf::IosDetailsV2
        },

        # @!attribute tvos
        #   @return [Jamf::TvOsDetails]
        tvos: {
          class: Jamf::TvOsDetails
        }

      } # end OAPI_PROPERTIES

    end # module MobileDeviceDetailsV2

  end # module OAPIObjectModels

end # module Jamf
