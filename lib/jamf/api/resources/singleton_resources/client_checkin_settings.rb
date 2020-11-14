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

module Jamf

  # The client checkin settings for the Jamf Pro Server
  #
  class ClientCheckInSettings < Jamf::SingletonResource

    # Mix-Ins
    #####################################

    extend Jamf::ChangeLog
    include Jamf::ChangeLog

    # Constants
    #####################################

    UPDATABLE = true

    RSRC_VERSION = 'v2'.freeze

    RSRC_PATH = 'check-in'.freeze

    OBJECT_MODEL = {

      # @!attribute checkInFrequency
      #   @return [integer]
      checkInFrequency: {
        class: :integer
      },

      # @!attribute isCreateHooks
      #   @return [Boolean]
      createHooks: {
        class: :boolean
      },

      # @!attribute isHookLog
      #   @return [Boolean]
      hookLog: {
        class: :boolean
      },

      # @!attribute isHookPolicies
      #   @return [Boolean]
      hookPolicies: {
        class: :boolean
      },

      # @!attribute isHookHideRestore
      #   @return [Boolean]
      hookHideRestore: {
        class: :boolean
      },

      # @!attribute isHookMCX
      #   @return [Boolean]
      hookMcx: {
        class: :boolean
      },

      # @!attribute isBackgroundHooks
      #   @return [Boolean]
      backgroundHooks: {
        class: :boolean
      },

      # @!attribute isHookDisplayStatus
      #   @return [Boolean]
      hookDisplayStatus: {
        class: :boolean
      },

      # @!attribute isCreateStartupScript
      #   @return [Boolean]
      createStartupScript: {
        class: :boolean
      },

      # @!attribute isStartupLog
      #   @return [Boolean]
      startupLog: {
        class: :boolean
      },

      # @!attribute isStartupPolicies
      #   @return [Boolean]
      startupPolicies: {
        class: :boolean
      },

      # @!attribute isStartupSSH
      #   @return [Boolean]
      startupSsh: {
        class: :boolean
      },

      # @!attribute isStartupMCX
      #   @return [Boolean]
      startupMcx: {
        class: :boolean
      },

      # @!attribute isEnableLocalConfigurationProfiles
      #   @return [Boolean]
      enableLocalConfigurationProfiles: {
        class: :boolean
      }

    }.freeze # end OBJECT_MODEL

    parse_object_model

  end # class ClientCheckIn

end # module JAMF
