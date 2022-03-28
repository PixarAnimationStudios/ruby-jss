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

    # API Object Model and Enums for: ComputerHardware
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
    #  - OAPIObjectModels::ComputerExtensionAttribute
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
    #   include Jamf::OAPIObjectModels::ComputerHardware
    #
    module ComputerHardware

      # These enums are used in the properties below

      

      OAPI_PROPERTIES = {

        # @!attribute [r] make
        #   @return [String]
        make: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] model
        #   @return [String]
        model: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] modelIdentifier
        #   @return [String]
        modelIdentifier: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] serialNumber
        #   @return [String]
        serialNumber: {
          class: :string,
          readonly: true
        },

        # Processor Speed in MHz.
        # @!attribute [r] processorSpeedMhz
        #   @return [Integer]
        processorSpeedMhz: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] processorCount
        #   @return [Integer]
        processorCount: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] coreCount
        #   @return [Integer]
        coreCount: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] processorType
        #   @return [String]
        processorType: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] processorArchitecture
        #   @return [String]
        processorArchitecture: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] busSpeedMhz
        #   @return [Integer]
        busSpeedMhz: {
          class: :integer,
          readonly: true
        },

        # Cache Size in KB.
        # @!attribute [r] cacheSizeKilobytes
        #   @return [Integer]
        cacheSizeKilobytes: {
          class: :integer,
          readonly: true
        },

        # @!attribute networkAdapterType
        #   @return [String]
        networkAdapterType: {
          class: :string
        },

        # @!attribute macAddress
        #   @return [String]
        macAddress: {
          class: :string
        },

        # @!attribute altNetworkAdapterType
        #   @return [String]
        altNetworkAdapterType: {
          class: :string
        },

        # @!attribute altMacAddress
        #   @return [String]
        altMacAddress: {
          class: :string
        },

        # Total RAM Size in MB.
        # @!attribute [r] totalRamMegabytes
        #   @return [Integer]
        totalRamMegabytes: {
          class: :integer,
          readonly: true
        },

        # Available RAM slots.
        # @!attribute [r] openRamSlots
        #   @return [Integer]
        openRamSlots: {
          class: :integer,
          readonly: true
        },

        # Remaining percentage of battery power.
        # @!attribute [r] batteryCapacityPercent
        #   @return [Integer]
        batteryCapacityPercent: {
          class: :integer,
          readonly: true
        },

        # @!attribute [r] smcVersion
        #   @return [String]
        smcVersion: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] nicSpeed
        #   @return [String]
        nicSpeed: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] opticalDrive
        #   @return [String]
        opticalDrive: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] bootRom
        #   @return [String]
        bootRom: {
          class: :string,
          readonly: true
        },

        # @!attribute [r] bleCapable
        #   @return [Boolean]
        bleCapable: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] supportsIosAppInstalls
        #   @return [Boolean]
        supportsIosAppInstalls: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] appleSilicon
        #   @return [Boolean]
        appleSilicon: {
          class: :boolean,
          readonly: true
        },

        # @!attribute extensionAttributes
        #   @return [Array<Jamf::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::ComputerExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # module ComputerHardware

  end # module OAPIObjectModels

end # module Jamf
