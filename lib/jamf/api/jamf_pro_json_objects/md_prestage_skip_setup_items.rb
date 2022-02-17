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

  # The 'skip Setup Items' for a mobile device prestage in Jamf Pro
  # The ones in common with computers are in the superclass
  # To see the ones that should be here, remove anything that's in
  # computers's list from the device ones, thus:
  #
  # (Jamf::MobileDevicePrestage.all.sample[:skipSetupItems].keys - Jamf::ComputerPrestage.all.sample[:skipSetupItems].keys).sort
  #  => [:Android,
  # :CloudStorage,
  # :ExpressLanguage,
  # :HomeButtonSensitivity,
  # :OnBoarding,
  # :Passcode,
  # :PreferredLanguage,
  # :RestoreCompleted,
  # :SIMSetup,
  # :ScreenSaver,
  # :SoftwareUpdate,
  # :TVHomeScreenSync,
  # :TVProviderSignIn,
  # :TVRoom,
  # :TapToSetup,
  # :TransferData,
  # :UpdateCompleted,
  # :WatchMigration,
  # :Welcome,
  # :Zoom,
  # :iMessageAndFaceTime]
  #
  class MobileDevicePrestageSkipSetupItems < Jamf::PrestageSkipSetupItems

    OBJECT_MODEL = superclass::OBJECT_MODEL.merge(

      # @!attribute Android
      #   @return [Boolean]
      Android: {
        class: :boolean,
        aliases: %i[android]
      },

      # @!attribute CloudStorage
      #   @return [Boolean]
      CloudStorage: {
        class: :boolean,
        aliases: %i[cloudstorage cloud_storage]
      },

      # @!attribute ExpressLanguage
      #   @return [Boolean]
      ExpressLanguage: {
        class: :boolean,
        aliases: %i[expressLanguage expresslanguage express_language]
      },

      # @!attribute HomeButtonSensitivity
      #   @return [Boolean]
      HomeButtonSensitivity: {
        class: :boolean,
        aliases: %i[homeButtonSensitivity homebuttonsensitivity home_button_sensitivity]
      },

      # @!attribute iMessageAndFaceTime
      #   @return [Boolean]
      iMessageAndFaceTime: {
        class: :boolean,
        aliases: %i[imessageandfacetime imessage_and_facetime]
      },

      # @!attribute OnBoarding
      #   @return [Boolean]
      OnBoarding: {
        class: :boolean,
        aliases: %i[onBoarding onboarding on_boarding]
      },

      # @!attribute Passcode
      #   @return [Boolean]
      Passcode: {
        class: :boolean,
        aliases: %i[passcode]
      },

      # @!attribute PreferredLanguage
      #   @return [Boolean]
      PreferredLanguage: {
        class: :boolean,
        aliases: %i[preferredLanguage preferredlanguage preferred_language]
      },

      # @!attribute RestoreCompleted
      #   @return [Boolean]
      RestoreCompleted: {
        class: :boolean,
        aliases: %i[restorecompleted restoreCompleted restore_completed]
      },


      # @!attribute SIMSetup
      #   @return [Boolean]
      SIMSetup: {
        class: :boolean,
        aliases: %i[simsetup simSetup sim_setup]
      },

      # @!attribute ScreenSaver
      #   @return [Boolean]
      ScreenSaver: {
        class: :boolean,
        aliases: %i[screenSaver screensaver screen_saver]
      },

      # @!attribute SoftwareUpdate
      #   @return [Boolean]
      SoftwareUpdate: {
        class: :boolean,
        aliases: %i[oftwareUpdate softwareupdate software_update]
      },

      # @!attribute TVHomeScreenSync
      #   @return [Boolean]
      TVHomeScreenSync: {
        class: :boolean,
        aliases: %i[tvHomeScreenSync tvhomescreensync tv_home_screen_sync]
      },

      # @!attribute TVProviderSignIn
      #   @return [Boolean]
      TVProviderSignIn: {
        class: :boolean,
        aliases: %i[tvprovidersignin tvProviderSignIn tv_provider_sign_in]
      },

      # @!attribute TVRoom
      #   @return [Boolean]
      TVRoom: {
        class: :boolean,
        aliases: %i[tvRoom tvroom tv_room]
      },

      # @!attribute TapToSetup
      #   @return [Boolean]
      TapToSetup: {
        class: :boolean,
        aliases: %i[tapToSetup taptosetup tap_to_setup]
      },

      # @!attribute TransferData
      #   @return [Boolean]
      TransferData: {
        class: :boolean,
        aliases: %i[transferData transferdata transfer_data]
      },

      # @!attribute UpdateCompleted
      #   @return [Boolean]
      UpdateCompleted: {
        class: :boolean,
        aliases: %i[updateCompleted updatecompleted update_completed]
      },

      # @!attribute WatchMigration
      #   @return [Boolean]
      WatchMigration: {
        class: :boolean,
        aliases: %i[watchMigration watchmigration watch_migration]
      },

      # @!attribute Welcome
      #   @return [Boolean]
      Welcome: {
        class: :boolean,
        aliases: %i[welcome]
      },

      # @!attribute Zoom
      #   @return [Boolean]
      Zoom: {
        class: :boolean,
        aliases: %i[zoom]
      }
    ).freeze

    parse_object_model

  end # class location

end # module
