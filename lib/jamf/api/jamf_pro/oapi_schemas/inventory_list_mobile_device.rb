# Copyright 2024 Pixar
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


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: InventoryListMobileDevice
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.6.1-t1718634702
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
    #  - Jamf::OAPISchemas::InventoryListMobileDeviceSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class InventoryListMobileDevice < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute mobileDeviceId
        #   @return [String]
        mobileDeviceId: {
          class: :string,
          min_length: 1
        },

        # @!attribute udid
        #   @return [String]
        udid: {
          class: :string
        },

        # @!attribute airPlayPassword
        #   @return [String]
        airPlayPassword: {
          class: :string,
          format: 'password'
        },

        # @!attribute appAnalyticsEnabled
        #   @return [Boolean]
        appAnalyticsEnabled: {
          class: :boolean
        },

        # @!attribute assetTag
        #   @return [String]
        assetTag: {
          class: :string
        },

        # @!attribute availableSpaceMb
        #   @return [Integer]
        availableSpaceMb: {
          class: :integer
        },

        # @!attribute batteryLevel
        #   @return [Integer]
        batteryLevel: {
          class: :integer
        },

        # @!attribute bluetoothLowEnergyCapable
        #   @return [Boolean]
        bluetoothLowEnergyCapable: {
          class: :boolean
        },

        # @!attribute bluetoothMacAddress
        #   @return [String]
        bluetoothMacAddress: {
          class: :string
        },

        # @!attribute capacityMb
        #   @return [Integer]
        capacityMb: {
          class: :integer
        },

        # @!attribute lostModeEnabledDate
        #   @return [Jamf::Timestamp]
        lostModeEnabledDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute declarativeDeviceManagementEnabled
        #   @return [Boolean]
        declarativeDeviceManagementEnabled: {
          class: :boolean
        },

        # @!attribute deviceId
        #   @return [String]
        deviceId: {
          class: :string
        },

        # @!attribute deviceLocatorServiceEnabled
        #   @return [Boolean]
        deviceLocatorServiceEnabled: {
          class: :boolean
        },

        # @!attribute deviceOwnershipType
        #   @return [String]
        deviceOwnershipType: {
          class: :string
        },

        # @!attribute devicePhoneNumber
        #   @return [String]
        devicePhoneNumber: {
          class: :string
        },

        # @!attribute diagnosticAndUsageReportingEnabled
        #   @return [Boolean]
        diagnosticAndUsageReportingEnabled: {
          class: :boolean
        },

        # @!attribute displayName
        #   @return [String]
        displayName: {
          class: :string
        },

        # @!attribute doNotDisturbEnabled
        #   @return [Boolean]
        doNotDisturbEnabled: {
          class: :boolean
        },

        # @!attribute enrollmentSessionTokenValid
        #   @return [Boolean]
        enrollmentSessionTokenValid: {
          class: :boolean
        },

        # @!attribute exchangeDeviceId
        #   @return [String]
        exchangeDeviceId: {
          class: :string
        },

        # @!attribute cloudBackupEnabled
        #   @return [Boolean]
        cloudBackupEnabled: {
          class: :boolean
        },

        # @!attribute osBuild
        #   @return [String]
        osBuild: {
          class: :string
        },

        # @!attribute osSupplementalBuildVersion
        #   @return [String]
        osSupplementalBuildVersion: {
          class: :string
        },

        # @!attribute osRapidSecurityResponse
        #   @return [String]
        osRapidSecurityResponse: {
          class: :string
        },

        # @!attribute osVersion
        #   @return [String]
        osVersion: {
          class: :string
        },

        # @!attribute ipAddress
        #   @return [String]
        ipAddress: {
          class: :string
        },

        # @!attribute itunesStoreAccountActive
        #   @return [Boolean]
        itunesStoreAccountActive: {
          class: :boolean
        },

        # @!attribute jamfParentPairings
        #   @return [Integer]
        jamfParentPairings: {
          class: :integer
        },

        # @!attribute languages
        #   @return [String]
        languages: {
          class: :string
        },

        # @!attribute lastBackupDate
        #   @return [Jamf::Timestamp]
        lastBackupDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute lastEnrolledDate
        #   @return [Jamf::Timestamp]
        lastEnrolledDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute lastCloudBackupDate
        #   @return [Jamf::Timestamp]
        lastCloudBackupDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute lastInventoryUpdateDate
        #   @return [Jamf::Timestamp]
        lastInventoryUpdateDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute locales
        #   @return [String]
        locales: {
          class: :string
        },

        # @!attribute locationServicesForSelfServiceMobileEnabled
        #   @return [Boolean]
        locationServicesForSelfServiceMobileEnabled: {
          class: :boolean
        },

        # @!attribute lostModeEnabled
        #   @return [Boolean]
        lostModeEnabled: {
          class: :boolean
        },

        # @!attribute managed
        #   @return [Boolean]
        managed: {
          class: :boolean
        },

        # @!attribute mdmProfileExpirationDate
        #   @return [Jamf::Timestamp]
        mdmProfileExpirationDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

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

        # @!attribute modemFirmwareVersion
        #   @return [String]
        modemFirmwareVersion: {
          class: :string
        },

        # @!attribute quotaSize
        #   @return [Integer]
        quotaSize: {
          class: :integer
        },

        # @!attribute residentUsers
        #   @return [Integer]
        residentUsers: {
          class: :integer
        },

        # @!attribute serialNumber
        #   @return [String]
        serialNumber: {
          class: :string
        },

        # @!attribute sharedIpad
        #   @return [Boolean]
        sharedIpad: {
          class: :boolean
        },

        # @!attribute supervised
        #   @return [Boolean]
        supervised: {
          class: :boolean
        },

        # @!attribute tethered
        #   @return [Boolean]
        tethered: {
          class: :boolean
        },

        # @!attribute timeZone
        #   @return [String]
        timeZone: {
          class: :string
        },

        # @!attribute usedSpacePercentage
        #   @return [Integer]
        usedSpacePercentage: {
          class: :integer
        },

        # @!attribute wifiMacAddress
        #   @return [String]
        wifiMacAddress: {
          class: :string
        },

        # @!attribute building
        #   @return [String]
        building: {
          class: :string
        },

        # @!attribute department
        #   @return [String]
        department: {
          class: :string
        },

        # @!attribute emailAddress
        #   @return [String]
        emailAddress: {
          class: :string
        },

        # @!attribute fullName
        #   @return [String]
        fullName: {
          class: :string
        },

        # @!attribute position
        #   @return [String]
        position: {
          class: :string
        },

        # @!attribute room
        #   @return [String]
        room: {
          class: :string
        },

        # @!attribute userPhoneNumber
        #   @return [String]
        userPhoneNumber: {
          class: :string
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute appleCareId
        #   @return [String]
        appleCareId: {
          class: :string
        },

        # @!attribute leaseExpirationDate
        #   @return [Jamf::Timestamp]
        leaseExpirationDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute lifeExpectancyYears
        #   @return [Integer]
        lifeExpectancyYears: {
          class: :integer
        },

        # @!attribute poDate
        #   @return [Jamf::Timestamp]
        poDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute poNumber
        #   @return [String]
        poNumber: {
          class: :string
        },

        # @!attribute purchasePrice
        #   @return [String]
        purchasePrice: {
          class: :string
        },

        # @!attribute purchasedOrLeased
        #   @return [Boolean]
        purchasedOrLeased: {
          class: :boolean
        },

        # @!attribute purchasingAccount
        #   @return [String]
        purchasingAccount: {
          class: :string
        },

        # @!attribute purchasingContact
        #   @return [String]
        purchasingContact: {
          class: :string
        },

        # @!attribute vendor
        #   @return [String]
        vendor: {
          class: :string
        },

        # @!attribute warrantyExpirationDate
        #   @return [Jamf::Timestamp]
        warrantyExpirationDate: {
          class: Jamf::Timestamp,
          format: 'date-time'
        },

        # @!attribute activationLockEnabled
        #   @return [Boolean]
        activationLockEnabled: {
          class: :boolean
        },

        # @!attribute blockEncryptionCapable
        #   @return [Boolean]
        blockEncryptionCapable: {
          class: :boolean
        },

        # @!attribute dataProtection
        #   @return [Boolean]
        dataProtection: {
          class: :boolean
        },

        # @!attribute fileEncryptionCapable
        #   @return [Boolean]
        fileEncryptionCapable: {
          class: :boolean
        },

        # @!attribute hardwareEncryptionSupported
        #   @return [Boolean]
        hardwareEncryptionSupported: {
          class: :boolean
        },

        # @!attribute jailbreakStatus
        #   @return [String]
        jailbreakStatus: {
          class: :string
        },

        # @!attribute passcodeCompliant
        #   @return [Boolean]
        passcodeCompliant: {
          class: :boolean
        },

        # @!attribute passcodeCompliantWithProfile
        #   @return [Boolean]
        passcodeCompliantWithProfile: {
          class: :boolean
        },

        # @!attribute passcodeLockGracePeriodEnforcedSeconds
        #   @return [Integer]
        passcodeLockGracePeriodEnforcedSeconds: {
          class: :integer
        },

        # @!attribute passcodePresent
        #   @return [Boolean]
        passcodePresent: {
          class: :boolean
        },

        # @!attribute personalDeviceProfileCurrent
        #   @return [Boolean]
        personalDeviceProfileCurrent: {
          class: :boolean
        },

        # @!attribute carrierSettingsVersion
        #   @return [String]
        carrierSettingsVersion: {
          class: :string
        },

        # @!attribute cellularTechnology
        #   @return [String]
        cellularTechnology: {
          class: :string
        },

        # @!attribute currentCarrierNetwork
        #   @return [String]
        currentCarrierNetwork: {
          class: :string
        },

        # @!attribute currentMobileCountryCode
        #   @return [String]
        currentMobileCountryCode: {
          class: :string
        },

        # @!attribute currentMobileNetworkCode
        #   @return [String]
        currentMobileNetworkCode: {
          class: :string
        },

        # @!attribute dataRoamingEnabled
        #   @return [Boolean]
        dataRoamingEnabled: {
          class: :boolean
        },

        # @!attribute eid
        #   @return [String]
        eid: {
          class: :string
        },

        # @!attribute homeCarrierNetwork
        #   @return [String]
        homeCarrierNetwork: {
          class: :string
        },

        # @!attribute homeMobileCountryCode
        #   @return [String]
        homeMobileCountryCode: {
          class: :string
        },

        # @!attribute homeMobileNetworkCode
        #   @return [String]
        homeMobileNetworkCode: {
          class: :string
        },

        # @!attribute iccid
        #   @return [String]
        iccid: {
          class: :string
        },

        # @!attribute imei
        #   @return [String]
        imei: {
          class: :string
        },

        # @!attribute imei2
        #   @return [String]
        imei2: {
          class: :string
        },

        # @!attribute meid
        #   @return [String]
        meid: {
          class: :string
        },

        # @!attribute personalHotspotEnabled
        #   @return [Boolean]
        personalHotspotEnabled: {
          class: :boolean
        },

        # @!attribute roaming
        #   @return [Boolean]
        roaming: {
          class: :boolean
        },

        # @!attribute voiceRoamingEnabled
        #   @return [String]
        voiceRoamingEnabled: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # class InventoryListMobileDevice

  end # module OAPISchemas

end # module Jamf
