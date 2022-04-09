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

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: ComputerInventoryResponse
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.36.1-t1645562643
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
    #  - Jamf::OAPISchemas::ComputerInventorySearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::ComputerGeneral
    #  - Jamf::OAPISchemas::ComputerDiskEncryption
    #  - Jamf::OAPISchemas::ComputerPurchase
    #  - Jamf::OAPISchemas::ComputerApplication
    #  - Jamf::OAPISchemas::ComputerStorage
    #  - Jamf::OAPISchemas::ComputerUserAndLocation
    #  - Jamf::OAPISchemas::ComputerConfigurationProfile
    #  - Jamf::OAPISchemas::ComputerPrinter
    #  - Jamf::OAPISchemas::ComputerService
    #  - Jamf::OAPISchemas::ComputerHardware
    #  - Jamf::OAPISchemas::ComputerLocalUserAccount
    #  - Jamf::OAPISchemas::ComputerCertificate
    #  - Jamf::OAPISchemas::ComputerAttachment
    #  - Jamf::OAPISchemas::ComputerPlugin
    #  - Jamf::OAPISchemas::ComputerPackageReceipts
    #  - Jamf::OAPISchemas::ComputerFont
    #  - Jamf::OAPISchemas::ComputerSecurity
    #  - Jamf::OAPISchemas::ComputerOperatingSystem
    #  - Jamf::OAPISchemas::ComputerLicensedSoftware
    #  - Jamf::OAPISchemas::ComputerIbeacon
    #  - Jamf::OAPISchemas::ComputerSoftwareUpdate
    #  - Jamf::OAPISchemas::ComputerExtensionAttribute
    #  - Jamf::OAPISchemas::ComputerContentCaching
    #  - Jamf::OAPISchemas::GroupMembership
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/computers-inventory-detail/{id}:GET' needs permissions:
    #    - Read Computers
    #  - '/v1/computers-inventory-detail/{id}:PATCH' needs permissions:
    #    - Update Computers
    #  - '/v1/computers-inventory/{id}:GET' needs permissions:
    #    - Read Computers
    #
    #
    class ComputerInventoryResponse < Jamf::OAPIObject

      

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
        #   @return [Jamf::OAPISchemas::ComputerGeneral]
        general: {
          class: Jamf::OAPISchemas::ComputerGeneral
        },

        # @!attribute diskEncryption
        #   @return [Jamf::OAPISchemas::ComputerDiskEncryption]
        diskEncryption: {
          class: Jamf::OAPISchemas::ComputerDiskEncryption
        },

        # @!attribute purchasing
        #   @return [Jamf::OAPISchemas::ComputerPurchase]
        purchasing: {
          class: Jamf::OAPISchemas::ComputerPurchase
        },

        # @!attribute applications
        #   @return [Array<Jamf::OAPISchemas::ComputerApplication>]
        applications: {
          class: Jamf::OAPISchemas::ComputerApplication,
          multi: true
        },

        # @!attribute storage
        #   @return [Jamf::OAPISchemas::ComputerStorage]
        storage: {
          class: Jamf::OAPISchemas::ComputerStorage
        },

        # @!attribute userAndLocation
        #   @return [Jamf::OAPISchemas::ComputerUserAndLocation]
        userAndLocation: {
          class: Jamf::OAPISchemas::ComputerUserAndLocation
        },

        # @!attribute configurationProfiles
        #   @return [Array<Jamf::OAPISchemas::ComputerConfigurationProfile>]
        configurationProfiles: {
          class: Jamf::OAPISchemas::ComputerConfigurationProfile,
          multi: true
        },

        # @!attribute printers
        #   @return [Array<Jamf::OAPISchemas::ComputerPrinter>]
        printers: {
          class: Jamf::OAPISchemas::ComputerPrinter,
          multi: true
        },

        # @!attribute services
        #   @return [Array<Jamf::OAPISchemas::ComputerService>]
        services: {
          class: Jamf::OAPISchemas::ComputerService,
          multi: true
        },

        # @!attribute hardware
        #   @return [Jamf::OAPISchemas::ComputerHardware]
        hardware: {
          class: Jamf::OAPISchemas::ComputerHardware
        },

        # @!attribute localUserAccounts
        #   @return [Array<Jamf::OAPISchemas::ComputerLocalUserAccount>]
        localUserAccounts: {
          class: Jamf::OAPISchemas::ComputerLocalUserAccount,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::OAPISchemas::ComputerCertificate>]
        certificates: {
          class: Jamf::OAPISchemas::ComputerCertificate,
          multi: true
        },

        # @!attribute attachments
        #   @return [Array<Jamf::OAPISchemas::ComputerAttachment>]
        attachments: {
          class: Jamf::OAPISchemas::ComputerAttachment,
          multi: true
        },

        # @!attribute plugins
        #   @return [Array<Jamf::OAPISchemas::ComputerPlugin>]
        plugins: {
          class: Jamf::OAPISchemas::ComputerPlugin,
          multi: true
        },

        # @!attribute packageReceipts
        #   @return [Jamf::OAPISchemas::ComputerPackageReceipts]
        packageReceipts: {
          class: Jamf::OAPISchemas::ComputerPackageReceipts
        },

        # @!attribute fonts
        #   @return [Array<Jamf::OAPISchemas::ComputerFont>]
        fonts: {
          class: Jamf::OAPISchemas::ComputerFont,
          multi: true
        },

        # @!attribute security
        #   @return [Jamf::OAPISchemas::ComputerSecurity]
        security: {
          class: Jamf::OAPISchemas::ComputerSecurity
        },

        # @!attribute operatingSystem
        #   @return [Jamf::OAPISchemas::ComputerOperatingSystem]
        operatingSystem: {
          class: Jamf::OAPISchemas::ComputerOperatingSystem
        },

        # @!attribute licensedSoftware
        #   @return [Array<Jamf::OAPISchemas::ComputerLicensedSoftware>]
        licensedSoftware: {
          class: Jamf::OAPISchemas::ComputerLicensedSoftware,
          multi: true
        },

        # @!attribute ibeacons
        #   @return [Array<Jamf::OAPISchemas::ComputerIbeacon>]
        ibeacons: {
          class: Jamf::OAPISchemas::ComputerIbeacon,
          multi: true
        },

        # @!attribute softwareUpdates
        #   @return [Array<Jamf::OAPISchemas::ComputerSoftwareUpdate>]
        softwareUpdates: {
          class: Jamf::OAPISchemas::ComputerSoftwareUpdate,
          multi: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPISchemas::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::ComputerExtensionAttribute,
          multi: true
        },

        # @!attribute contentCaching
        #   @return [Jamf::OAPISchemas::ComputerContentCaching]
        contentCaching: {
          class: Jamf::OAPISchemas::ComputerContentCaching
        },

        # @!attribute groupMemberships
        #   @return [Array<Jamf::OAPISchemas::GroupMembership>]
        groupMemberships: {
          class: Jamf::OAPISchemas::GroupMembership,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerInventoryResponse

  end # module OAPISchemas

end # module Jamf
