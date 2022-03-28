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

    # API Object Model and Enums for: ComputerSecurity
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::ComputerInventoryResponse
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
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::ComputerSecurity
    #
    module ComputerSecurity

      # These enums are used in the properties below

      SIP_STATUS_OPTIONS = [
        'NOT_COLLECTED',
        'NOT_AVAILABLE',
        'DISABLED',
        'ENABLED'
      ]

      GATEKEEPER_STATUS_OPTIONS = [
        'NOT_COLLECTED',
        'DISABLED',
        'APP_STORE_AND_IDENTIFIED_DEVELOPERS',
        'APP_STORE'
      ]

      SECURE_BOOT_LEVEL_OPTIONS = [
        'NO_SECURITY',
        'MEDIUM_SECURITY',
        'FULL_SECURITY',
        'NOT_SUPPORTED',
        'UNKNOWN'
      ]

      EXTERNAL_BOOT_LEVEL_OPTIONS = [
        'ALLOW_BOOTING_FROM_EXTERNAL_MEDIA',
        'DISALLOW_BOOTING_FROM_EXTERNAL_MEDIA',
        'NOT_SUPPORTED',
        'UNKNOWN'
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
        }

      } # end OAPI_PROPERTIES

    end # module ComputerSecurity

  end # module OAPIObjectModels

end # module Jamf
