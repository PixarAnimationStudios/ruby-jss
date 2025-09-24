# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: DeviceEnrollmentPrestageV2
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
    #  - Jamf::OAPISchemas::LocationInformationV2
    #  - Jamf::OAPISchemas::PrestagePurchasingInformationV2
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class DeviceEnrollmentPrestageV2 < Jamf::OAPIObject

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
        #   @return [Jamf::OAPISchemas::LocationInformationV2]
        locationInformation: {
          class: Jamf::OAPISchemas::LocationInformationV2,
          required: true
        },

        # @!attribute purchasingInformation
        #   @return [Jamf::OAPISchemas::PrestagePurchasingInformationV2]
        purchasingInformation: {
          class: Jamf::OAPISchemas::PrestagePurchasingInformationV2,
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

  end # module OAPISchemas

end # module Jamf
