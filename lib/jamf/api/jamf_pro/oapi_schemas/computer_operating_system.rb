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

    # OAPI Object Model and Enums for: ComputerOperatingSystem
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
    #  - Jamf::OAPISchemas::ComputerExtensionAttribute
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    #
    class ComputerOperatingSystem < Jamf::OAPIObject

      # Enums used by this class or others

      FILE_VAULT2_STATUS_OPTIONS = %w[
        NOT_APPLICABLE
        NOT_ENCRYPTED
        BOOT_ENCRYPTED
        SOME_ENCRYPTED
        ALL_ENCRYPTED
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] name
        #   @return [String]
        name: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] version
        #   @return [String]
        version: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] build
        #   @return [String]
        build: {
          class: :string,
          readonly: true
        },

        # Collected for macOS 13.0 or later
        # @!attribute [r] supplementalBuildVersion
        #   @return [String]
        supplementalBuildVersion: {
          class: :string,
          readonly: true
        },

        # Collected for macOS 13.0 or later
        # @!attribute [r] rapidSecurityResponse
        #   @return [String]
        rapidSecurityResponse: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] activeDirectoryStatus
        #   @return [String]
        activeDirectoryStatus: {
          class: :string,
          readonly: true
        },

        # @!attribute fileVault2Status
        #   @return [String]
        fileVault2Status: {
          class: :string,
          enum: FILE_VAULT2_STATUS_OPTIONS
        },

        # @!attribute [r] softwareUpdateDeviceId
        #   @return [String]
        softwareUpdateDeviceId: {
          class: :string,
          readonly: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::OAPISchemas::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::ComputerExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerOperatingSystem

  end # module OAPISchemas

end # module Jamf
