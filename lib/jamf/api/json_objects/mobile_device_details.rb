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
#

# The module
module Jamf

  # Classes
  #####################################

  # details of a mob dev
  class MobileDeviceDetails < Jamf::JSONObject

    # Mixins
    #####################################

    # Class Constants
    #####################################

    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute [r] name
      #   This is readonly becuase the name attribute of
      #   the enclosing MobileDevice is used.
      #   @return [String]
      name: {
        class: :string,
        readonly: true
      },

      # @!attribute assetTag
      #   @param [String]
      #   @return [String]
      assetTag: {
        class: :string
        # TODO: make this an identifier?
      },

      # @!attribute [r] lastInventoryUpdateTimestamp
      #   @return [String]
      lastInventoryUpdateTimestamp: {
        class: Jamf::Timestamp,
        aliases: [:lastInventoryUpdate],
        readonly: true
      },

      # @!attribute [r] osVersion
      #   @return [String]
      osVersion: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] osBuild
      #   @return [String]
      osBuild: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] serialNumber
      #   @param [String]
      #   @return [String]
      serialNumber: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] udid
      #   @param [String]
      #   @return [String]
      udid: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] ipAddress
      #   @return [Jamf::IPAddress]
      ipAddress: {
        class: Jamf::IPAddress,
        readonly: true
      },

      # @!attribute [r] wifiMacAddress
      #   @param [String]
      #   @return [String]
      wifiMacAddress: {
        class: :string,
        identifier: true,
        readonly: true
      },

      # @!attribute [r] bluetoothMacAddress
      #   @return [String]
      bluetoothMacAddress: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] isManaged
      #   see Jamf::MobileDevice#unmanage
      #   @return [Boolean]
      isManaged: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] initialEntryTimestamp
      #   @return [Jamf::Timestamp]
      initialEntryTimestamp: {
        class: Jamf::Timestamp,
        readonly: true,
        aliases: %i[initialEntry firstEnrolled]
      },

      # @!attribute [r] lastEnrollmentTimestamp
      #   @return [Boolean]
      lastEnrollmentTimestamp: {
        class: Jamf::Timestamp,
        readonly: true,
        aliases: %i[lastEnrollment lastEnrolled]
      },

      # @!attribute deviceOwnershipLevel
      #   @return [String]
      deviceOwnershipLevel: {
        class: :string,
        readonly: true
      },

      # @!attribute site
      #   @param @see Jamf::Site::Reference#initialize
      #   @return [Jamf::Site::Reference]
      site: {
        class: Jamf::Site::Reference
      },

      # @!attribute [r] extensionAttributes
      #   see Jamf::Extendable
      #   @return [Array<Jamf::ExtensionAttribute::Value>]
      extensionAttributes: {
        class: Jamf::ExtensionAttributeValue,
        multi: true,
        readonly: true
      },

      # @!attribute [r] location
      #   see Jamf::Locatable
      #   @return [Jamf::Location]
      location: {
        class: Jamf::Location
      },

      # @!attribute [r] ios
      #   @return [Jamf::MobileDevice::IosDetails]
      ios: {
        class: Jamf::IosDetails,
        readonly: true
      },

      # @!attribute [r] appleTv
      #   @return [Jamf::MobileDevice::AppleTvDetails]
      appleTv: {
        class: Jamf::AppleTVDetails,
        readonly: true
      },

      # @!attribute [r] android
      #   @return [Jamf::MobileDevice::AndroidDetails]
      android: {
        class: Jamf::AndroidDetails,
        readonly: true
      }

    }.freeze
    parse_object_model

    # Class Methods
    ###################################################

    def self.fetch(id, cnx)
      data = cnx.get "#{Jamf::MobileDevice::RSRC_PATH}/#{id}/detail"
      new data, cnx: cnx
    end

  end # class Mobile Device Details

end # module
