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

    # OAPI Object Model and Enums for: ComputerLocalUserAccount
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.9.2-t1726753918
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
    #  - Jamf::OAPISchemas::ComputerInventory
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
    class ComputerLocalUserAccount < Jamf::OAPIObject

      # Enums used by this class or others

      USER_ACCOUNT_TYPE_OPTIONS = %w[
        LOCAL
        MOBILE
        UNKNOWN
      ]

      AZURE_ACTIVE_DIRECTORY_ID_OPTIONS = %w[
        ACTIVATED
        DEACTIVATED
        UNRESPONSIVE
        UNKNOWN
      ]

      OAPI_PROPERTIES = {

        # @!attribute uid
        #   @return [String]
        uid: {
          class: :string
        },

        # @!attribute [r] userGuid
        #   @return [String]
        userGuid: {
          class: :string,
          readonly: true
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute fullName
        #   @return [String]
        fullName: {
          class: :string
        },

        # @!attribute admin
        #   @return [Boolean]
        admin: {
          class: :boolean
        },

        # @!attribute homeDirectory
        #   @return [String]
        homeDirectory: {
          class: :string
        },

        # Home directory size in MB.
        # @!attribute [r] homeDirectorySizeMb
        #   @return [Integer]
        homeDirectorySizeMb: {
          class: :integer,
          format: 'int64',
          readonly: true
        },

        # @!attribute fileVault2Enabled
        #   @return [Boolean]
        fileVault2Enabled: {
          class: :boolean
        },

        # @!attribute userAccountType
        #   @return [String]
        userAccountType: {
          class: :string,
          enum: USER_ACCOUNT_TYPE_OPTIONS
        },

        # @!attribute passwordMinLength
        #   @return [Integer]
        passwordMinLength: {
          class: :integer
        },

        # @!attribute passwordMaxAge
        #   @return [Integer]
        passwordMaxAge: {
          class: :integer
        },

        # @!attribute passwordMinComplexCharacters
        #   @return [Integer]
        passwordMinComplexCharacters: {
          class: :integer
        },

        # @!attribute passwordHistoryDepth
        #   @return [Integer]
        passwordHistoryDepth: {
          class: :integer
        },

        # @!attribute passwordRequireAlphanumeric
        #   @return [Boolean]
        passwordRequireAlphanumeric: {
          class: :boolean
        },

        # @!attribute computerAzureActiveDirectoryId
        #   @return [String]
        computerAzureActiveDirectoryId: {
          class: :string
        },

        # @!attribute userAzureActiveDirectoryId
        #   @return [String]
        userAzureActiveDirectoryId: {
          class: :string
        },

        # @!attribute azureActiveDirectoryId
        #   @return [String]
        azureActiveDirectoryId: {
          class: :string,
          enum: AZURE_ACTIVE_DIRECTORY_ID_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class ComputerLocalUserAccount

  end # module OAPISchemas

end # module Jamf
