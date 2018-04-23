### Copyright 2018 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
module JSS

  # This is a stub - Patch Policy data in the API is still borked.
  # Waiting for fixes from Jamf.
  #
  # @see JSS::APIObject
  #
  class PatchPolicy < JSS::APIObject

    include JSS::SelfServable
    include JSS::Scopable

    RSRC_BASE = 'patchpolicies'.freeze

    RSRC_LIST_KEY = :patch_policies

    RSRC_OBJECT_KEY = :patch_policy

    SCOPE_TARGET_KEY = :computers


    USE_XML_WORKAROUND = {
      patch_policy: {
        general: {
          id: -1,
          name: JSS::BLANK,
          enabled: nil,
          target_version: JSS::BLANK,
          release_date: 0,
          incremental_update: nil,
          reboot: nil,
          minimum_os: JSS::BLANK,
          kill_apps: [
            {
              kill_app_name: JSS::BLANK,
              kill_app_bundle_id: JSS::BLANK
            }
          ],
          distribution_method: JSS::BLANK,
          allow_downgrade: nil,
          patch_unknown: nil
        },
        scope: {
          all_computers: nil,
          computers: [
            {
              id: -1,
              name: JSS::BLANK,
              udid: JSS::BLANK
            }
          ],
          computer_groups: [
            {
              id: -1,
              name: JSS::BLANK
            }
          ],
          users: [
            {
              id: -1,
              username: JSS::BLANK
            }
          ],
          user_groups: [
            {
              id: -1,
              name: JSS::BLANK
            }
          ],
          buildings: [
            {
              id: -1,
              name: JSS::BLANK
            }
          ],
          departments: [
            {
              id: -1,
              name: JSS::BLANK
            }
          ],
          limitations: {
            network_segments: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ],
            ibeacons: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ]
          },
          exclusions: {
            computers: [
              {
                id: -1,
                name: JSS::BLANK,
                udid: JSS::BLANK
              }
            ],
            computer_groups: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ],
            users: [
              {
                id: -1,
                username: JSS::BLANK
              }
            ],
            user_groups: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ],
            buildings: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ],
            departments: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ],
            network_segments: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ],
            ibeacons: [
              {
                id: -1,
                name: JSS::BLANK
              }
            ]
          }
        },
        user_interaction: {
          install_button_text: JSS::BLANK,
          self_service_description: JSS::BLANK,
          self_service_icon: {
            id: -1,
            filename: JSS::BLANK,
            uri: JSS::BLANK
          },
          notifications: {
            notification_enabled: nil,
            notification_type: JSS::BLANK,
            notification_subject: JSS::BLANK,
            notification_message: JSS::BLANK,
            reminders: {
              notification_reminders_enabled: nil,
              notification_reminder_frequency: 1
            }
          },
          deadlines: {
            deadline_enabled: nil,
            deadline_period: 7
          }
        },
        software_title_configuration_id: 2
      }
    }.freeze

    # @return [Boolean] is this patch policy enabled?
    attr_reader :enabled
    alias enabled? enabled

    # @return [String] The version deployed by this policy
    attr_reader :target_version
    alias version target_version

    # @return [Time] when the target_version was released
    attr_reader :release_date

    # @return [Boolean] must this patch be installed only over the prev. version?
    attr_reader :incremental_update
    alias incremental_update? incremental_update

    # @return [Boolean] does this patch require a reboot after installation?
    attr_reader :reboot
    alias reboot_required reboot
    alias reboot? reboot
    alias reboot_required? reboot

    # @return [String] The min. OS version require to install this patch
    attr_reader :minimum_os

    # @return [Array<Hash>] The apps that cannot be running when this is installed.
    #   each Hash contains :kill_app_name and :kill_app_bundle_id, both Strings
    attr_reader :kill_apps

    # @return [Boolean] Can this title be downgraded to this version?
    attr_reader :allow_downgrade
    alias allow_downgrade? allow_downgrade
    alias downgradable? allow_downgrade

    # @return [Boolean] can this be installed over an unknown current version?
    attr_reader :patch_unknown
    alias patch_unknown? patch_unknown

    # @return [Boolean] Does this policy have a deadline for installing?
    attr_reader :deadline_enabled
    alias deadline_enabled? deadline_enabled

    # @return [Integer] If a deadline is enabled, how many days is it?
    attr_reader :deadline_period

    # @return [Integer] the id of the JSS::PatchTitle for this policy
    attr_reader :software_title_configuration_id
    alias software_title_id software_title_configuration_id
    alias patch_title_id software_title_configuration_id

    def initialize(data = {})
      super
      @enabled = @init_data[:general][:enabled]
      @target_version = @init_data[:general][:target_version]
      @release_date = JSS.epoch_to_time @init_data[:general][:release_date]
      @incremental_update = @init_data[:general][:incremental_update]
      @reboot = @init_data[:general][:reboot]
      @minimum_os = @init_data[:general][:minimum_os]
      @kill_apps = @init_data[:general][:kill_apps]
      @allow_downgrade = @init_data[:general][:allow_downgrade]
      @patch_unknown = @init_data[:general][:patch_unknown]
      @deadline_enabled = @init_data[:user_interaction][:deadlines][:deadline_enabled]
      @deadline_period = @init_data[:user_interaction][:deadlines][:deadline_period]

    end


  end # class PatchPolicy

end # module JSS
