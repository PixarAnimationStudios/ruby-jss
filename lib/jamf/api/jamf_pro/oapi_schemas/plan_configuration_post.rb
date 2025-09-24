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

    # OAPI Object Model and Enums for: PlanConfigurationPost
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.14.1-t1740408745756
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
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdatePlanGroupPost
    #  - Jamf::OAPISchemas::ManagedSoftwareUpdatePlanPost
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class PlanConfigurationPost < Jamf::OAPIObject

      # Enums used by this class or others

      UPDATE_ACTION_OPTIONS = %w[
        DOWNLOAD_ONLY
        DOWNLOAD_INSTALL
        DOWNLOAD_INSTALL_ALLOW_DEFERRAL
        DOWNLOAD_INSTALL_RESTART
        DOWNLOAD_INSTALL_SCHEDULE
        UNKNOWN
      ]

      VERSION_TYPE_OPTIONS = %w[
        LATEST_MAJOR
        LATEST_MINOR
        LATEST_ANY
        SPECIFIC_VERSION
        CUSTOM_VERSION
        UNKNOWN
      ]

      OAPI_PROPERTIES = {

        # @!attribute updateAction
        #   @return [String]
        updateAction: {
          class: :string,
          required: true,
          enum: UPDATE_ACTION_OPTIONS
        },

        # @!attribute versionType
        #   @return [String]
        versionType: {
          class: :string,
          required: true,
          enum: VERSION_TYPE_OPTIONS
        },

        # Optional. Indicates the specific version to update to. Only available when the version type is set to specific version or custom version, otherwise defaults to NO_SPECIFIC_VERSION.
        # @!attribute specificVersion
        #   @return [String]
        specificVersion: {
          class: :string,
          min_length: 0
        },

        # Optional. Indicates the build version to update to. Only available when the version type is set to custom version.
        # @!attribute buildVersion
        #   @return [String]
        buildVersion: {
          class: :string,
          nil_ok: true
        },

        # Required when the provided updateAction is DOWNLOAD_INSTALL_ALLOW_DEFERRAL, not applicable to all managed software update plans
        # @!attribute maxDeferrals
        #   @return [Integer]
        maxDeferrals: {
          class: :integer,
          minimum: 0
        },

        # Optional. Indicates the local date and time of the device to force update by.
        # @!attribute forceInstallLocalDateTime
        #   @return [String]
        forceInstallLocalDateTime: {
          class: Jamf::Timestamp,
          nil_ok: true
        }

      } # end OAPI_PROPERTIES

    end # class PlanConfigurationPost

  end # module OAPISchemas

end # module Jamf
