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
    include JSS::Creatable
    include JSS::Updatable

    RSRC_BASE = 'patchpolicies'.freeze

    RSRC_LIST_KEY = :patch_policies

    RSRC_OBJECT_KEY = :patch_policy

    SCOPE_TARGET_KEY = :computers

    AUTO_INSTALL_GRACE_PERIOD_MESSAGE = '$APP_NAMES will quit in $DELAY_MINUTES minutes so that $SOFTWARE_TITLE can be updated. Save anything you are working on and quit the app(s).'.freeze

    DFT_ENABLED = false


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
          },
          grace_period: {
            grace_period_duration: 15,
            notification_center_subject: 'Important',
            message: AUTO_INSTALL_GRACE_PERIOD_MESSAGE
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

    # @return [Integer] How many minutes does the user have to quit the killapps?
    attr_reader :grace_period_duration

    # @return [String] The Subject of the message displayed asking the user to
    #    quit the killapps within @grace_period_duration minutes
    attr_reader :grace_period_notification_center_subject

    # @return [String] The message displayed asking the user to quit the killapps
    #   within @grace_period_duration minutes
    attr_reader :grace_period_message

    # @return [Integer] the id of the JSS::PatchTitle for this policy
    attr_reader :software_title_configuration_id
    alias software_title_id software_title_configuration_id
    alias patch_title_id software_title_configuration_id

    # When making new Patch Polices :patch_title and :target_version must be
    # provided as well as :name.
    #
    # :patch_title is the name or id of a currently active patch title
    #
    # :target_version is the string identfier of an available version of
    # the title. The target version MUST have a package assigned to it.
    #
    def initialize(data = {})
      super

      gen = @init_data[:general]
      gen ||= {}

      if !in_jss
        raise JSS::MissingDataError, ':patch_title required when creating a patch policy' unless @init_data[:patch_title]
        title_id = JSS::PatchTitle.valid_id @init_data[:patch_title]
        raise JSS::NoSuchItemError, "No Patch Title matches '#{@init_data[:patch_title]}'" unless title_id
        @init_data[:software_title_configuration_id] = title_id
        validate_target_version @init_data[:target_version]
        @init_data[:general][:target_version] = @init_data[:target_version]
      end


      @enabled = gen[:enabled]
      @target_version = gen[:target_version]
      @allow_downgrade = gen[:allow_downgrade]
      @patch_unknown = gen[:patch_unknown]


      @init_data[:user_interaction] ||= {}
      deadlines = @init_data[:user_interaction][:deadlines]
      deadlines ||= {}
      grace = @init_data[:user_interaction][:grace_period]
      grace ||= {}

      @deadline_enabled = deadlines[:deadline_enabled]
      @deadline_period = deadlines[:deadline_period]

      @grace_period_duration = grace[:grace_period_duration]
      @grace_period_notification_center_subject = grace[:notification_center_subject]
      @grace_period_message = grace[:message]

      # This is read only - even if you put a change, it's ignored.
      @software_title_configuration_id = @init_data[:software_title_configuration_id]

      # read-only values, they come from the version.
      @release_date = JSS.epoch_to_time gen[:release_date]
      @incremental_update = gen[:incremental_update]
      @reboot = gen[:reboot]
      @minimum_os = gen[:minimum_os]
      @kill_apps = gen[:kill_apps]

    end

    # Set a new target version for this policy.
    # The version must exist in the policy's PatchTitle, and have a package
    # assigned to it.
    #
    # @param new_tgt_vers[String] the new version for this Patch Policy.
    #
    # @return [void]
    #
    def target_version=(new_tgt_vers)
      return if new_tgt_vers == target_version
      validate_target_version new_tgt_vers
      @target_version = new_tgt_vers
      @need_to_update = true
      @refetch_for_new_version = true
    end

    # The JSS::PatchTitle to for this PatchPolicy
    #
    # @param refresh [Boolean] Should the Title be re-fetched from the API?
    #
    # @return [JSS::PatchTitle, nil]
    #
    def patch_title(refresh = false)
      return nil unless JSS::PatchTitle.all_ids.include? software_title_configuration_id
      @patch_title = nil if refresh
      @patch_title ||= JSS::PatchTitle.fetch id: software_title_configuration_id
    end

    # @return [String] the name of the PatchTitle for this patch policy
    def patch_title_name
      return @patch_title.name if @patch_title
      JSS::PatchTitle.map_all_ids_to(:name)[software_title_configuration_id]
    end

    # Set the downgradability of this policy - i.e. can it run when
    # the installed version is newer than this one?
    #
    # @param new_val [Boolean] Can this policy be used for downgrades?
    #
    # @return [void]
    #
    def allow_downgrade=(new_val)
      return if new_val == allow_downgrade
      raise JSS::InvalidDataError, 'New value must be boolean true or false' unless JSS::TRUE_FALSE.include? new_val
      @allow_downgrade = new_val
      @need_to_update = true
    end

    # Set the abillity of this policy to install when the previosly installed
    # version cannot be determined?
    #
    # @param new_val [Boolean] Can this policy run when we don't know the prev.
    #  version?
    #
    # @return [void]
    #
    def patch_unknown=(new_val)
      return if new_val == patch_unknown
      raise JSS::InvalidDataError, 'New value must be boolean true or false' unless JSS::TRUE_FALSE.include? new_val
      @patch_unknown = new_val
      @need_to_update = true
    end

    # Set the deadline enforcement of this policy
    #
    # @param new_val [Boolean] Does this policy have a deadline for running?
    #
    # @return [void]
    #
    def deadline_enabled=(new_val)
      return if new_val == deadline_enabled
      raise JSS::InvalidDataError, 'New value must be boolean true or false' unless JSS::TRUE_FALSE.include? new_val
      @deadline_enabled = new_val
      @need_to_update = true
    end

    # Set the deadline for running this patch policy to some number of days
    # after it becomes available.
    #
    # @param days[Integer] how many days before this Patch Policy runs automatically?
    #
    # @return [void]
    #
    def deadline_period=(days)
      return if deadline_period == days
      raise JSS::InvalidDataError, 'New value must be an Integer' unless days.is_a? Integer
      @deadline_period = days
      @need_to_update = true
    end


    def create
      super
      refetch_version_info
    end


    def update
      super
      refetch_version_info if @refetch_for_new_version
      @refetch_for_new_version = false
    end



    # Private Instance Methods
    #####################################
    private

    def validate_target_version(tgt_vers)
      raise JSS::InvalidDataError, 'target_version must be a String' unless tgt_vers.is_a? String
      raise JSS::InvalidDataError, 'target_version must not be empty' if tgt_vers.empty?

      unless title.versions.key? new_tgt_vers
        raise JSS::UnsupportedError, "Version '#{new_tgt_vers}' does not exist for title: #{patch_title_name}."
      end

      unless title.versions_with_packages.key? new_tgt_vers
        raise JSS::UnsupportedError, "Version '#{new_tgt_vers}' cannot be used in Patch Policies until a package is assigned to it."
      end
    end

    def refetch_version_info
      tmp = self.class.fetch id: id
      @release_date = tmp.release_date
      @incremental_update = tmp.incremental_update
      @reboot = tmp.reboot
      @minimum_os = tmp.minimum_os
      @kill_apps = tmp.kill_apps
    end

    def rest_xml
      doc = REXML::Document.new JSS::APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      general = obj.add_element 'general'
      general.add_element('name').text = @name
      general.add_element('enabled').text = @enabled
      general.add_element('target_version').text = @target_version
      general.add_element('allow_downgrade').text = @allow_downgrade
      general.add_element('patch_unknown').text = @patch_unknown

      obj << scope.scope_xml

      add_self_service_xml doc

      doc.to_s
    end


  end # class PatchPolicy

end # module JSS
