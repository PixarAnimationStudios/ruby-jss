# Copyright 2025 Pixar
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

    # OAPI Object Model and Enums for: EnrollmentSettingsV3
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
    #
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::CertificateIdentityV2
    #  - Jamf::OAPISchemas::CertificateIdentityV2
    #  - Jamf::OAPISchemas::CertificateDetails
    #  - Jamf::OAPISchemas::CertificateDetails
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v3/enrollment:GET' needs permissions:
    #    - Read User-Initiated Enrollment
    #  - '/v3/enrollment:PUT' needs permissions:
    #    - Update User-Initiated Enrollment
    #
    #
    class EnrollmentSettingsV3 < Jamf::OAPIObject

      # Enums used by this class or others

      FLUSH_MDM_COMMANDS_ON_REENROLL_OPTIONS = %w[
        DELETE_NOTHING
        DELETE_ERRORS
        DELETE_EVERYTHING_EXCEPT_ACKNOWLEDGED
        DELETE_EVERYTHING
      ]

      PERSONAL_DEVICE_ENROLLMENT_TYPE_OPTIONS = %w[
        USERENROLLMENT
        PERSONALDEVICEPROFILES
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
        #   @return [Jamf::OAPISchemas::CertificateIdentityV2]
        mdmSigningCertificate: {
          class: Jamf::OAPISchemas::CertificateIdentityV2
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
        #   @return [Jamf::OAPISchemas::CertificateIdentityV2]
        developerCertificateIdentity: {
          class: Jamf::OAPISchemas::CertificateIdentityV2
        },

        # @!attribute developerCertificateIdentityDetails
        #   @return [Jamf::OAPISchemas::CertificateDetails]
        developerCertificateIdentityDetails: {
          class: Jamf::OAPISchemas::CertificateDetails
        },

        # @!attribute mdmSigningCertificateDetails
        #   @return [Jamf::OAPISchemas::CertificateDetails]
        mdmSigningCertificateDetails: {
          class: Jamf::OAPISchemas::CertificateDetails
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
        },

        # @!attribute accountDrivenDeviceEnrollmentEnabled
        #   @return [Boolean]
        accountDrivenDeviceEnrollmentEnabled: {
          class: :boolean
        }

      } # end OAPI_PROPERTIES

    end # class EnrollmentSettingsV3

  end # module OAPISchemas

end # module Jamf
