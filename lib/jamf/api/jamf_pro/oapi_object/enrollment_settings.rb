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


    # OAPI Object Model and Enums for: EnrollmentSettings
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
    #  - Jamf::OAPIObject::MdmSigningCertificate
    #  - Jamf::OAPIObject::CertificateIdentityV1
    #  - Jamf::OAPIObject::CertificateDetails
    #  - Jamf::OAPIObject::CertificateDetails
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/enrollment:GET', needs permissions: Read User-Initiated Enrollment
    #  - '/v1/enrollment:PUT', needs permissions: Update User-Initiated Enrollment
    #
    #
    class EnrollmentSettings < OAPIObject

      # Enums used by this class or others

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
        #   @return [Hash{Symbol: Object}]
        mdmSigningCertificate: {
          class: :hash
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
          class: :integer,
          format: 'int32'
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
        #   @return [Hash{Symbol: Object}]
        developerCertificateIdentity: {
          class: :hash
        },

        # @!attribute developerCertificateIdentityDetails
        #   @return [Hash{Symbol: Object}]
        developerCertificateIdentityDetails: {
          class: :hash
        },

        # @!attribute mdmSigningCertificateDetails
        #   @return [Hash{Symbol: Object}]
        mdmSigningCertificateDetails: {
          class: :hash
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

    end # class EnrollmentSettings

  end # class OAPIObject

end # module Jamf
