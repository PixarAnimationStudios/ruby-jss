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

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: ComputerSecurity
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
    #  - Jamf::OAPISchemas::ComputerInventoryResponse
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

    end # class ComputerSecurity

  end # module OAPISchemas

end # module Jamf
