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

  # A Patch Policy in the JSS
  #
  # When making new Patch Polices :patch_title and :target_version must be
  # provided as well as :name.
  #
  # :patch_title is the name or id of a currently active patch title
  #
  # :target_version is the string identfier of an available version of
  # the title. The target version MUST have a package assigned to it.
  #
  # See {JSS::PatchTitle} and {JSS::PatchSource.available_titles} for methods
  # to acquire such info.
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

    RSRC_BY_PATCH_TITLE = 'patchpolicies/softwaretitleconfig/id/'.freeze

    # TODO: complain to jamf about this - should be the same as RSRC_LIST_KEY
    RSRC_BY_PATCH_TITLE_LIST_KEY = :"patch policies"

    SCOPE_TARGET_KEY = :computers

    AUTO_INSTALL_GRACE_PERIOD_MESSAGE = '$APP_NAMES will quit in $DELAY_MINUTES minutes so that $SOFTWARE_TITLE can be updated. Save anything you are working on and quit the app(s).'.freeze

    DFT_ENABLED = false

    # the default dist method - not in ssvc
    DFT_DISTRIBUTION = 'prompt'.freeze

    # the value of #deadline when there is no deadline
    NO_DEADLINE = :none

    DFT_DEADLINE = 7

    # The valud of #grace_period when not defined
    DFT_GRACE_PERIOD = 15

    DFT_GRACE_PERIOD_SUBJECT = 'Important'.freeze

    DFT_GRACE_PERIOD_MESSAGE = '$APP_NAMES will quit in $DELAY_MINUTES minutes so that $SOFTWARE_TITLE can be updated. Save anything you are working on and quit the app(s).'.freeze

    # See {JSS::XMLWorkaround}
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

    # Class Methods
    ################################

    # Fetch name and id of all PatchPolicies tied to a given PatchTitle
    #
    # @param title[String,Integer] the name or id of the PatchTitle for which
    #  to retrieve a list of patch policies
    #
    # @return [Array<Hash>] the :id and :name of each policy for the title
    #
    def self.all_for_title(title, api: JSS.api)
      title_id = JSS::PatchTitle.valid_id title
      raise JSS::NoSuchItemError, "No PatchTitle matching '#{title}'" unless title_id
      api.get_rsrc("#{RSRC_BY_PATCH_TITLE}#{title_id}")[RSRC_BY_PATCH_TITLE_LIST_KEY]
    end

    # Attributes
    ################################

    # @return [Boolean] is this patch policy enabled?
    attr_reader :enabled
    alias enabled? enabled

    # When setting, the version must exist in the policy's PatchTitle,
    # and have a package assigned to it.
    #
    # @param new_tgt_vers[String] the new version for this Patch Policy.
    #
    # @return [String] The version deployed by this policy
    #
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

    # Can this title be downgraded to this version?
    # @param new_val [Boolean]
    # @return [Boolean]
    attr_reader :allow_downgrade
    alias allow_downgrade? allow_downgrade
    alias downgradable? allow_downgrade

    # Can this policy run when we don't know the prev. version?
    # @param new_val [Boolean]
    # @return [Boolean]
    attr_reader :patch_unknown
    alias patch_unknown? patch_unknown

    # How many days is the install deadline?
    # @param days [Integer, Symbol] :none, or a positive integer. Integers < 1
    #   have the same meaning as :none
    #
    # @return [Integer, Symnol] :none, or a positive integer
    attr_reader :deadline

    # @param new_period [Integer] Negative integers will be saved as 0
    #
    # @return [Integer] How many minutes does the user have to quit the killapps?
    #
    attr_reader :grace_period
    alias grace_period_duration grace_period

    # @param subj [String] the new subject
    #
    # @return [String] The Subject of the message displayed asking the user to
    #    quit the killapps within @grace_period minutes
    attr_reader :grace_period_subject
    alias grace_period_notification_center_subject grace_period_subject

    # @param subj [String] the new message
    #
    # @return [String] The message displayed asking the user to quit the killapps
    #   within @grace_period minutes
    attr_reader :grace_period_message

    # @return [Integer] the id of the JSS::PatchTitle for this policy.
    #   Can be set with the patch_title: param of .make, but is read-only after
    #   that.
    attr_reader :patch_title_id
    alias software_title_id patch_title_id
    alias software_title_configuration_id patch_title_id

    # When making new Patch Polices :patch_title is required and is
    # a JSS::PatchTitle or the name or id of one
    #
    # If target_version: is provided, it must exist in the PatchTitle,
    # and must have a package assigned to it.
    #
    def initialize(data = {})
      super

      # creation...
      unless in_jss
        @init_data[:general] ||= {}
        @init_data[:software_title_configuration_id] = validate_patch_title @init_data[:patch_title]

        # were we given target_version in the make params?
        validate_target_version @init_data[:target_version] if @init_data[:target_version]
        @init_data[:general][:target_version] = @init_data[:target_version]

        # other defaults
        @init_data[:general][:enabled] = false
        @init_data[:general][:allow_downgrade] = false
        @init_data[:general][:patch_unknown] = false
        @init_data[:general][:distribution_method] = DFT_DISTRIBUTION
      end

      @patch_title_id = @init_data[:software_title_configuration_id]

      gen = @init_data[:general]
      @enabled = gen[:enabled]
      @target_version = gen[:target_version]
      @allow_downgrade = gen[:allow_downgrade]
      @patch_unknown = gen[:patch_unknown]

      @init_data[:user_interaction] ||= {}

      deadlines = @init_data[:user_interaction][:deadlines]
      deadlines ||= {}
      deadlines[:deadline_period] = DFT_DEADLINE if deadlines[:deadline_period].to_s.empty?
      @deadline = deadlines[:deadline_enabled] ? deadlines[:deadline_period] : NO_DEADLINE

      grace = @init_data[:user_interaction][:grace_period]
      grace ||= {}

      @grace_period = grace[:grace_period_duration]
      @grace_period = DFT_GRACE_PERIOD if @grace_period.to_s.empty?

      @grace_period_subject = grace[:notification_center_subject]
      @grace_period_subject = DFT_GRACE_PERIOD_SUBJECT if @grace_period_subject.to_s.empty?

      @grace_period_message = grace[:message]
      @grace_period_message = DFT_GRACE_PERIOD_MESSAGE if @grace_period_message.to_s.empty?


      # read-only values, they come from the version.
      @release_date = JSS.epoch_to_time gen[:release_date]
      @incremental_update = gen[:incremental_update]
      @reboot = gen[:reboot]
      @minimum_os = gen[:minimum_os]
      @kill_apps = gen[:kill_apps]
    end

    # The JSS::PatchTitle to for this PatchPolicy
    #
    # @param refresh [Boolean] Should the Title be re-fetched from the API?
    #
    # @return [JSS::PatchTitle, nil]
    #
    def patch_title(refresh = false)
      @patch_title = nil if refresh
      @patch_title ||= JSS::PatchTitle.fetch id: patch_title_id
    end

    # @return [String] the name of the PatchTitle for this patch policy
    #
    def patch_title_name
      return @patch_title.name if @patch_title
      JSS::PatchTitle.map_all_ids_to(:name)[software_title_configuration_id]
    end

    # See attr_reader :target_version
    #
    def target_version=(new_tgt_vers)
      return if new_tgt_vers == target_version
      @target_version = validate_target_version new_tgt_vers
      @need_to_update = true
      @refetch_for_new_version = true
    end

    # enable this policy
    #
    # @return [void]
    #
    def enable
      return if enabled
      @enabled = true
      @need_to_update = true
    end

    # disable this policy
    #
    # @return [void]
    #
    def disable
      return unless enabled
      @enabled = false
      @need_to_update = true
    end

    # see attr_reader :allow_downgrade
    #
    def allow_downgrade=(new_val)
      return if new_val == allow_downgrade
      @allow_downgrade = JSS::Validate.boolean new_val
      @need_to_update = true
    end

    # see attr_reader :patch_unknown
    #
    def patch_unknown=(new_val)
      return if new_val == patch_unknown
      @patch_unknown = JSS::Validate.boolean new_val
      @need_to_update = true
    end

    # see attr_reader :deadline
    #
    def deadline=(days)
      unless days == NO_DEADLINE
        days = JSS::Validate.integer(days)
        days = NO_DEADLINE unless days.positive?
      end
      return if days == deadline
      @deadline = days
      @need_to_update = true
    end

    # see attr_reader :grace_period
    #
    def grace_period=(mins)
      mins = JSS::Validate.integer(mins)
      mins = 0 if mins.negative?
      return if mins == grace_period
      @grace_period = mins
      @need_to_update = true
    end

    # see attr_reader :grace_period_subject
    #
    def grace_period_subject=(subj)
      return if grace_period_subject == subj.to_s
      @grace_period_subject = subj.to_s
      @need_to_update = true
    end

    # see attr_reader :grace_period_message
    #
    def grace_period_message=(msg)
      return if grace_period_message == msg
      @grace_period_message = msg
      @need_to_update = true
    end

    # Create a new PatchPolicy in the JSS
    #
    # @return [Integer] the id of the new policy
    #
    def create
      validate_for_saving
      # TODO: prepare for more cases where the POST rsrc is
      # different from the PUT/GET/DELETE.
      orig_rsrc = @rest_rsrc
      @rest_rsrc = "#{RSRC_BY_PATCH_TITLE}#{patch_title_id}"
      super
      @rest_rsrc = orig_rsrc
      refetch_version_info
      id
    end

    # Update an existing PatchPolicy with changes from ruby
    #
    # @return [Integer] the id of the policy
    #
    def update
      validate_for_saving
      super
      refetch_version_info if @refetch_for_new_version
      @refetch_for_new_version = false
      id
    end

    # Private Instance Methods
    #####################################
    private

    # raise an error if the patch title we're trying to use isn't available in
    # the jss. If handed a PatchTitle instance, we assume it came from the JSS
    #
    ## @param new_title[String,Integer,JSS::PatchTitle] the title to validate
    #
    # @return [Integer] the id of the valid title
    #
    def validate_patch_title(a_title)
      if a_title.is_a? JSS::PatchTitle
        @patch_title = a_title
        return a_title.id
      end
      raise JSS::MissingDataError, ':patch_title is required' unless a_title
      title_id = JSS::PatchTitle.valid_id a_title
      return title_id if title_id
      raise JSS::NoSuchItemError, "No Patch Title matches '#{a_title}'"
    end

    # raise an exception if a given target version is not valid for this policy
    # Otherwise return it
    #
    def validate_target_version(tgt_vers)
      raise JSS::MissingDataError, "target_version can't be nil" unless tgt_vers

      JSS::Validate.non_empty_string tgt_vers

      unless patch_title(:refresh).versions.key? tgt_vers
        errmsg = "Version '#{tgt_vers}' does not exist for title: #{patch_title_name}."
        raise JSS::NoSuchItemError, errmsg
      end

      return tgt_vers if patch_title.versions_with_packages.key? tgt_vers

      errmsg = "Version '#{tgt_vers}' cannot be used in Patch Policies until a package is assigned to it."
      raise JSS::UnsupportedError, errmsg
    end

    def validate_for_saving
      validate_target_version target_version
    end

    # Update our local version data after the target_version is changed
    #
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
      general.add_element('target_version').text = target_version
      general.add_element('name').text = name
      general.add_element('enabled').text = enabled?.to_s
      general.add_element('allow_downgrade').text = allow_downgrade
      general.add_element('patch_unknown').text = patch_unknown

      obj << scope.scope_xml

      add_self_service_xml doc

      # self svc xml gave us the user_interaction section
      user_int = obj.elements['user_interaction']

      dlines = user_int.add_element 'deadlines'
      if deadline == NO_DEADLINE
        dlines.add_element('deadline_enabled').text = 'false'
      else
        dlines.add_element('deadline_enabled').text = 'true'
        dlines.add_element('deadline_period').text = deadline.to_s
      end

      grace = user_int.add_element 'grace_period'
      grace.add_element('grace_period_duration').text = grace_period.to_s
      grace.add_element('notification_center_subject').text = grace_period_subject.to_s
      grace.add_element('message').text = grace_period_message.to_s

      doc.to_s
    end

  end # class PatchPolicy

end # module JSS
