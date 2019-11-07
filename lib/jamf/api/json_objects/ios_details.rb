# Copyright 2018 Pixar

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

  class IosDetails < Jamf::JSONObject

    # Class Constants
    #####################################

    # Since instances of this class are always embedded in the
    # matching MobileDevice instance, duplicated attributes are
    # omitted from OBJECT_MODEL
    OBJECT_MODEL = {

      # @!attribute [r] model
      #   @param [String]
      #   @return [String]
      model: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] modelIdentifier
      #   @param [String]
      #   @return [String]
      modelIdentifier: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] modelNumber
      #   @param [String]
      #   @return [String]
      modelNumber: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] isSupervised
      #   @return [Boolean]
      isSupervised: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] batteryLevel
      #   @return [Integer]
      batteryLevel: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] lastBackupTimestamp
      #   @return [Jamf::Timestamp]
      lastBackupTimestamp: {
        class: Jamf::Timestamp,
        readonly: true,
        aliases: [:lastBackup]
      },

      # @!attribute [r] capacityMb
      #   @return [Integer]
      capacityMb: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] availableMb
      #   @return [Integer]
      availableMb: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] percentageUsed
      #   @return [Integer]
      percentageUsed: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] isShared
      #   @return [Boolean]
      isShared: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] isDeviceLocatorServiceEnabled
      #   @return [Boolean]
      isDeviceLocatorServiceEnabled: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] isDoNotDisturbEnabled
      #   @return [Boolean]
      isDoNotDisturbEnabled: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] isCloudBackupEnabled
      #   @return [Boolean]
      isCloudBackupEnabled: {
        class: :boolean,
        readonly: true
      },

      # @!attribute lastCloudBackupTimestamp
      #   @return [Jamf::Timestamp]
      lastCloudBackupTimestamp: {
        class: Jamf::Timestamp,
        readonly: true,
        aliases: [:lastCloudBackup]
      },

      # @!attribute [r] isLocationServicesEnabled
      #   @return [Boolean]
      isLocationServicesEnabled: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] isITunesStoreAccountActive
      #   @return [Boolean]
      isITunesStoreAccountActive: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] isBleCapable
      #   @return [Boolean]
      isBleCapable: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] computer
      #   @return [Jamf::Computer::Reference]
      computer: {
        class: Jamf::Computer::Reference,
        readonly: true
      },

      # @!attribute [r] purchasing
      #   @return [Jamf::Computer::Reference]
      purchasing: {
        class: Jamf::PurchasingData,
        readonly: true
      },

      # @!attribute [r] security
      #   @return [Jamf::MobileDeviceSecurity]
      security: {
        class: Jamf::MobileDeviceSecurity,
        readonly: true
      },

      # @!attribute [r] network
      #   @return [Jamf::CCellularNetwork]
      network: {
        class: Jamf::CellularNetwork,
        readonly: true
      },

      # @!attribute [r] applications
      #   @return [Jamf::InstalledApplication]
      applications: {
        class: Jamf::InstalledApplication,
        readonly: true,
        multi: true
      },

      # @!attribute [r] certificates
      #   @return [Jamf::InstalledApplication]
      certificates: {
        class: Jamf::InstalledCertificate,
        readonly: true,
        multi: true
      },

      # @!attribute [r] ebooks
      #   @return [Jamf::InstalledApplication]
      ebooks: {
        class: Jamf::InstalledEBook,
        readonly: true,
        multi: true
      },

      # @!attribute [r] configurationProfiles
      #   @return [Jamf::InstalledConfigurationProfile]
      configurationProfiles: {
        class: Jamf::InstalledConfigurationProfile,
        readonly: true,
        multi: true
      },

      # @!attribute [r] provisioningProfiles
      #   @return [Jamf::InstalledConfigurationProfile]
      provisioningProfiles: {
        class: Jamf::InstalledProvisioningProfile,
        readonly: true,
        multi: true
      },

      # @!attribute [r] attachments
      #   @return [Jamf::InstalledConfigurationProfile]
      attachments: {
        class: Jamf::Attachment::Reference,
        readonly: true,
        multi: true
      }
    }.freeze
    parse_object_model


  end # class  Details

end # module
