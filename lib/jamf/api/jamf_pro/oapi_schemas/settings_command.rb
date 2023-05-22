# Copyright 2023 Pixar
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


    # OAPI Object Model and Enums for: SettingsCommand
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.46.0-t1681398190
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::AppAnalyticsSetting
    #  - Jamf::OAPISchemas::DiagnosticSubmissionSetting
    #  - Jamf::OAPISchemas::DataRoamingSetting
    #  - Jamf::OAPISchemas::VoiceRoamingSetting
    #  - Jamf::OAPISchemas::PersonalHotspotSetting
    #  - Jamf::OAPISchemas::ApplicationAttributes
    #  - Jamf::OAPISchemas::SharedDeviceConfiguration
    #  - Jamf::OAPISchemas::ApplicationConfiguration
    #  - Jamf::OAPISchemas::SoftwareUpdateSettings
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class SettingsCommand < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute bootstrapTokenAllowed
        #   @return [Boolean]
        bootstrapTokenAllowed: {
          class: :boolean
        },

        # @!attribute bluetooth
        #   @return [Boolean]
        bluetooth: {
          class: :boolean
        },

        # @!attribute appAnalytics
        #   @return [Jamf::OAPISchemas::AppAnalyticsSetting]
        appAnalytics: {
          class: Jamf::OAPISchemas::AppAnalyticsSetting
        },

        # @!attribute diagnosticSubmission
        #   @return [Jamf::OAPISchemas::DiagnosticSubmissionSetting]
        diagnosticSubmission: {
          class: Jamf::OAPISchemas::DiagnosticSubmissionSetting
        },

        # @!attribute dataRoaming
        #   @return [Jamf::OAPISchemas::DataRoamingSetting]
        dataRoaming: {
          class: Jamf::OAPISchemas::DataRoamingSetting
        },

        # @!attribute voiceRoaming
        #   @return [Jamf::OAPISchemas::VoiceRoamingSetting]
        voiceRoaming: {
          class: Jamf::OAPISchemas::VoiceRoamingSetting
        },

        # @!attribute personalHotspot
        #   @return [Jamf::OAPISchemas::PersonalHotspotSetting]
        personalHotspot: {
          class: Jamf::OAPISchemas::PersonalHotspotSetting
        },

        # @!attribute maximumResidentUsers
        #   @return [Integer]
        maximumResidentUsers: {
          class: :integer
        },

        # @!attribute deviceName
        #   @return [String]
        deviceName: {
          class: :string
        },

        # @!attribute applicationAttributes
        #   @return [Jamf::OAPISchemas::ApplicationAttributes]
        applicationAttributes: {
          class: Jamf::OAPISchemas::ApplicationAttributes
        },

        # @!attribute sharedDeviceConfiguration
        #   @return [Jamf::OAPISchemas::SharedDeviceConfiguration]
        sharedDeviceConfiguration: {
          class: Jamf::OAPISchemas::SharedDeviceConfiguration
        },

        # @!attribute applicationConfiguration
        #   @return [Jamf::OAPISchemas::ApplicationConfiguration]
        applicationConfiguration: {
          class: Jamf::OAPISchemas::ApplicationConfiguration
        },

        # @!attribute timeZone
        #   @return [String]
        timeZone: {
          class: :string
        },

        # @!attribute softwareUpdateSettings
        #   @return [Jamf::OAPISchemas::SoftwareUpdateSettings]
        softwareUpdateSettings: {
          class: Jamf::OAPISchemas::SoftwareUpdateSettings
        },

        # The number of seconds before a locked screen requires the user to enter the device passcode to unlock it. (Shared iPad Only)
        # @!attribute passcodeLockGracePeriod
        #   @return [Integer]
        passcodeLockGracePeriod: {
          class: :integer
        }

      } # end OAPI_PROPERTIES

    end # class SettingsCommand

  end # module OAPISchemas

end # module Jamf
