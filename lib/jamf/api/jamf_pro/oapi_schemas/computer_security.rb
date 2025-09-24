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

    # OAPI Object Model and Enums for: ComputerSecurity
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
    class ComputerSecurity < Jamf::OAPIObject

      # Enums used by this class or others

      SIP_STATUS_OPTIONS = %w[
        NOT_COLLECTED
        NOT_AVAILABLE
        DISABLED
        ENABLED
      ]

      GATEKEEPER_STATUS_OPTIONS = %w[
        NOT_COLLECTED
        DISABLED
        APP_STORE_AND_IDENTIFIED_DEVELOPERS
        APP_STORE
      ]

      SECURE_BOOT_LEVEL_OPTIONS = %w[
        NO_SECURITY
        MEDIUM_SECURITY
        FULL_SECURITY
        NOT_SUPPORTED
        UNKNOWN
      ]

      EXTERNAL_BOOT_LEVEL_OPTIONS = %w[
        ALLOW_BOOTING_FROM_EXTERNAL_MEDIA
        DISALLOW_BOOTING_FROM_EXTERNAL_MEDIA
        NOT_SUPPORTED
        UNKNOWN
      ]

      BOOTSTRAP_TOKEN_ESCROWED_STATUS_OPTIONS = %w[
        ESCROWED
        NOT_ESCROWED
        NOT_SUPPORTED
      ]

      OAPI_PROPERTIES = {

        # @!attribute sipStatus
        #   @return [String]
        sipStatus: {
          class: :string,
          enum: SIP_STATUS_OPTIONS
        },

        # @!attribute gatekeeperStatus
        #   @return [String]
        gatekeeperStatus: {
          class: :string,
          enum: GATEKEEPER_STATUS_OPTIONS
        },

        # @!attribute xprotectVersion
        #   @return [String]
        xprotectVersion: {
          class: :string
        },

        # @!attribute autoLoginDisabled
        #   @return [Boolean]
        autoLoginDisabled: {
          class: :boolean
        },

        # Collected for macOS 10.14.4 or later
        # @!attribute remoteDesktopEnabled
        #   @return [Boolean]
        remoteDesktopEnabled: {
          class: :boolean
        },

        # Collected for macOS 10.15.0 or later
        # @!attribute activationLockEnabled
        #   @return [Boolean]
        activationLockEnabled: {
          class: :boolean
        },

        # @!attribute recoveryLockEnabled
        #   @return [Boolean]
        recoveryLockEnabled: {
          class: :boolean
        },

        # @!attribute firewallEnabled
        #   @return [Boolean]
        firewallEnabled: {
          class: :boolean
        },

        # Collected for macOS 10.15.0 or later
        # @!attribute secureBootLevel
        #   @return [String]
        secureBootLevel: {
          class: :string,
          enum: SECURE_BOOT_LEVEL_OPTIONS
        },

        # Collected for macOS 10.15.0 or later
        # @!attribute externalBootLevel
        #   @return [String]
        externalBootLevel: {
          class: :string,
          enum: EXTERNAL_BOOT_LEVEL_OPTIONS
        },

        # Collected for macOS 11 or later
        # @!attribute bootstrapTokenAllowed
        #   @return [Boolean]
        bootstrapTokenAllowed: {
          class: :boolean
        },

        # Collected for macOS 11 or later
        # @!attribute bootstrapTokenEscrowedStatus
        #   @return [String]
        bootstrapTokenEscrowedStatus: {
          class: :string,
          enum: BOOTSTRAP_TOKEN_ESCROWED_STATUS_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # class ComputerSecurity

  end # module OAPISchemas

end # module Jamf
