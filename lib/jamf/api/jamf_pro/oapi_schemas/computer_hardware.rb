# Copyright 2024 Pixar
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


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: ComputerHardware
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
    class ComputerHardware < Jamf::OAPIObject

      

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
          format: 'int64',
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
          format: 'int64',
          readonly: true
        },

        # Cache Size in KB.
        # @!attribute [r] cacheSizeKilobytes
        #   @return [Integer]
        cacheSizeKilobytes: {
          class: :integer,
          format: 'int64',
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
          format: 'int64',
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
          readonly: true,
          minimum: 0,
          maximum: 100
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
        #   @return [Array<Jamf::OAPISchemas::ComputerExtensionAttribute>]
        extensionAttributes: {
          class: Jamf::OAPISchemas::ComputerExtensionAttribute,
          multi: true
        }

      } # end OAPI_PROPERTIES

    end # class ComputerHardware

  end # module OAPISchemas

end # module Jamf
