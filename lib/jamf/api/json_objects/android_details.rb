# Copyright 2019 Pixar

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

# The module
module Jamf

  class AndroidDetails < Jamf::JSONObject

    # Class Constants
    #####################################

    OBJECT_MODEL = {

      # @!attribute [r] osName
      #   @return [String]
      osName: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] manufacturer
      #   @return [String]
      manufacturer: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] model
      #   @return [String]
      model: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] internalCapacityMb
      #   @return [Integer]
      internalCapacityMb: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] internalAvailableMb
      #   @return [Integer]
      internalAvailableMb: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] internalPercentUsed
      #   @return [Integer]
      internalPercentUsed: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] externalCapacityMb
      #   @return [Integer]
      externalCapacityMb: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] externalAvailableMb
      #   @return [Integer]
      externalAvailableMb: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] externalPercentUsed
      #   @return [Integer]
      externalPercentUsed: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] batteryLevel
      #   @return [Integer]
      batteryLevel: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] lastBackupTimestamp
      #   @return [Jamf::Timestamp]
      lastBackupTimestamp: {
        class: Jamf::Timestamp,
        readonly: true,
        aliases: %i[lastBackup]
      },

      # @!attribute [r] apiVersion
      #   @return [Integer]
      apiVersion: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] computer
      #   @return [Jamf::Computer::Reference]
      computer: {
        class: Jamf::Computer::Reference,
        readonly: true
      },

      # @!attribute [r] security
      #   @return [Jamf::MobileDevic:Security]
      security: {
        class: Jamf::MobileDeviceSecurity,
        readonly: true
      }
    }.freeze
    parse_object_model

  end # class Details

end # module
