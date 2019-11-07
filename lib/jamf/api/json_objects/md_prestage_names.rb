# Copyright 2018 Pixar

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

  # A 'location' for a computer prestage in Jamf Pro
  class MobileDevicePrestageNames < Jamf::JSONObject

    OBJECT_MODEL = {

      # @!attribute assignNamesUsing
      #   @return [String]
      assignNamesUsing: {
        class: :string
      },

      # @!attribute prestageDeviceNames
      #   @return [Jamf::MobileDevicePrestageName]
      prestageDeviceNames: {
        class: Jamf::MobileDevicePrestageName,
        multi: true
      },

      # @!attribute deviceNamePrefix
      #   @return [String]
      deviceNamePrefix: {
        class: :string
      },

      # @!attribute deviceNameSuffix
      #   @return [String]
      deviceNameSuffix: {
        class: :string
      },

      # @!attribute singleDeviceName
      #   @return [String]
      singleDeviceName: {
        class: :string
      },

      # @!attribute isManageNames
      #   @return [Boolean]
      isManageNames: {
        class: :boolean
      },

      # @!attribute isDeviceNamingConfigured
      #   @return [Boolean]
      isDeviceNamingConfigured: {
        class: :boolean
      }
    }.freeze

    parse_object_model

  end # class location

end # module
