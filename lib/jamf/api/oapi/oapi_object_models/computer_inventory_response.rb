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

    # API Object Model and Enums for: ComputerInventoryResponse
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::ComputerInventorySearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::ComputerGeneral
    #  - OAPIObjectModels::ComputerDiskEncryption
    #  - OAPIObjectModels::ComputerPurchase
    #  - OAPIObjectModels::ComputerApplication
    #  - OAPIObjectModels::ComputerStorage
    #  - OAPIObjectModels::ComputerUserAndLocation
    #  - OAPIObjectModels::ComputerConfigurationProfile
    #  - OAPIObjectModels::ComputerPrinter
    #  - OAPIObjectModels::ComputerService
    #  - OAPIObjectModels::ComputerHardware
    #  - OAPIObjectModels::ComputerLocalUserAccount
    #  - OAPIObjectModels::ComputerCertificate
    #  - OAPIObjectModels::ComputerAttachment
    #  - OAPIObjectModels::ComputerPlugin
    #  - OAPIObjectModels::ComputerPackageReceipts
    #  - OAPIObjectModels::ComputerFont
    #  - OAPIObjectModels::ComputerSecurity
    #  - OAPIObjectModels::ComputerOperatingSystem
    #  - OAPIObjectModels::ComputerLicensedSoftware
    #  - OAPIObjectModels::ComputerIbeacon
    #  - OAPIObjectModels::ComputerSoftwareUpdate
    #  - OAPIObjectModels::ComputerExtensionAttribute
    #  - OAPIObjectModels::ComputerContentCaching
    #  - OAPIObjectModels::GroupMembership
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/computers-inventory-detail/{id}:GET', needs permissions: Read Computers
    #  - '/v1/computers-inventory-detail/{id}:PATCH', needs permissions: Update Computers
    #  - '/v1/computers-inventory/{id}:GET', needs permissions: Read Computers
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::ComputerInventoryResponse
    #
    module ComputerInventoryResponse

      # These enums are used in the properties below

      

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute udid
        #   @return [String]
        udid: {
          class: :string
        },

        # @!attribute general
        #   @return [Jamf::ComputerGeneral]
        general: {
          class: Jamf::ComputerGeneral
        },

        # @!attribute diskEncryption
        #   @return [Jamf::ComputerDiskEncryption]
        diskEncryption: {
          class: Jamf::ComputerDiskEncryption
        },

        # @!attribute purchasing
        #   @return [Jamf::ComputerPurchase]
        purchasing: {
          class: Jamf::ComputerPurchase
        },

        # @!attribute applications
        #   @return [Array<Jamf::ComputerApplication>]
        applications: {
          class: Jamf::ComputerApplication,
          multi: true
        },

        # @!attribute storage
        #   @return [Jamf::ComputerStorage]
        storage: {
          class: Jamf::ComputerStorage
        },

        # @!attribute userAndLocation
        #   @return [Jamf::ComputerUserAndLocation]
        userAndLocation: {
          class: Jamf::ComputerUserAndLocation
        },

        # @!attribute configurationProfiles
        #   @return [Array<Jamf::ComputerConfigurationProfile>]
        configurationProfiles: {
          class: Jamf::ComputerConfigurationProfile,
          multi: true
        },

        # @!attribute printers
        #   @return [Array<Jamf::ComputerPrinter>]
        printers: {
          class: Jamf::ComputerPrinter,
          multi: true
        },

        # @!attribute services
        #   @return [Array<Jamf::ComputerService>]
        services: {
          class: Jamf::ComputerService,
          multi: true
        },

        # @!attribute hardware
        #   @return [Jamf::ComputerHardware]
        hardware: {
          class: Jamf::ComputerHardware
        },

        # @!attribute localUserAccounts
        #   @return [Array<Jamf::ComputerLocalUserAccount>]
        localUserAccounts: {
          class: Jamf::ComputerLocalUserAccount,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::ComputerCertificate>]
        certificates: {
          class: Jamf::ComputerCertificate,
          multi: true
        },

        # @!attribute attachments
        #   @return [Array<Jamf::ComputerAttachment>]
        attachments: {
          class: Jamf::ComputerAttachment,
          multi: true
        },

        # @!attribute plugins
        #   @return [Array<Jamf::ComputerPlugin>]
        plugins: {
          class: Jamf::ComputerPlugin,
          multi: true
        },

        # @!attribute packageReceipts
        #   @return [Jamf::ComputerPackageReceipts]
        packageReceipts: {
          class: Jamf::ComputerPackageReceipts
        },

        # @!attribute fonts
        #   @return [Array<Jamf::ComputerFont>]
        fonts: {
          class: Jamf::ComputerFont,
          multi: true
        },

        # @!attribute security
        #   @return [Jamf::ComputerSecurity]
        security: {
          class: Jamf::ComputerSecurity
        },

        # @!attribute operatingSystem
        #   @return [Jamf::ComputerOperatingSystem]
        operatingSystem: {
          class: Jamf::ComputerOperatingSystem
        },

        # @!attribute licensedSoftware
        #   @return [Array<Jamf::ComputerLicensedSoftware>]
        licensedSoftware: {
          class: Jamf::ComputerLicensedSoftware,
          multi: true
        },

        # @!attribute ibeacons
        #   @return [Array<Jamf::ComputerIbeacon>]
        ibeacons: {
          class: Jamf::ComputerIbeacon,
          multi: true
        },

        # @!attribute softwareUpdates
        #   @return [Array<Jamf::ComputerSoftwareUpdate>]
        softwareUpdates: {
          class: Jamf::ComputerSoftwareUpdate,
          multi: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::ComputerExtensionAttribute,
          multi: true
        },

        # @!attribute contentCaching
        #   @return [Jamf::ComputerContentCaching]
        contentCaching: {
          class: Jamf::ComputerContentCaching
        },

        # @!attribute groupMemberships
        #   @return [Array<Jamf::GroupMembership>]
        groupMemberships: {
          class: Jamf::GroupMembership,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module ComputerInventoryResponse

  end # module OAPIObjectModels

end # module Jamf
