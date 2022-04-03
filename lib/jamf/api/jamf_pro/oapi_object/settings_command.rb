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


    # OAPI Object Model and Enums for: SettingsCommand
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPIObject::AppAnalyticsSetting
    #  - Jamf::OAPIObject::DiagnosticSubmissionSetting
    #  - Jamf::OAPIObject::DataRoamingSetting
    #  - Jamf::OAPIObject::VoiceRoamingSetting
    #  - Jamf::OAPIObject::PersonalHotspotSetting
    #  - Jamf::OAPIObject::ApplicationAttributes
    #  - Jamf::OAPIObject::SharedDeviceConfiguration
    #  - Jamf::OAPIObject::ApplicationConfiguration
    #  - Jamf::OAPIObject::SoftwareUpdateSettings
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class SettingsCommand < OAPIObject

      # Enums used by this class or others

      APP_ANALYTICS_OPTIONS = [
        'ENABLE_APP_ANALYTICS',
        'DISABLE_APP_ANALYTICS'
      ]

      DIAGNOSTIC_SUBMISSION_OPTIONS = [
        'ENABLE_DIAGNOSTIC_SUBMISSION',
        'DISABLE_DIAGNOSTIC_SUBMISSION'
      ]

      DATA_ROAMING_OPTIONS = [
        'ENABLE_DATA_ROAMING',
        'DISABLE_DATA_ROAMING'
      ]

      VOICE_ROAMING_OPTIONS = [
        'ENABLE_VOICE_ROAMING',
        'DISABLE_VOICE_ROAMING'
      ]

      PERSONAL_HOTSPOT_OPTIONS = [
        'ENABLE_PERSONAL_HOTSPOT',
        'DISABLE_PERSONAL_HOTSPOT'
      ]

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
        #   @return [String]
        appAnalytics: {
          class: :string,
          enum: APP_ANALYTICS_OPTIONS
        },

        # @!attribute diagnosticSubmission
        #   @return [String]
        diagnosticSubmission: {
          class: :string,
          enum: DIAGNOSTIC_SUBMISSION_OPTIONS
        },

        # @!attribute dataRoaming
        #   @return [String]
        dataRoaming: {
          class: :string,
          enum: DATA_ROAMING_OPTIONS
        },

        # @!attribute voiceRoaming
        #   @return [String]
        voiceRoaming: {
          class: :string,
          enum: VOICE_ROAMING_OPTIONS
        },

        # @!attribute personalHotspot
        #   @return [String]
        personalHotspot: {
          class: :string,
          enum: PERSONAL_HOTSPOT_OPTIONS
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
        #   @return [Hash{Symbol: Object}]
        applicationAttributes: {
          class: :hash
        },

        # @!attribute sharedDeviceConfiguration
        #   @return [Hash{Symbol: Object}]
        sharedDeviceConfiguration: {
          class: :hash
        },

        # @!attribute applicationConfiguration
        #   @return [Hash{Symbol: Object}]
        applicationConfiguration: {
          class: :hash
        },

        # @!attribute timeZone
        #   @return [String]
        timeZone: {
          class: :string
        },

        # @!attribute softwareUpdateSettings
        #   @return [Hash{Symbol: Object}]
        softwareUpdateSettings: {
          class: :hash
        }

      } # end OAPI_PROPERTIES

    end # class SettingsCommand

  end # class OAPIObject

end # module Jamf
