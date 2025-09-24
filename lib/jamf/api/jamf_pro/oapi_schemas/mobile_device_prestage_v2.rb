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

    # OAPI Object Model and Enums for: MobileDevicePrestageV2
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
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v2/mobile-device-prestages:POST' needs permissions:
    #    - Create Mobile Device PreStage Enrollments
    #
    #
    class MobileDevicePrestageV2 < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute allowPairing
        #   @return [Boolean]
        allowPairing: {
          class: :boolean,
          required: true
        },

        # @!attribute multiUser
        #   @return [Boolean]
        multiUser: {
          class: :boolean,
          required: true
        },

        # @!attribute supervised
        #   @return [Boolean]
        supervised: {
          class: :boolean,
          required: true
        },

        # @!attribute maximumSharedAccounts
        #   @return [Integer]
        maximumSharedAccounts: {
          class: :integer,
          required: true
        },

        # @!attribute configureDeviceBeforeSetupAssistant
        #   @return [Boolean]
        configureDeviceBeforeSetupAssistant: {
          class: :boolean,
          required: true
        },

        # @!attribute names
        #   @return [Jamf::OAPISchemas::MobileDevicePrestageNamesV2]
        names: {
          class: Jamf::OAPISchemas::MobileDevicePrestageNamesV2
        },

        # @!attribute sendTimezone
        #   @return [Boolean]
        sendTimezone: {
          class: :boolean,
          required: true
        },

        # @!attribute timezone
        #   @return [String]
        timezone: {
          class: :string,
          required: true
        },

        # @!attribute storageQuotaSizeMegabytes
        #   @return [Integer]
        storageQuotaSizeMegabytes: {
          class: :integer,
          required: true
        },

        # @!attribute useStorageQuotaSize
        #   @return [Boolean]
        useStorageQuotaSize: {
          class: :boolean,
          required: true
        },

        # @!attribute temporarySessionOnly
        #   @return [Boolean]
        temporarySessionOnly: {
          class: :boolean
        },

        # @!attribute enforceTemporarySessionTimeout
        #   @return [Boolean]
        enforceTemporarySessionTimeout: {
          class: :boolean
        },

        # @!attribute temporarySessionTimeout
        #   @return [Integer]
        temporarySessionTimeout: {
          class: :integer
        },

        # @!attribute enforceUserSessionTimeout
        #   @return [Boolean]
        enforceUserSessionTimeout: {
          class: :boolean
        },

        # @!attribute userSessionTimeout
        #   @return [Integer]
        userSessionTimeout: {
          class: :integer
        }
      }.merge(Jamf::OAPISchemas::DeviceEnrollmentPrestageV2::OAPI_PROPERTIES) # end OAPI_PROPERTIES

    end # class MobileDevicePrestageV2

  end # module OAPISchemas

end # module Jamf
