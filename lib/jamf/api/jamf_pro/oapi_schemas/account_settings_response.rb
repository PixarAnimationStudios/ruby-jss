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

    # OAPI Object Model and Enums for: AccountSettingsResponse
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
    #
    #
    #
    class AccountSettingsResponse < Jamf::OAPIObject

      # Enums used by this class or others

      USER_ACCOUNT_TYPE_OPTIONS = %w[
        ADMINISTRATOR
        STANDARD
        SKIP
      ]

      OAPI_PROPERTIES = {

        # id of Account Settings
        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute payloadConfigured
        #   @return [Boolean]
        payloadConfigured: {
          class: :boolean
        },

        # @!attribute localAdminAccountEnabled
        #   @return [Boolean]
        localAdminAccountEnabled: {
          class: :boolean
        },

        # @!attribute adminUsername
        #   @return [String]
        adminUsername: {
          class: :string,
          min_length: 0
        },

        # @!attribute hiddenAdminAccount
        #   @return [Boolean]
        hiddenAdminAccount: {
          class: :boolean
        },

        # @!attribute localUserManaged
        #   @return [Boolean]
        localUserManaged: {
          class: :boolean
        },

        # @!attribute userAccountType
        #   @return [String]
        userAccountType: {
          class: :string,
          enum: USER_ACCOUNT_TYPE_OPTIONS
        },

        # @!attribute versionLock
        #   @return [Integer]
        versionLock: {
          class: :integer,
          minimum: 0
        },

        # @!attribute prefillPrimaryAccountInfoFeatureEnabled
        #   @return [Boolean]
        prefillPrimaryAccountInfoFeatureEnabled: {
          class: :boolean
        },

        # Values accepted are only CUSTOM and DEVICE_OWNER
        # @!attribute prefillType
        #   @return [String]
        prefillType: {
          class: :string
        },

        # @!attribute prefillAccountFullName
        #   @return [String]
        prefillAccountFullName: {
          class: :string,
          min_length: 0
        },

        # @!attribute prefillAccountUserName
        #   @return [String]
        prefillAccountUserName: {
          class: :string,
          min_length: 0
        },

        # @!attribute preventPrefillInfoFromModification
        #   @return [Boolean]
        preventPrefillInfoFromModification: {
          class: :boolean
        }

      } # end OAPI_PROPERTIES

    end # class AccountSettingsResponse

  end # module OAPISchemas

end # module Jamf
