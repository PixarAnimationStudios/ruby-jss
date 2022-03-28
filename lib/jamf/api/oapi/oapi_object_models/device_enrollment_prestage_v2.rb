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

    # API Object Model and Enums for: DeviceEnrollmentPrestageV2
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
    #  - OAPIObjectModels::LocationInformationV2
    #  - OAPIObjectModels::PrestagePurchasingInformationV2
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::DeviceEnrollmentPrestageV2
    #
    module DeviceEnrollmentPrestageV2

      # These enums are used in the properties below

      

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
        #   @return [Jamf::LocationInformationV2]
        locationInformation: {
          class: Jamf::LocationInformationV2,
          required: true
        },

        # @!attribute purchasingInformation
        #   @return [Jamf::PrestagePurchasingInformationV2]
        purchasingInformation: {
          class: Jamf::PrestagePurchasingInformationV2,
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

    end # module DeviceEnrollmentPrestageV2

  end # module OAPIObjectModels

end # module Jamf
