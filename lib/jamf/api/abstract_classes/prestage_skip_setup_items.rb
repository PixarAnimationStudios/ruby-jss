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

  # A class that represents the 'Skip' settings for
  # various Setup options in a DEP prestage
  # The object model here includes the attributes common
  # to both Computer and MobileDevice prestages
  class PrestageSkipSetupItems < Jamf::JSONObject

    extend Jamf::Abstract

    OBJECT_MODEL = {

      # @!attribute Appearance
      #   @return [Boolean]
      Appearance: {
        class: :boolean,
        aliases: %i[appearance]
      },

      # @!attribute AppleID
      #   @return [Boolean]
      AppleID: {
        class: :boolean,
        aliases: %i[appleID appleid apple_id]
      },

      # @!attribute Biometric
      #   @return [Boolean]
      Biometric: {
        class: :boolean,
        aliases: %i[biometric]
      },

      # @!attribute Diagnostics
      #   @return [Boolean]
      Diagnostics: {
        class: :boolean,
        aliases: %i[diagnostics]
      },

      # @!attribute DisplayTone
      #   @return [Boolean]
      DisplayTone: {
        class: :boolean,
        aliases: %i[displaytone display_tone]
      },

      # @!attribute Location
      #   @return [Boolean]
      Location: {
        class: :boolean,
        aliases: %i[location]
      },

      # @!attribute Payment
      #   @return [Boolean]
      Payment: {
        class: :boolean,
        aliases: %i[payment]
      },

      # @!attribute Privacy
      #   @return [Boolean]
      Privacy: {
        class: :boolean,
        aliases: %i[privacy]
      },

      # @!attribute Restore
      #   @return [Boolean]
      Restore: {
        class: :boolean,
        aliases: %i[restore]
      },

      # @!attribute ScreenTime
      #   @return [Boolean]
      ScreenTime: {
        class: :boolean,
        aliases: %i[screenTime screentime]
      },

      # @!attribute Siri
      #   @return [Boolean]
      Siri: {
        class: :boolean,
        aliases: %i[siri]
      },

      # @!attribute TOS
      #   @return [Boolean]
      TOS: {
        class: :boolean,
        aliases: %i[tos terms_of_service]
      }
    }.freeze

  end # class location

end # module
