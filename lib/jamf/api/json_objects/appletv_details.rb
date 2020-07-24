# Copyright 2020 Pixar

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

  class AppleTVDetails < Jamf::JSONObject

    # Class Constants
    #####################################

    # Since instances of this class are always embedded in the
    # matching MobileDevice instance, duplicated attributes are
    # omitted from OBJECT_MODEL
    OBJECT_MODEL = {

      # @!attribute [r] model
      #   @param [String]
      #   @return [String]
      model: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] modelIdentifier
      #   @param [String]
      #   @return [String]
      modelIdentifier: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] modelNumber
      #   @param [String]
      #   @return [String]
      modelNumber: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] isSupervised
      #   @return [Boolean]
      isSupervised: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] deviceId
      #   @return [String]
      deviceId: {
        class: :string,
        readonly: true,
        aliases: [:ethernet_mac_address]
      },

      # @!attribute [r] locales
      #   @return [String]
      locales: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] configurationProfiles
      #   @return [Jamf::InstalledConfigurationProfile]
      configurationProfiles: {
        class: Jamf::InstalledConfigurationProfile,
        readonly: true,
        multi: true
      },

      # @!attribute [r] airplayPassword
      #   @return [String]
      airplayPassword: {
        class: :string
      },

      # @!attribute [r] purchasing
      #   @return [Jamf::PurchasingData]
      purchasing: {
        class: Jamf::PurchasingData,
        readonly: true
      }
    }.freeze
    parse_object_model

  end # class AppleTVDetails

end # module
