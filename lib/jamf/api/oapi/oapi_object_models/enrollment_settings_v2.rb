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

    # API Object Model and Enums for: EnrollmentSettingsV2
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::CertificateIdentityV2
    #  - OAPIObjectModels::CertificateIdentityV2
    #  - OAPIObjectModels::CertificateDetails
    #  - OAPIObjectModels::CertificateDetails
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/enrollment:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v2/enrollment:PUT', needs permissions: Update User-Initiated Enrollment
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::EnrollmentSettingsV2
    #
    module EnrollmentSettingsV2

      # These enums are used in the properties below

      FLUSH_MDM_COMMANDS_ON_REENROLL_OPTIONS = [
        'DELETE_NOTHING',
        'DELETE_ERRORS',
        'DELETE_EVERYTHING_EXCEPT_ACKNOWLEDGED',
        'DELETE_EVERYTHING'
      ]

      PASSWORD_TYPE_OPTIONS = [
        'STATIC',
        'RANDOM'
      ]

      PERSONAL_DEVICE_ENROLLMENT_TYPE_OPTIONS = [
        'USERENROLLMENT',
        'PERSONALDEVICEPROFILES'
      ]

      OAPI_PROPERTIES = {

        # @!attribute installSingleProfile
        #   @return [Boolean]
        installSingleProfile: {
          class: :boolean
        },

        # @!attribute signingMdmProfileEnabled
        #   @return [Boolean]
        signingMdmProfileEnabled: {
          class: :boolean
        },

        # @!attribute mdmSigningCertificate
        #   @return [Jamf::CertificateIdentityV2]
        mdmSigningCertificate: {
          class: Jamf::CertificateIdentityV2
        },

        # @!attribute restrictReenrollment
        #   @return [Boolean]
        restrictReenrollment: {
          class: :boolean
        },

        # @!attribute flushLocationInformation
        #   @return [Boolean]
        flushLocationInformation: {
          class: :boolean
        },

        # @!attribute flushLocationHistoryInformation
        #   @return [Boolean]
        flushLocationHistoryInformation: {
          class: :boolean
        },

        # @!attribute flushPolicyHistory
        #   @return [Boolean]
        flushPolicyHistory: {
          class: :boolean
        },

        # @!attribute flushExtensionAttributes
        #   @return [Boolean]
        flushExtensionAttributes: {
          class: :boolean
        },

        # @!attribute flushMdmCommandsOnReenroll
        #   @return [String]
        flushMdmCommandsOnReenroll: {
          class: :string,
          enum: FLUSH_MDM_COMMANDS_ON_REENROLL_OPTIONS
        },

        # @!attribute macOsEnterpriseEnrollmentEnabled
        #   @return [Boolean]
        macOsEnterpriseEnrollmentEnabled: {
          class: :boolean
        },

        # @!attribute managementUsername
        #   @return [String]
        managementUsername: {
          class: :string,
          required: true
        },

        # @!attribute managementPassword
        #   @return [String]
        managementPassword: {
          class: :string
        },

        # @!attribute [r] managementPasswordSet
        #   @return [Boolean]
        managementPasswordSet: {
          class: :boolean,
          readonly: true
        },

        # @!attribute passwordType
        #   @return [String]
        passwordType: {
          class: :string,
          enum: PASSWORD_TYPE_OPTIONS
        },

        # @!attribute randomPasswordLength
        #   @return [Integer]
        randomPasswordLength: {
          class: :integer
        },

        # @!attribute createManagementAccount
        #   @return [Boolean]
        createManagementAccount: {
          class: :boolean
        },

        # @!attribute hideManagementAccount
        #   @return [Boolean]
        hideManagementAccount: {
          class: :boolean
        },

        # @!attribute allowSshOnlyManagementAccount
        #   @return [Boolean]
        allowSshOnlyManagementAccount: {
          class: :boolean
        },

        # @!attribute ensureSshRunning
        #   @return [Boolean]
        ensureSshRunning: {
          class: :boolean
        },

        # @!attribute launchSelfService
        #   @return [Boolean]
        launchSelfService: {
          class: :boolean
        },

        # @!attribute signQuickAdd
        #   @return [Boolean]
        signQuickAdd: {
          class: :boolean
        },

        # @!attribute developerCertificateIdentity
        #   @return [Jamf::CertificateIdentityV2]
        developerCertificateIdentity: {
          class: Jamf::CertificateIdentityV2
        },

        # @!attribute developerCertificateIdentityDetails
        #   @return [Jamf::CertificateDetails]
        developerCertificateIdentityDetails: {
          class: Jamf::CertificateDetails
        },

        # @!attribute mdmSigningCertificateDetails
        #   @return [Jamf::CertificateDetails]
        mdmSigningCertificateDetails: {
          class: Jamf::CertificateDetails
        },

        # @!attribute iosEnterpriseEnrollmentEnabled
        #   @return [Boolean]
        iosEnterpriseEnrollmentEnabled: {
          class: :boolean
        },

        # @!attribute iosPersonalEnrollmentEnabled
        #   @return [Boolean]
        iosPersonalEnrollmentEnabled: {
          class: :boolean
        },

        # @!attribute personalDeviceEnrollmentType
        #   @return [String]
        personalDeviceEnrollmentType: {
          class: :string,
          enum: PERSONAL_DEVICE_ENROLLMENT_TYPE_OPTIONS
        },

        # @!attribute accountDrivenUserEnrollmentEnabled
        #   @return [Boolean]
        accountDrivenUserEnrollmentEnabled: {
          class: :boolean
        }

      } # end OAPI_PROPERTIES

    end # module EnrollmentSettingsV2

  end # module OAPIObjectModels

end # module Jamf
