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

    # API Object Model and Enums for: EnrollmentSettings
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
    #  - OAPIObjectModels::MdmSigningCertificate
    #  - OAPIObjectModels::CertificateIdentityV1
    #  - OAPIObjectModels::CertificateDetails
    #  - OAPIObjectModels::CertificateDetails
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/enrollment:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v1/enrollment:PUT', needs permissions: Update User-Initiated Enrollment
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::EnrollmentSettings
    #
    module EnrollmentSettings

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

        # @!attribute isInstallSingleProfile
        #   @return [Boolean]
        isInstallSingleProfile: {
          class: :boolean
        },

        # @!attribute isSigningMdmProfileEnabled
        #   @return [Boolean]
        isSigningMdmProfileEnabled: {
          class: :boolean
        },

        # @!attribute mdmSigningCertificate
        #   @return [Jamf::MdmSigningCertificate]
        mdmSigningCertificate: {
          class: Jamf::MdmSigningCertificate
        },

        # @!attribute isRestrictReenrollment
        #   @return [Boolean]
        isRestrictReenrollment: {
          class: :boolean
        },

        # @!attribute isFlushLocationInformation
        #   @return [Boolean]
        isFlushLocationInformation: {
          class: :boolean
        },

        # @!attribute isFlushLocationHistoryInformation
        #   @return [Boolean]
        isFlushLocationHistoryInformation: {
          class: :boolean
        },

        # @!attribute isFlushPolicyHistory
        #   @return [Boolean]
        isFlushPolicyHistory: {
          class: :boolean
        },

        # @!attribute isFlushExtensionAttributes
        #   @return [Boolean]
        isFlushExtensionAttributes: {
          class: :boolean
        },

        # @!attribute flushMdmCommandsOnReenroll
        #   @return [String]
        flushMdmCommandsOnReenroll: {
          class: :string,
          required: true,
          enum: FLUSH_MDM_COMMANDS_ON_REENROLL_OPTIONS
        },

        # @!attribute isEnabledMacosEnterpriseEnrollment
        #   @return [Boolean]
        isEnabledMacosEnterpriseEnrollment: {
          class: :boolean,
          required: true
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

        # @!attribute passwordType
        #   @return [String]
        passwordType: {
          class: :string,
          required: true,
          enum: PASSWORD_TYPE_OPTIONS
        },

        # @!attribute randomPasswordLength
        #   @return [Integer]
        randomPasswordLength: {
          class: :integer
        },

        # @!attribute isCreateManagementAccount
        #   @return [Boolean]
        isCreateManagementAccount: {
          class: :boolean
        },

        # @!attribute isHideManagementAccount
        #   @return [Boolean]
        isHideManagementAccount: {
          class: :boolean
        },

        # @!attribute isAllowSshOnlyManagementAccount
        #   @return [Boolean]
        isAllowSshOnlyManagementAccount: {
          class: :boolean
        },

        # @!attribute isEnsureSshRunning
        #   @return [Boolean]
        isEnsureSshRunning: {
          class: :boolean
        },

        # @!attribute isLaunchSelfService
        #   @return [Boolean]
        isLaunchSelfService: {
          class: :boolean
        },

        # @!attribute isSignQuickAdd
        #   @return [Boolean]
        isSignQuickAdd: {
          class: :boolean
        },

        # @!attribute developerCertificateIdentity
        #   @return [Jamf::CertificateIdentityV1]
        developerCertificateIdentity: {
          class: Jamf::CertificateIdentityV1
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

        # @!attribute isEnableIosEnterpriseEnrollment
        #   @return [Boolean]
        isEnableIosEnterpriseEnrollment: {
          class: :boolean
        },

        # @!attribute isEnableIosPersonalEnrollment
        #   @return [Boolean]
        isEnableIosPersonalEnrollment: {
          class: :boolean
        },

        # @!attribute personalDeviceEnrollmentType
        #   @return [String]
        personalDeviceEnrollmentType: {
          class: :string,
          required: true,
          enum: PERSONAL_DEVICE_ENROLLMENT_TYPE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # module EnrollmentSettings

  end # module OAPIObjectModels

end # module Jamf
