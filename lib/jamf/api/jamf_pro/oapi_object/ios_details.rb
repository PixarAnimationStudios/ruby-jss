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


    # OAPI Object Model and Enums for: IosDetails
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
    #  - Jamf::OAPIObject::MobileDeviceDetails
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::IdAndName
    #  - Jamf::OAPIObject::Purchasing
    #  - Jamf::OAPIObject::Security
    #  - Jamf::OAPIObject::Network
    #  - Jamf::OAPIObject::MobileDeviceApplication
    #  - Jamf::OAPIObject::MobileDeviceCertificateV1
    #  - Jamf::OAPIObject::MobileDeviceEbook
    #  - Jamf::OAPIObject::ConfigurationProfile
    #  - Jamf::OAPIObject::ProvisioningProfile
    #  - Jamf::OAPIObject::MobileDeviceAttachment
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class IosDetails < OAPIObject

      

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
          class: Jamf::Timestamp,
          format: 'date-time'
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
          class: Jamf::Timestamp,
          format: 'date-time'
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
        #   @return [Jamf::OAPIObject::IdAndName]
        computer: {
          class: Jamf::OAPIObject::IdAndName
        },

        # @!attribute purchasing
        #   @return [Jamf::OAPIObject::Purchasing]
        purchasing: {
          class: Jamf::OAPIObject::Purchasing
        },

        # @!attribute security
        #   @return [Jamf::OAPIObject::Security]
        security: {
          class: Jamf::OAPIObject::Security
        },

        # @!attribute network
        #   @return [Jamf::OAPIObject::Network]
        network: {
          class: Jamf::OAPIObject::Network
        },

        # @!attribute applications
        #   @return [Array<Jamf::OAPIObject::MobileDeviceApplication>]
        applications: {
          class: Jamf::OAPIObject::MobileDeviceApplication,
          multi: true
        },

        # @!attribute certificates
        #   @return [Array<Jamf::OAPIObject::MobileDeviceCertificateV1>]
        certificates: {
          class: Jamf::OAPIObject::MobileDeviceCertificateV1,
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
        #   @return [Array<Jamf::OAPIObject::MobileDeviceAttachment>]
        attachments: {
          class: Jamf::OAPIObject::MobileDeviceAttachment,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class IosDetails

  end # class OAPIObject

end # module Jamf
