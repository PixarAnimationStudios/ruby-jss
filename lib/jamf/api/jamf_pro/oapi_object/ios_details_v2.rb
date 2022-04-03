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


    # OAPI Object Model and Enums for: IosDetailsV2
    #
    # Description of this class from the OAPI Schema:
    #   will be populated if the type is ios.
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
    #  - Jamf::OAPIObject::MobileDeviceDetailsV2
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::IdAndNameV2
    #  - Jamf::OAPIObject::PurchasingV2
    #  - Jamf::OAPIObject::SecurityV2
    #  - Jamf::OAPIObject::NetworkV2
    #  - Jamf::OAPIObject::MobileDeviceApplication
    #  - Jamf::OAPIObject::MobileDeviceCertificateV2
    #  - Jamf::OAPIObject::MobileDeviceEbook
    #  - Jamf::OAPIObject::ConfigurationProfile
    #  - Jamf::OAPIObject::ProvisioningProfile
    #  - Jamf::OAPIObject::MobileDeviceAttachmentV2
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class IosDetailsV2 < OAPIObject

      

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
          class: Jamf::Timestamp,
          format: date-time
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
          class: Jamf::Timestamp,
          format: date-time
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
        #   @return [Hash{Symbol: Object}]
        computer: {
          class: :hash
        },

        # @!attribute purchasing
        #   @return [Hash{Symbol: Object}]
        purchasing: {
          class: :hash
        },

        # @!attribute security
        #   @return [Hash{Symbol: Object}]
        security: {
          class: :hash
        },

        # @!attribute network
        #   @return [Hash{Symbol: Object}]
        network: {
          class: :hash
        },

        # @!attribute applications
        #   @return [Array<Jamf::OAPIObject::MobileDeviceApplication>]
        applications: {
          class: Jamf::OAPIObject::MobileDeviceApplication,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::OAPIObject::MobileDeviceCertificateV2>]
        certificates: {
          class: Jamf::OAPIObject::MobileDeviceCertificateV2,
          multi: true
        },

        # @!attribute ebooks
        #   @return [Array<Jamf::OAPIObject::MobileDeviceEbook>]
        ebooks: {
          class: Jamf::OAPIObject::MobileDeviceEbook,
          multi: true
        },

        # @!attribute configurationProfiles
        #   @return [Array<Jamf::OAPIObject::ConfigurationProfile>]
        configurationProfiles: {
          class: Jamf::OAPIObject::ConfigurationProfile,
          multi: true
        },

        # @!attribute provisioningProfiles
        #   @return [Array<Jamf::OAPIObject::ProvisioningProfile>]
        provisioningProfiles: {
          class: Jamf::OAPIObject::ProvisioningProfile,
          multi: true
        },

        # @!attribute attachments
        #   @return [Array<Jamf::OAPIObject::MobileDeviceAttachmentV2>]
        attachments: {
          class: Jamf::OAPIObject::MobileDeviceAttachmentV2,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class IosDetailsV2

  end # class OAPIObject

end # module Jamf
