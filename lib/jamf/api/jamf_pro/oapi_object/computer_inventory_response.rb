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

  # This class is the superclass AND the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  class OAPIObject


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
    #  - Jamf::OAPIObject::ComputerInventorySearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::ComputerGeneral
    #  - Jamf::OAPIObject::ComputerDiskEncryption
    #  - Jamf::OAPIObject::ComputerPurchase
    #  - Jamf::OAPIObject::ComputerApplication
    #  - Jamf::OAPIObject::ComputerStorage
    #  - Jamf::OAPIObject::ComputerUserAndLocation
    #  - Jamf::OAPIObject::ComputerConfigurationProfile
    #  - Jamf::OAPIObject::ComputerPrinter
    #  - Jamf::OAPIObject::ComputerService
    #  - Jamf::OAPIObject::ComputerHardware
    #  - Jamf::OAPIObject::ComputerLocalUserAccount
    #  - Jamf::OAPIObject::ComputerCertificate
    #  - Jamf::OAPIObject::ComputerAttachment
    #  - Jamf::OAPIObject::ComputerPlugin
    #  - Jamf::OAPIObject::ComputerPackageReceipts
    #  - Jamf::OAPIObject::ComputerFont
    #  - Jamf::OAPIObject::ComputerSecurity
    #  - Jamf::OAPIObject::ComputerOperatingSystem
    #  - Jamf::OAPIObject::ComputerLicensedSoftware
    #  - Jamf::OAPIObject::ComputerIbeacon
    #  - Jamf::OAPIObject::ComputerSoftwareUpdate
    #  - Jamf::OAPIObject::ComputerExtensionAttribute
    #  - Jamf::OAPIObject::ComputerContentCaching
    #  - Jamf::OAPIObject::GroupMembership
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
    class ComputerInventoryResponse < OAPIObject

      

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
        #   @return [Jamf::OAPIObject::ComputerGeneral]
        general: {
          class: Jamf::OAPIObject::ComputerGeneral
        },

        # @!attribute diskEncryption
        #   @return [Jamf::OAPIObject::ComputerDiskEncryption]
        diskEncryption: {
          class: Jamf::OAPIObject::ComputerDiskEncryption
        },

        # @!attribute purchasing
        #   @return [Jamf::OAPIObject::ComputerPurchase]
        purchasing: {
          class: Jamf::OAPIObject::ComputerPurchase
        },

        # @!attribute applications
        #   @return [Array<Jamf::OAPIObject::ComputerApplication>]
        applications: {
          class: Jamf::OAPIObject::ComputerApplication,
          multi: true
        },

        # @!attribute storage
        #   @return [Jamf::OAPIObject::ComputerStorage]
        storage: {
          class: Jamf::OAPIObject::ComputerStorage
        },

        # @!attribute userAndLocation
        #   @return [Jamf::OAPIObject::ComputerUserAndLocation]
        userAndLocation: {
          class: Jamf::OAPIObject::ComputerUserAndLocation
        },

        # @!attribute configurationProfiles
        #   @return [Array<Jamf::OAPIObject::ComputerConfigurationProfile>]
        configurationProfiles: {
          class: Jamf::OAPIObject::ComputerConfigurationProfile,
          multi: true
        },

        # @!attribute printers
        #   @return [Array<Jamf::OAPIObject::ComputerPrinter>]
        printers: {
          class: Jamf::OAPIObject::ComputerPrinter,
          multi: true
        },

        # @!attribute services
        #   @return [Array<Jamf::OAPIObject::ComputerService>]
        services: {
          class: Jamf::OAPIObject::ComputerService,
          multi: true
        },

        # @!attribute hardware
        #   @return [Jamf::OAPIObject::ComputerHardware]
        hardware: {
          class: Jamf::OAPIObject::ComputerHardware
        },

        # @!attribute localUserAccounts
        #   @return [Array<Jamf::OAPIObject::ComputerLocalUserAccount>]
        localUserAccounts: {
          class: Jamf::OAPIObject::ComputerLocalUserAccount,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::OAPIObject::ComputerCertificate>]
        certificates: {
          class: Jamf::OAPIObject::ComputerCertificate,
          multi: true
        },

        # @!attribute attachments
        #   @return [Array<Jamf::OAPIObject::ComputerAttachment>]
        attachments: {
          class: Jamf::OAPIObject::ComputerAttachment,
          multi: true
        },

        # @!attribute plugins
        #   @return [Array<Jamf::OAPIObject::ComputerPlugin>]
        plugins: {
          class: Jamf::OAPIObject::ComputerPlugin,
          multi: true
        },

        # @!attribute packageReceipts
        #   @return [Jamf::OAPIObject::ComputerPackageReceipts]
        packageReceipts: {
          class: Jamf::OAPIObject::ComputerPackageReceipts
        },

        # @!attribute fonts
        #   @return [Array<Jamf::OAPIObject::ComputerFont>]
        fonts: {
          class: Jamf::OAPIObject::ComputerFont,
          multi: true
        },

        # @!attribute security
        #   @return [Jamf::OAPIObject::ComputerSecurity]
        security: {
          class: Jamf::OAPIObject::ComputerSecurity
        },

        # @!attribute operatingSystem
        #   @return [Jamf::OAPIObject::ComputerOperatingSystem]
        operatingSystem: {
          class: Jamf::OAPIObject::ComputerOperatingSystem
        },

        # @!attribute licensedSoftware
        #   @return [Array<Jamf::OAPIObject::ComputerLicensedSoftware>]
        licensedSoftware: {
          class: Jamf::OAPIObject::ComputerLicensedSoftware,
          multi: true
        },

        # @!attribute ibeacons
        #   @return [Array<Jamf::OAPIObject::ComputerIbeacon>]
        ibeacons: {
          class: Jamf::OAPIObject::ComputerIbeacon,
          multi: true
        },

        # @!attribute softwareUpdates
        #   @return [Array<Jamf::OAPIObject::ComputerSoftwareUpdate>]
        softwareUpdates: {
          class: Jamf::OAPIObject::ComputerSoftwareUpdate,
          multi: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPIObject::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPIObject::ComputerExtensionAttribute,
          multi: true
        },

        # @!attribute contentCaching
        #   @return [Jamf::OAPIObject::ComputerContentCaching]
        contentCaching: {
          class: Jamf::OAPIObject::ComputerContentCaching
        },

        # @!attribute groupMemberships
        #   @return [Array<Jamf::OAPIObject::GroupMembership>]
        groupMemberships: {
          class: Jamf::OAPIObject::GroupMembership,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerInventoryResponse

  end # class OAPIObject

end # module Jamf
