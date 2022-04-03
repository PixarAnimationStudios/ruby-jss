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


    # OAPI Object Model and Enums for: DeviceEnrollmentPrestageV2
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
    #  - Jamf::OAPIObject::LocationInformationV2
    #  - Jamf::OAPIObject::PrestagePurchasingInformationV2
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class DeviceEnrollmentPrestageV2 < OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute displayName
        #   @return [String]
        displayName: {
          class: :string,
          required: true
        },

        # @!attribute mandatory
        #   @return [Boolean]
        mandatory: {
          class: :boolean,
          required: true
        },

        # @!attribute mdmRemovable
        #   @return [Boolean]
        mdmRemovable: {
          class: :boolean,
          required: true
        },

        # @!attribute supportPhoneNumber
        #   @return [String]
        supportPhoneNumber: {
          class: :string,
          required: true
        },

        # @!attribute supportEmailAddress
        #   @return [String]
        supportEmailAddress: {
          class: :string,
          required: true
        },

        # @!attribute department
        #   @return [String]
        department: {
          class: :string,
          required: true
        },

        # @!attribute defaultPrestage
        #   @return [Boolean]
        defaultPrestage: {
          class: :boolean,
          required: true
        },

        # @!attribute enrollmentSiteId
        #   @return [String]
        enrollmentSiteId: {
          class: :string,
          required: true
        },

        # @!attribute keepExistingSiteMembership
        #   @return [Boolean]
        keepExistingSiteMembership: {
          class: :boolean,
          required: true
        },

        # @!attribute keepExistingLocationInformation
        #   @return [Boolean]
        keepExistingLocationInformation: {
          class: :boolean,
          required: true
        },

        # @!attribute requireAuthentication
        #   @return [Boolean]
        requireAuthentication: {
          class: :boolean,
          required: true
        },

        # @!attribute authenticationPrompt
        #   @return [String]
        authenticationPrompt: {
          class: :string,
          required: true
        },

        # @!attribute preventActivationLock
        #   @return [Boolean]
        preventActivationLock: {
          class: :boolean,
          required: true
        },

        # @!attribute enableDeviceBasedActivationLock
        #   @return [Boolean]
        enableDeviceBasedActivationLock: {
          class: :boolean,
          required: true
        },

        # @!attribute deviceEnrollmentProgramInstanceId
        #   @return [String]
        deviceEnrollmentProgramInstanceId: {
          class: :string,
          required: true
        },

        # @!attribute skipSetupItems
        #   @return [Hash{Symbol: Boolean }]
        skipSetupItems: {
          class: :hash
        },

        # @!attribute locationInformation
        #   @return [Hash{Symbol: Object}]
        locationInformation: {
          class: :hash,
          required: true
        },

        # @!attribute purchasingInformation
        #   @return [Hash{Symbol: Object}]
        purchasingInformation: {
          class: :hash,
          required: true
        },

        # The Base64 encoded PEM Certificate
        # @!attribute anchorCertificates
        #   @return [Array<String>]
        anchorCertificates: {
          class: :string,
          multi: true
        },

        # @!attribute enrollmentCustomizationId
        #   @return [String]
        enrollmentCustomizationId: {
          class: :string
        },

        # @!attribute language
        #   @return [String]
        language: {
          class: :string
        },

        # @!attribute region
        #   @return [String]
        region: {
          class: :string
        },

        # @!attribute autoAdvanceSetup
        #   @return [Boolean]
        autoAdvanceSetup: {
          class: :boolean,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class DeviceEnrollmentPrestageV2

  end # class OAPIObject

end # module Jamf
