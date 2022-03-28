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

    # API Object Model and Enums for: IosDetails
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::MobileDeviceDetails
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::IdAndName
    #  - OAPIObjectModels::Purchasing
    #  - OAPIObjectModels::Security
    #  - OAPIObjectModels::Network
    #  - OAPIObjectModels::MobileDeviceApplication
    #  - OAPIObjectModels::MobileDeviceCertificateV1
    #  - OAPIObjectModels::MobileDeviceEbook
    #  - OAPIObjectModels::ConfigurationProfile
    #  - OAPIObjectModels::ProvisioningProfile
    #  - OAPIObjectModels::MobileDeviceAttachment
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
    #   include Jamf::OAPIObjectModels::IosDetails
    #
    module IosDetails

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

        # @!attribute isSupervised
        #   @return [Boolean]
        isSupervised: {
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

        # @!attribute isShared
        #   @return [Boolean]
        isShared: {
          class: :boolean
        },

        # @!attribute isDeviceLocatorServiceEnabled
        #   @return [Boolean]
        isDeviceLocatorServiceEnabled: {
          class: :boolean
        },

        # @!attribute isDoNotDisturbEnabled
        #   @return [Boolean]
        isDoNotDisturbEnabled: {
          class: :boolean
        },

        # @!attribute isCloudBackupEnabled
        #   @return [Boolean]
        isCloudBackupEnabled: {
          class: :boolean
        },

        # @!attribute lastCloudBackupTimestamp
        #   @return [Jamf::Timestamp]
        lastCloudBackupTimestamp: {
          class: Jamf::Timestamp
        },

        # @!attribute isLocationServicesEnabled
        #   @return [Boolean]
        isLocationServicesEnabled: {
          class: :boolean
        },

        # @!attribute isITunesStoreAccountActive
        #   @return [Boolean]
        isITunesStoreAccountActive: {
          class: :boolean
        },

        # @!attribute isBleCapable
        #   @return [Boolean]
        isBleCapable: {
          class: :boolean
        },

        # @!attribute computer
        #   @return [Jamf::IdAndName]
        computer: {
          class: Jamf::IdAndName
        },

        # @!attribute purchasing
        #   @return [Jamf::Purchasing]
        purchasing: {
          class: Jamf::Purchasing
        },

        # @!attribute security
        #   @return [Jamf::Security]
        security: {
          class: Jamf::Security
        },

        # @!attribute network
        #   @return [Jamf::Network]
        network: {
          class: Jamf::Network
        },

        # @!attribute applications
        #   @return [Array<Jamf::MobileDeviceApplication>]
        applications: {
          class: Jamf::MobileDeviceApplication,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::MobileDeviceCertificateV1>]
        certificates: {
          class: Jamf::MobileDeviceCertificateV1,
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
        #   @return [Array<Jamf::MobileDeviceAttachment>]
        attachments: {
          class: Jamf::MobileDeviceAttachment,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module IosDetails

  end # module OAPIObjectModels

end # module Jamf
