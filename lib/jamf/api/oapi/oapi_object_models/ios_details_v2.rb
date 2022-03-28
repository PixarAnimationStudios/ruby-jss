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

    # API Object Model and Enums for: IosDetailsV2
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::MobileDeviceDetailsV2
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::IdAndNameV2
    #  - OAPIObjectModels::PurchasingV2
    #  - OAPIObjectModels::SecurityV2
    #  - OAPIObjectModels::NetworkV2
    #  - OAPIObjectModels::MobileDeviceApplication
    #  - OAPIObjectModels::MobileDeviceCertificateV2
    #  - OAPIObjectModels::MobileDeviceEbook
    #  - OAPIObjectModels::ConfigurationProfile
    #  - OAPIObjectModels::ProvisioningProfile
    #  - OAPIObjectModels::MobileDeviceAttachmentV2
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::IosDetailsV2
    #
    module IosDetailsV2

      # These enums are used in the properties below

      

      OAPI_PROPERTIES = {

        # @!attribute model
        #   @return [String]
        model: {
          class: :string
        },

        # @!attribute modelIdentifier
        #   @return [String]
        modelIdentifier: {
          class: :string
        },

        # @!attribute modelNumber
        #   @return [String]
        modelNumber: {
          class: :string
        },

        # @!attribute supervised
        #   @return [Boolean]
        supervised: {
          class: :boolean
        },

        # @!attribute batteryLevel
        #   @return [Integer]
        batteryLevel: {
          class: :integer
        },

        # @!attribute lastBackupTimestamp
        #   @return [Jamf::Timestamp]
        lastBackupTimestamp: {
          class: Jamf::Timestamp
        },

        # @!attribute capacityMb
        #   @return [Integer]
        capacityMb: {
          class: :integer
        },

        # @!attribute availableMb
        #   @return [Integer]
        availableMb: {
          class: :integer
        },

        # @!attribute percentageUsed
        #   @return [Integer]
        percentageUsed: {
          class: :integer
        },

        # @!attribute shared
        #   @return [Boolean]
        shared: {
          class: :boolean
        },

        # @!attribute deviceLocatorServiceEnabled
        #   @return [Boolean]
        deviceLocatorServiceEnabled: {
          class: :boolean
        },

        # @!attribute doNotDisturbEnabled
        #   @return [Boolean]
        doNotDisturbEnabled: {
          class: :boolean
        },

        # @!attribute cloudBackupEnabled
        #   @return [Boolean]
        cloudBackupEnabled: {
          class: :boolean
        },

        # @!attribute lastCloudBackupTimestamp
        #   @return [Jamf::Timestamp]
        lastCloudBackupTimestamp: {
          class: Jamf::Timestamp
        },

        # @!attribute locationServicesEnabled
        #   @return [Boolean]
        locationServicesEnabled: {
          class: :boolean
        },

        # @!attribute iTunesStoreAccountActive
        #   @return [Boolean]
        iTunesStoreAccountActive: {
          class: :boolean
        },

        # @!attribute bleCapable
        #   @return [Boolean]
        bleCapable: {
          class: :boolean
        },

        # @!attribute computer
        #   @return [Jamf::IdAndNameV2]
        computer: {
          class: Jamf::IdAndNameV2
        },

        # @!attribute purchasing
        #   @return [Jamf::PurchasingV2]
        purchasing: {
          class: Jamf::PurchasingV2
        },

        # @!attribute security
        #   @return [Jamf::SecurityV2]
        security: {
          class: Jamf::SecurityV2
        },

        # @!attribute network
        #   @return [Jamf::NetworkV2]
        network: {
          class: Jamf::NetworkV2
        },

        # @!attribute applications
        #   @return [Array<Jamf::MobileDeviceApplication>]
        applications: {
          class: Jamf::MobileDeviceApplication,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::MobileDeviceCertificateV2>]
        certificates: {
          class: Jamf::MobileDeviceCertificateV2,
          multi: true
        },

        # @!attribute ebooks
        #   @return [Array<Jamf::MobileDeviceEbook>]
        ebooks: {
          class: Jamf::MobileDeviceEbook,
          multi: true
        },

        # @!attribute configurationProfiles
        #   @return [Array<Jamf::ConfigurationProfile>]
        configurationProfiles: {
          class: Jamf::ConfigurationProfile,
          multi: true
        },

        # @!attribute provisioningProfiles
        #   @return [Array<Jamf::ProvisioningProfile>]
        provisioningProfiles: {
          class: Jamf::ProvisioningProfile,
          multi: true
        },

        # @!attribute attachments
        #   @return [Array<Jamf::MobileDeviceAttachmentV2>]
        attachments: {
          class: Jamf::MobileDeviceAttachmentV2,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module IosDetailsV2

  end # module OAPIObjectModels

end # module Jamf
