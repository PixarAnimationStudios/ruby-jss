# Copyright 2023 Pixar

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

  module Scopable

    # Classes
    #####################################

    # This class represents a Scope in the JSS, as can be applied to Scopable
    # objects like Policies, Profiles, etc. Instances of this class are
    # generally used as the value of the @scope attribute of those objects.
    #
    # Scope data comes from the API as a hash within the overall object data.
    # The main keys of the hash define the included targets of the scope. A
    # sub-hash defines limitations on those targets, and another sub-hash
    # defines explicit exclusions.
    #
    # This class provides methods for adding, removing, or fully replacing the
    # various items in scope's realms: targets, limitations, and exclusions.
    #
    # This class also provides a way to see if a machine will be included in
    # this scope.
    #
    # = Discussion: Users & User Groups in Scopes:
    #######################################
    # The Classic API has bugs, as well as non-obvious/historical oddness,
    # regarding the use of Users, UserGroups, Directory Service/Local Users,
    # and Directory Service User Groups in scopes.
    # Here's a discussion of those issues, and how ruby-jss handles them.
    #
    # == Historical Oddness
    #
    # Because the concept of 'scope' existed before Jamf Pro had 'Users'
    # and 'User Groups' (Jamf::User and Jamf::UserGroup classes in ruby-jss)
    # there is non-obvious inconsistency between the labels for API data, and
    # the labels for that data in the web UI:
    #
    # === Users
    #
    # What appears in the UI as 'Users' are User objects in Jamf pro, which in ruby-jss
    # are Jamf::User instances.
    #
    # These will appear in the API data as \<jss_users> element with \<user> sub-elements (XML)
    # or the 'jss_users' array (JSON). These are available as Targets or Exclusions.
    #
    # In this class, they are also referred to as 'jss_users'
    #
    # === Directory Service/Local Users
    #
    # When editing a scope in the UI, in Limitations and Exclusions, you can
    # add arbitrary strings that will be matched to the users assigned to machines,
    # or that appear in any of the defined LDAP servers.
    # These scope items are called 'Directory Service/Local Users' but
    # used to be called 'LDAP/Local Users'
    #
    # In the API data for scopes, these items appear in the \<users> element
    # with \<user> sub-elements (XML) or 'users' array (JSON) of the limitations
    # and exclusions data
    #
    # In this class, these items ultimately use the same names they have in the API data:
    # 'users' but when specifying that you are setting that value, you can use any of
    # these synonyms, plural or singular:
    #     ldap_users, jamf_ldap_users, directory_service_local_users
    #
    # === User Groups
    #
    # What appears in the UI as 'User Groups' are User Group objects in Jamf Pro, both
    # static and smart. In ruby-jss, these are Jamf::UserGroup instances.
    #
    # They will appear in the API data as \<jss_user_groups> element with \<user_group>
    # sub-elements (XML) or the 'jss_user_groups' array (JSON). These are available as
    # Targets or Exclusions.
    #
    # In this class they are also referred to as 'jss_user_groups'
    #
    # === Directory Service User Groups
    #
    # When editing a scope in the UI, in Limitations and Exclusions, you can
    # look up and add groups from any of the defined LDAP servers.
    # These scope items are called 'Directory Service User Groups' but
    # used to be called 'LDAP User Groups'
    #
    # In the API data for scopes, these items appear in the \<user_groups> element
    # with \<user_group> sub-elements (XML) or 'user_groups' array (JSON) of the limitations
    # and exclusions data
    #
    # In this class, these items ultimately use the same names they have in the API data:
    # 'user_groups' but when specifying that you are setting that value, you can use any of
    # these synonyms, singular or plural:
    #     ldap_user_groups, directory_service_user_groups
    #
    ###################################
    # = IMPORTANT: API BUG IN POLICY AND PATCH POLICY SCOPES - CAN CAUSE DATA LOSS
    ###################################
    #
    # When you GET the data for policies and patch policies from the Classic API
    # the scope data returned will NOT include the 'jss_users' and 'jss_user_groups'
    # data in the targets or the exclusions, even if they are defined in the web UI.
    #
    # More importantly, if you try to include those in the XML when you PUT a policy
    # back to make a change via the API, you'll get an error because the API endpoint
    # doesn't know what <jss_users> or <jss_user_groups> elements are.
    #
    # Even more importanly, since you cannot include those elements in your PUT body,
    # if they actually exist in the scope, THEY WILL BE ERASED from the actual scope,
    # because they weren't in the PUT data.
    # This will always happen if you include the <scope> element in your
    # PUT data, even if you didn't change the scope.
    #
    # - How ruby-jss handles this bug:
    #
    # Fortunately the Classic API, or at least this part of it, doesn't fully adhere
    # to the REST standards for PUT, and if you don't include the <scope> element in
    # the XML, the server will just ignore the scope entirely, and nothing will change.
    #
    # We make use of that here to allow for editing Policies without fear of erasing
    # those parts of the scope. As long as you don't change anything about the scope,
    # there will be no <scope> element in the XML sent with a PUT, and the scope is
    # safe from harm.
    #
    # If you DO change the scope of a policy, this bug cannot be avoided, and you'll
    # delete any "User"/jss_user and "User Groups/jss_user_groups" defined in the
    # targets or exclusions.
    #
    # By default, if you try to change the scope of a Policy of PatchPolicy, you'll
    # get a warning about the possibility of losing data when you save.
    #
    # You can supress those warnings either by supressing all ruby warnings, or
    # by calling Jamf::Scopable::Scope.do_not_warn_about_policy_scope_bugs
    #
    ###################################
    # = IMPORTANT: API BUG IN OSX CONFIG PROFILE SCOPES - CAN CAUSE DATA LOSS
    ###################################
    #
    # When fetching the data for OSX Configuration Profiles using JSON (which ruby-jss does)
    # and the scope of the profile contains more than one `jss_user_groups` as a target, then
    # only the last one will be returned. If you have more than one such group as a target, and
    # use ruby-jss to make changes to the scope, all but the last jss_user_groups used as targets will
    # be removed.
    #
    # This only appears to affect scope targets, not exclusions, and only for
    # OSX Config Profiles. Other scopable objects that use jss_user_groups in their API data
    # seem to be OK.
    #
    # This is due to a long-standing API bug regarding how Arrays in XML are incorrectly
    # translated into Hashes of a single Hash when returning the data as JSON - they shoud be
    # Arrays of Hashes in JSON - one hash for each item.
    #
    # Even though this bug was first reported to jamf in 2009, it still appears in many places throughout
    # the Classic API.  ruby-jss works around some of the worst instances of the bug, but such workarounds
    # are complex requiring re-fetching the data in XML and parsing it manually. At the moment there are no
    # plans to do that for this specific scope bug.
    #
    # By default, if you try to change the scope of an object affected by this bug, you'll
    # get a warning about the possibility of losing data when you save.
    #
    # You can supress those warnings either by supressing all ruby warnings, or
    # by calling Jamf::Scopable::Scope.do_not_warn_about_array_hash_scope_bugs
    #
    ########################
    #
    # @see Jamf::Scopable
    #
    class Scope

      # Class Constants
      #####################################

      # These are the classes that Scopes can use for defining a scope,
      # keyed by appropriate symbols.
      #
      # synonyms, including singular/plural forms, are used to allow for
      # more natural language when specifying these scope entities. The
      # key used in the actual API data is usually the plural.
      #
      # NOTE: user[s] and user_group[s] in Scope data refer to
      # 'Directory Service/Local User' and 'Directory Service User Group'
      # as labeled in the web-ui. These were formerly labeled
      # as 'LDAP/Local User' and 'LDAP User Group'.
      #
      SCOPING_CLASSES = {
        computers: Jamf::Computer,
        computer: Jamf::Computer,

        computer_groups: Jamf::ComputerGroup,
        computer_group: Jamf::ComputerGroup,

        mobile_devices: Jamf::MobileDevice,
        mobile_device: Jamf::MobileDevice,

        mobile_device_groups: Jamf::MobileDeviceGroup,
        mobile_device_group: Jamf::MobileDeviceGroup,

        buildings: Jamf::Building,
        building: Jamf::Building,

        departments: Jamf::Department,
        department: Jamf::Department,

        network_segments: Jamf::NetworkSegment,
        network_segment: Jamf::NetworkSegment,

        ibeacons: Jamf::IBeacon,
        ibeacon: Jamf::IBeacon,

        jss_users: Jamf::User,
        jss_user: Jamf::User,

        jss_user_groups: Jamf::UserGroup,
        jss_user_group: Jamf::UserGroup,

        users: nil,
        user: nil,
        ldap_users: nil,
        ldap_user: nil,
        jamf_ldap_users: nil,
        jamf_ldap_user: nil,
        directory_service_local_users: nil,
        directory_service_local_user: nil,

        user_groups: nil,
        user_group: nil,
        ldap_user_groups: nil,
        ldap_user_group: nil,
        directory_service_user_groups: nil,
        directory_service_user_group: nil
      }.freeze

      # These classes are affected by the jss_users/jss_user_groups bug.
      #
      # They do not accept jss_users or jss_user_groups in their targets or
      # exclusions, and editing their scope via the API will always delete those
      # items from the scope if they exist.
      #
      # See discussion in the Scope class comments.
      JAMF_DATA_LOSS_BUG_CLASSES = [
        Jamf::Policy,
        Jamf::PatchPolicy
      ].freeze

      # The classes affected by the jss_users/jss_user_groups bug do not
      # include these items in their Target or Exclusion API data, even if
      # the scope has such items defined in the JSS
      #
      # See discussion in the Scope class comments.
      JAMF_DATA_LOSS_BUG_KEYS = %i[jss_users jss_user_groups].freeze

      # In the API data for limitations and exclusions
      # 'users' is what appears as Directory Service/Local Users in the web UI
      # and 'user_groups' appears as 'Directory Service User Groups'.
      #
      # Contrasted with 'jss_users' and 'jss_user_groups' in the API data for
      # targets and exlcusions, which are Jamf::User and Jamf::UserGroup objects.
      #
      LDAP_BASED_KEYS = %i[users user_groups].freeze

      # These keys always mean :users
      LDAP_JAMF_USER_KEYS = %i[
        user
        users
        ldap_user
        ldap_users
        jamf_ldap_user
        jamf_ldap_users
        directory_service_local_user
        directory_service_local_users
      ].freeze

      # These keys always mean :user_groups
      LDAP_GROUP_KEYS = %i[
        user_group
        user_groups
        ldap_user_group
        ldap_user_groups
        directory_service_user_group
        directory_service_user_groups
      ].freeze

      # This hash maps the availble Scope Target keys from SCOPING_CLASSES to
      # their corresponding target group keys from SCOPING_CLASSES.
      TARGETS_AND_GROUPS = { computers: :computer_groups, mobile_devices: :mobile_device_groups }.freeze

      # added to the ends of singular key names if needed, e.g. computer_group => computer_groups
      ESS = 's'.freeze

      # These can be part of the base target list of the scope,
      # along with the appropriate target and target group keys
      TARGETS = %i[buildings departments jss_users jss_user_groups].freeze

      # Backward Compatibility
      INCLUSIONS = TARGETS

      # These can limit the inclusion list
      # These are the keys that come from the API
      # the  :users key from the API is what we call :jamf_ldap_users
      # and the :user_groups key from the API we call :ldap_user_groups
      # See the IMPORTANT discussion above.
      LIMITATIONS = %i[
        ibeacons
        network_segments
        users
        user_groups
      ].freeze

      # any of them can be excluded
      EXCLUSIONS = TARGETS + LIMITATIONS

      # Here's a default scope as it might come from the API.
      DEFAULT_SCOPE = {
        all_computers: false,
        all_mobile_devices: false,
        limitations: {},
        exclusions: {}
      }.freeze

      # Class Methods
      ######################

      # call this to suppress warnings about data loss bug in
      # Policy and Patch Policy scopes
      def self.do_not_warn_about_policy_scope_bugs
        @do_not_warn_about_policy_scope_bugs = true
      end

      # Has do_not_warn_about_policy_scope_bugs been set?
      def self.do_not_warn_about_policy_scope_bugs?
        @do_not_warn_about_policy_scope_bugs
      end

      # call this to suppress warnings about data loss bug in
      # OSXConfigurationProfile scopes when there are jss_user_groups
      # used as targets
      def self.do_not_warn_about_array_hash_scope_bugs
        @do_not_warn_about_array_hash_scope_bugs = true
      end

      # Has do_not_warn_about_policy_scope_bugs been set?
      def self.do_not_warn_about_array_hash_scope_bugs?
        @do_not_warn_about_array_hash_scope_bugs
      end

      # Attributes
      ######################

      # @return [Jamf::APIObject subclass]
      #
      # A reference to the object that contains this Scope
      #
      # For telling it when a change is made and an update needed
      # and for accessing its api connection
      attr_accessor :container

      # @return [Boolean] should we expect a potential 409 Conflict
      #   if we can't connect to LDAP servers for verification?
      attr_accessor :unable_to_verify_ldap_entries

      # what type of target is this scope for? Computers or MobileDevices?
      attr_reader :target_class

      # what type of target group is this scope for? ComputerGroups or MobileDeviceGroups?
      attr_reader :group_class

      # @return [Boolean]
      #
      # Does this scope cover all targets?
      #
      # If this is true, the @targets Hash is ignored, and all
      # targets in the JSS form the base scope.
      #
      attr_reader :all_targets
      alias all_targets? all_targets

      # The items which form the base scope of included targets
      #
      # This is the group of targets to which the limitations and exclusions apply.
      # they keys are:
      # - :computers or :mobile_devices  (which are directly targeted)
      # - :direct_targets - a synonym for :mobile_devices or :computers
      # - :computer_groups or :mobile_device_groups  (which target all of their memebers)
      # - :group_targets - a synonym for :computer_groups or :mobile_device_groups
      # - :departments
      # - :buildings
      # - :jss_users
      # - :jss_user_groups
      #
      # and the values are Arrays of names of those things.
      #
      # @return [Hash{Symbol: Array<Integer>}]
      attr_reader :targets
      # backward compatibility
      alias inclusions targets

      # The items in these arrays are the limitations applied to targets in the @targets .
      #
      # The arrays of ids are:
      # - :network_segments
      # - :users
      # - :user_groups
      # - :ibeacons
      #
      # @return [Hash{Symbol: Array<Integer, String>}]
      attr_reader :limitations

      # The items in these arrays are the exclusions applied to targets in the @targets .
      #
      # The arrays of ids are:
      # - :computers or :mobile_devices  (which are directly excluded)
      # - :direct_exclusions - a synonym for :mobile_devices or :computers
      # - :computer_groups or :mobile_device_groups  (which exclude all of their memebers)
      # - :group_exclusions - a synonym for :computer_groups or :mobile_device_groups
      # - :departments
      # - :buildings
      # - :network_segments
      # - :jss_users
      # - :jss_user_groups
      # - :users
      # - :user_groups      #
      # @return [Hash{Symbol: Array<Integer, String>}]
      attr_reader :exclusions

      # @return [Boolean] Have changes been made to the scope, that need
      #   to be sent to the server?
      attr_accessor :should_update
      alias should_update? should_update

      # Public Instance Methods
      #####################################

      # If raw_scope is empty, a default scope, scoped to no targets, is created, and can be modified
      # as needed.
      #
      # @param target_key[Symbol] the kind of thing we're scoping, a key from {TARGETS_AND_GROUPS}
      #
      # @param raw_scope[Hash] the JSON :scope data from an API query that is scopable, e.g. a Policy.
      #
      # @param container[Jamf::APIObject] The scopable object to which this scope belongs, e,g, an
      #   instance of Jamf::Policy, Jamf::MobileDeviceApplication, etc.. If not provided, will be
      #   set automatically after initialization
      #
      ###########################
      def initialize(target_key, raw_scope = nil, container: nil)
        raw_scope ||= DEFAULT_SCOPE.dup
        unless TARGETS_AND_GROUPS.key?(target_key)
          raise Jamf::InvalidDataError, "The target class of a Scope must be one of the symbols :#{TARGETS_AND_GROUPS.keys.join(', :')}"
        end

        @should_update = false
        @container = container

        @target_key = target_key
        @target_class = SCOPING_CLASSES[@target_key]
        @group_key = TARGETS_AND_GROUPS[@target_key]
        @group_class = SCOPING_CLASSES[@group_key]

        @target_keys = [@target_key, @group_key] + TARGETS
        @exclusion_keys = [@target_key, @group_key] + EXCLUSIONS

        if JAMF_DATA_LOSS_BUG_CLASSES.include?(@container.class)
          @target_keys -= JAMF_DATA_LOSS_BUG_KEYS
          @exclusion_keys -= JAMF_DATA_LOSS_BUG_KEYS
        end

        parse_targets(raw_scope)
        parse_limitations(raw_scope)
        parse_exclusions(raw_scope)
      end # init

      # parse the targets from the init data
      ###########################
      def parse_targets(raw_scope)
        @all_key = "all_#{@target_key}".to_sym
        @all_targets = raw_scope[@all_key]

        # Everything gets mapped from an Array of Hashes to
        # an Array of ids
        @targets = {}
        @target_keys.each do |k|
          raw_scope[k] ||= []
          @targets[k] =
            if raw_scope[k].is_a? Array
              # the data should be an array of hashes with :id and :name
              raw_scope[k].compact.map { |n| n[:id].to_i }

            elsif raw_scope[k].is_a? Hash
              # its a hash of hashes, it suffers the 2009 XML->JSON Array bug and
              # there will be data loss of any more than one item.
              # We know this to be the case for OSXConfigProfiles using
              # jss_user_groups as targets. When used as exclusions, they are
              # the correct array of hashes
              @array_hash_bug_target_key = k unless raw_scope[k].empty?
              raw_scope[k].values.compact.map { |n| n[:id].to_i }
            else
              []
            end
          @targets[:direct_targets] = @targets[k] if k == @target_key
          @targets[:group_targets] = @targets[k] if k == @group_key
        end # @target_keys.each do |k|
      end
      private :parse_targets

      # parse the limitations from the init data
      ###########################
      def parse_limitations(raw_scope)
        @limitations = {}
        return unless raw_scope[:limitations]

        LIMITATIONS.each do |k|
          api_data = raw_scope[:limitations][k]
          api_data ||= []
          @limitations[k] = api_data.compact.map do |n|
            LDAP_BASED_KEYS.include?(k) ? n[:name].to_s : n[:id].to_i
          end
        end # LIMITATIONS.each do |k|
      end
      private :parse_limitations

      # parse the limitations from the init data
      ###########################
      def parse_exclusions(raw_scope)
        @exclusions = {}
        return unless raw_scope[:exclusions]

        @exclusion_keys.each do |k|
          api_data = raw_scope[:exclusions][k]
          api_data ||= []
          @exclusions[k] = api_data.compact.map do |n|
            LDAP_BASED_KEYS.include?(k) ? n[:name].to_s : n[:id].to_i
          end

          @exclusions[:direct_exclusions] = @exclusions[k] if k == @target_key
          @exclusions[:group_exclusions] = @exclusions[k] if k == @group_key
        end # @exclusion_keys.each
      end
      private :parse_exclusions

      # Set the scope's targets to all.
      #
      # By default, the limitations and exclusions remain.
      # If a non-false parameter is provided, they will be removed also.
      #
      # @param clear[Boolean] Should the limitations and exclusions be removed also?
      #
      # @return [void]
      #
      def set_all_targets(clear = false)
        @targets = {}
        @target_keys.each { |k| @targets[k] = [] }
        @all_targets = true
        if clear
          @limitations = {}
          LIMITATIONS.each { |k| @limitations[k] = [] }

          @exclusions = {}
          @exclusion_keys.each { |k| @exclusions[k] = [] }
        end
        note_pending_changes
      end
      alias include_all set_all_targets

      # Replace a list of item names for as targets in this scope.
      #
      # The list must be an Array of names of items of the Class represented by
      # the key.
      # Each will be checked for existence in the JSS, and an exception raised
      # if the item doesn't exist.
      #
      # @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of items
      # being included, :computer, :building, etc... Use :all to scope to all targets
      # (the same as calling #set_all_targets)
      #
      # @param list[Array]  identifiers of the items being added
      #
      # @example
      #   set_targets(:computers, ['kimchi','mantis'])
      #
      # @return [void]
      #
      def set_targets(key, list = nil)
        if key == :all
          set_all_targets
          return
        end

        key = pluralize_key(key)
        raise Jamf::InvalidDataError, "List must be an Array of #{key} identifiers, it may be empty." unless list.is_a? Array

        # check the idents
        list_of_ids = list.map do |ident|
          item_id = validate_item(:target, key, ident)

          if @exclusions[key]&.include?(item_id)
            raise Jamf::AlreadyExistsError, \
                  "Can't set #{key} target to '#{ident}' because it's already an explicit exclusion."
          end

          item_id
        end # each

        return nil if list_of_ids.sort == @targets[key].sort

        @targets[key] = list_of_ids
        @all_targets = false
        note_pending_changes
      end # sinclude_in_scope
      alias set_target set_targets
      alias set_inclusion set_targets
      alias set_inclusions set_targets

      # to match the all_targets and all_targets? methods
      # Just calls #set_all_targets
      #
      # @param bool [Boolean] shou\d this scope include all targets?
      #
      # @return [void]
      def all_targets=(bool)
        if Jamf::Validate.boolean bool
          set_all_targets
        else
          @all_targets = false
          note_pending_changes
        end
      end

      # Add a single item as a target in this scope.
      #
      # The item name will be checked for existence in the JSS, and an exception
      #  raised if the item doesn't exist.
      #
      # @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of item being added, :computer, :building, etc...
      #   Use :all to scope to all targets (the same as calling #set_all_targets)
      #
      # @param item[String,integer] a valid identifier of the item being added
      #
      # @example
      #   add_target(:computers, "mantis")
      #
      # @example
      #   add_target(:computer_groups, 2342)
      #
      # @return [void]
      #
      def add_target(key, item = nil)
        if key == :all
          set_all_targets
          return
        end

        key = pluralize_key(key)
        item_id = validate_item(:target, key, item)
        return if @targets[key]&.include?(item_id)

        if @exclusions[key]&.include?(item_id)
          raise Jamf::AlreadyExistsError,
                "Can't set #{key} target to '#{item}' because it's already an explicit exclusion."
        end

        @targets[key] << item_id
        @all_targets = false
        note_pending_changes
      end
      alias add_inclusion add_target

      # Remove a single item as a target for this scope.
      #
      # @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of item being removed, :computer, :building, etc...
      #
      # @param item[String,integer] a valid identifier of the item being removed
      #
      # @example
      #   remove_target(:computer, "mantis")
      #
      # @return [void]
      #
      def remove_target(key, item)
        key = pluralize_key(key)
        item_id = validate_item :target, key, item, error_if_not_found: false
        return unless item_id
        return unless @targets[key]&.include?(item_id)

        @targets[key].delete item_id
        note_pending_changes
      end
      alias remove_inclusion remove_target

      # Replace a limitation list for this scope.
      #
      # The list must be an Array of names of items of the Class represented by the key.
      # Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      #
      # @param key[Symbol] the type of items being set as limitations, :network_segments, :users, etc...
      #
      # @param list[Array] the identifiers of the items being set as limitations
      #
      # @example
      #   set_limitation(:network_segments, ['foo',231])
      #
      # @return [void]
      #
      # @todo  handle ldap user group lookups
      #
      def set_limitations(key, list)
        key = pluralize_key(key)
        raise Jamf::InvalidDataError, "List must be an Array of #{key} identifiers, it may be empty." unless list.is_a? Array

        # check the idents
        list_of_ids = list.map do |ident|
          item_id = validate_item(:limitation, key, ident)
          if @exclusions[key]&.include?(item_id)
            raise Jamf::AlreadyExistsError, "Can't set #{key} limitation for '#{name}' because it's already an explicit exclusion."
          end

          item_id
        end # each

        return nil if list_of_ids.sort == @limitations[key].sort

        @limitations[key] = list_of_ids
        note_pending_changes
      end # set_limitation
      alias set_limitation set_limitations

      # Add a single item for limiting this scope.
      #
      # The item name will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      #
      # @param key[Symbol] the type of item being added, :computer, :building, etc...
      #
      # @param item[String,integer] a valid identifier of the item being added
      #
      # @example
      #   add_limitation(:network_segments, "foo")
      #
      # @return [void]
      #
      # @todo  handle ldap user/group lookups
      #
      def add_limitation(key, item)
        key = pluralize_key(key)
        item_id = validate_item(:limitation, key, item)
        return nil if @limitations[key]&.include?(item_id)

        if @exclusions[key]&.include?(item_id)
          raise Jamf::AlreadyExistsError, "Can't set #{key} limitation for '#{name}' because it's already an explicit exclusion."
        end

        @limitations[key] << item_id
        note_pending_changes
      end

      # Remove a single item for limiting this scope.
      #
      # @param key[Symbol] the type of item being removed, :computer, :building, etc...
      #
      # @param item[String,integer] a valid identifier of the item being removed
      #
      # @example
      #   remove_limitation(:network_segments, "foo")
      #
      # @return [void]
      #
      # @todo  handle ldap user/group lookups
      #
      def remove_limitation(key, item)
        key = pluralize_key(key)
        item_id = validate_item :limitation, key, item, error_if_not_found: false
        return unless item_id
        return unless @limitations[key]&.include?(item_id)

        @limitations[key].delete item_id
        note_pending_changes
      end ###

      # Replace an exclusion list for this scope
      #
      # The list must be an Array of names of items of the Class being excluded from the scope
      # Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      #
      # @param key[Symbol] the type of item being excluded, :computer, :building, etc...
      #
      # @param list[Array] the identifiers of the items being set
      #
      # @example
      #   set_exclusion(:network_segments, ['foo','bar'])
      #
      # @return [void]
      #
      def set_exclusions(key, list)
        key = pluralize_key(key)
        raise Jamf::InvalidDataError, "List must be an Array of #{key} identifiers, it may be empty." unless list.is_a? Array

        # check the idents
        list_of_ids = list.map do |ident|
          item_id = validate_item(:exclusion, key, ident)
          case key
          when *@target_keys
            if @targets[key]&.include?(item_id)
              msg = "Can't exclude #{key} '#{ident}' because it's already explicitly included."
              raise Jamf::AlreadyExistsError, msg
            end
          when *LIMITATIONS
            if @limitations[key]&.include?(item_id)
              msg = "Can't exclude #{key} '#{ident}' because it's already an explicit limitation."
              raise Jamf::AlreadyExistsError, msg
            end
          end
          item_id
        end # each

        return nil if list_of_ids.sort == @exclusions[key].sort

        @exclusions[key] = list_of_ids
        note_pending_changes
      end # set_exclusion
      alias set_exclusion set_exclusions

      # Add a single item for exclusions of this scope.
      #
      # The item name will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      #
      # @param key[Symbol] the type of item being added to the exclusions, :computer, :building, etc...
      #
      # @param item[String,integer] a valid identifier of the item being added
      #
      # @example
      #   add_exclusion(:network_segments, "foo")
      #
      # @return [void]
      #
      def add_exclusion(key, item)
        key = pluralize_key(key)
        item_id = validate_item(:exclusion, key, item)
        return if @exclusions[key]&.include?(item_id)

        raise Jamf::AlreadyExistsError, "Can't exclude #{key} scope to '#{item}' because it's already explicitly included." if @targets[key]&.include?(item)

        raise Jamf::AlreadyExistsError, "Can't exclude #{key} '#{item}' because it's already an explicit limitation." if @limitations[key]&.include?(item)

        @exclusions[key] << item_id
        note_pending_changes
      end

      # Remove a single item for exclusions of this scope
      #
      # @param key[Symbol] the type of item being removed from the excludions, :computer, :building, etc...
      #
      # @param item[String,integer] a valid identifier of the item being removed
      #
      # @example
      #   remove_exclusion(:network_segments, "foo")
      #
      # @return [void]
      #
      def remove_exclusion(key, item)
        key = pluralize_key(key)
        item_id = validate_item :exclusion, key, item, error_if_not_found: false
        return unless @exclusions[key]&.include?(item_id)

        @exclusions[key].delete item_id
        note_pending_changes
      end

      # @api private
      # Return a REXML Element containing the current state of the Scope
      # for adding into the XML of the container.
      #
      # @return [REXML::Element]
      #
      def scope_xml
        scope = REXML::Element.new 'scope'
        scope.add_element(@all_key.to_s).text = @all_targets

        @target_keys.each do |klass|
          list = @targets[klass]
          list.compact!
          list.delete 0
          list_as_hashes = list.map { |i| { id: i } }

          xml_list = SCOPING_CLASSES[klass].xml_list(list_as_hashes, :id)
          xml_list.name = 'jss_users' if SCOPING_CLASSES[klass] == Jamf::User
          xml_list.name = 'jss_user_groups' if SCOPING_CLASSES[klass] == Jamf::UserGroup
          scope << xml_list
        end

        limitations = scope.add_element('limitations')
        @limitations.each do |klass, list|
          list.compact!
          list.delete 0
          if klass == :users
            users_xml = limitations.add_element 'users'
            list.each do |name|
              user_xml = users_xml.add_element 'user'
              user_xml.add_element('name').text = name
            end
          elsif klass == :user_groups
            user_groups_xml = limitations.add_element 'user_groups'
            list.each do |name|
              user_group_xml = user_groups_xml.add_element 'user_group'
              user_group_xml.add_element('name').text = name
            end
          else
            list_as_hashes = list.map { |i| { id: i } }
            limitations << SCOPING_CLASSES[klass].xml_list(list_as_hashes, :id)
          end
        end

        exclusions = scope.add_element('exclusions')
        @exclusion_keys.each do |klass|
          list = @exclusions[klass]
          list.compact!
          list.delete 0
          if klass == :users
            users_xml = exclusions.add_element 'users'
            list.each do |name|
              user_xml = users_xml.add_element 'user'
              user_xml.add_element('name').text = name
            end
          elsif klass == :user_groups
            user_groups_xml = exclusions.add_element 'user_groups'
            list.each do |name|
              user_group_xml = user_groups_xml.add_element 'user_group'
              user_group_xml.add_element('name').text = name
            end
          else
            list_as_hashes = list.map { |i| { id: i } }

            xml_list = SCOPING_CLASSES[klass].xml_list(list_as_hashes, :id)
            xml_list.name = 'jss_users' if SCOPING_CLASSES[klass] == Jamf::User
            xml_list.name = 'jss_user_groups' if SCOPING_CLASSES[klass] == Jamf::UserGroup
            exclusions << xml_list

          end
        end
        scope
      end # scope_xml

      # Remove large or redundant data structures from
      # the instance_variables used to create
      # pretty-print (pp) output.
      #
      # @return [Array] the desired instance_variables
      #
      def pretty_print_instance_variables
        vars = instance_variables.sort
        vars.delete :@container
        vars
      end

      # Return a hash of id => name for all machines in the target class
      # that are within this scope.
      #
      # WARNING: This must instantiate all machines in the target class.
      # It will still be slow, at least the first time for each target class.
      # On the upside, the instantiated machines will be cached, so generating
      # this list for other scopes with the same target class will be much
      # much faster.
      # In tests, 1600 Computers took about 7 minutes the first time,
      # but less than 1 second after caching.
      #
      # See also the warning for #in_scope?
      #
      # @return [Hash{Integer => String}]
      #
      ################
      def scoped_machines
        scoped_machines = {}
        @target_class.all_objects(:refresh, cnx: container.cnx).each do |machine|
          scoped_machines[machine.id] = machine.name if in_scope? machine
        end
        scoped_machines
      end

      # is a given machine is in this scope?
      #
      # For a parameter you may pass either an instantiated
      # Jamf::MobileDevice or Jamf::Computer, or an identifier for one.
      # If an identifier is passed, it is not instantiated, but an API
      # request is made for just the required subsets of data, thus
      # speeding things up a bit when calling this method many times.
      #
      # WARNING: For scopes that include Jamf Users and Jamf User Groups
      # as targets or exclusions, this method may return an incorrect value.
      # See the discussion in the documentation for the Scopable::Scope class
      # under 'IMPORTANT - Users & User Groups in Targets and Exclusions'
      #
      # NOTE: currently in-range iBeacons are transient, and are not reported
      # to the JSS as inventory data. As such they are ignored in this result.
      # If a scope contains iBeacon limitations or exclusions, it is up to
      # the user to be aware of that when evaluating the meaning of this result.
      #
      # @param machine[Integer, String, Jamf::MobileDevice, Jamf::Computer]
      #   Either an identifier for the machine, or an instantiated object
      #
      # @return [Boolean]
      #
      ##############
      def in_scope?(machine)
        machine_data = fetch_machine_data machine

        a_target?(machine_data) && within_limitations?(machine_data) && !excluded?(machine_data)
      end

      #####
      def to_s
        "Scope for #{container.class} id #{container.id}"
      end

      # Private Instance Methods
      #####################################
      private

      # look up a valid id or nil, for use in a scope type
      # Raise an error if not found, unless error_if_not_found is falsey
      #
      # @param realm [Symbol] How is this key being used in the scope?
      #   :target, :limitation, or :exclusion
      #
      # @param key [Symbol] What kind of thing are we adding to the scope?
      #  e.g computer, network_segment, etc.
      #
      # @param ident [String, Integer] A unique identifier for the item being
      #   validated, jss id, name, serial number, etc.
      #
      # @param error_if_not_found [Boolean] raise an error if no match for the ident
      #
      # @return [Integer, String, nil] the valid id or string for the item, or nil if not found
      #
      def validate_item(realm, key, ident, error_if_not_found: true)
        # which keys allowed depends on how the item is used...
        # Classes susceptible to the Data Loss Bug have JAMF_DATA_LOSS_BUG_KEYS
        # removed from the possible keys.
        possible_keys =
          case realm
          when :target
            JAMF_DATA_LOSS_BUG_CLASSES.include?(@container.class) ? (@target_keys - JAMF_DATA_LOSS_BUG_KEYS) : @target_keys
          when :limitation
            LIMITATIONS
          when :exclusion
            JAMF_DATA_LOSS_BUG_CLASSES.include?(@container.class) ? (@exclusion_keys - JAMF_DATA_LOSS_BUG_KEYS) : @exclusion_keys
          else
            raise ArgumentError, 'Unknown realm, must be :target, :limitation, or :exclusion'
          end

        key = pluralize_key(key)

        unless possible_keys.include? key
          msg = "#{realm} key must be one of :#{possible_keys.join(', :')}."
          if JAMF_DATA_LOSS_BUG_CLASSES.include?(@container.class) && JAMF_DATA_LOSS_BUG_KEYS.include?(key)
            msg = "#{msg}\nJAMF BUG WARNING: The API cannot handle :jss_users or :jss_user_groups in scope targets or exclusions of Policies or Patch Policies. If any exist in the scope they will be deleted when you save any changes to the policy via the API."
          end
          raise Jamf::InvalidDataError, msg
        end

        id = nil

        # id will be a string
        if key == :users
          id = ident
        # the web UI doesn't validate this data, it accepts any string, so we do too
        # id = ident if Jamf::User.all_names(:refresh, cnx: container.cnx).include?(ident) || Jamf::LdapServer.user_in_ldap?(ident)

        # id will be a string
        elsif key == :user_groups
          # The web UI does validate that the group exists in LDAP
          id = ident if Jamf::LdapServer.group_in_ldap? ident, cnx: container.cnx

        # id will be an integer
        else
          id = SCOPING_CLASSES[key].valid_id ident, cnx: container.cnx
        end

        raise Jamf::NoSuchItemError, "No existing #{key} matching '#{ident}'" if error_if_not_found && id.nil?

        id
      end # validate_item(type, key, ident)

      # the symbols used in the API data are plural, e.g. 'network_segments'
      # this will pluralize them, allowing us to use singulars as well.
      # This also handles the synonyms for users and user_groups
      def pluralize_key(key)
        if LDAP_JAMF_USER_KEYS.include? key
          :users
        elsif LDAP_GROUP_KEYS.include? key
          :user_groups
        else
          key.to_s.end_with?(ESS) ? key : "#{key}s".to_sym
        end
      end

      # The data used by the methods that figure out if a machine is
      # in this scope, a Hash of Hashes. the sub hashes are:
      #
      #     general: the 'general' subset
      #     location: the 'location' subset
      #     group_ids: an Array of the group ids to which the machine belongs.
      #
      # @param machine[Integer, String, Jamf::MobileDevice, Jamf::Computer]
      #   Either an identifier for the machine, or an instantiated object
      #
      # @return
      #
      def fetch_machine_data(machine)
        case machine
        when Jamf::Computer
          raise Jamf::InvalidDataError, "Targets of this scope must be #{@target_class}" unless @target_class == Jamf::Computer

          general = machine.init_data[:general]
          location = machine.init_data[:location]
          group_ids = group_ids machine.computer_groups

          # put in standardize place for easier use
          # MDevs already have this at general[:managed]
          general[:managed] = general[:remote_management][:managed]

        when Jamf::MobileDevice
          raise Jamf::InvalidDataError, "Targets of this scope must be #{@target_class}" unless @target_class == Jamf::MobileDevice

          general = machine.init_data[:general]
          location = machine.init_data[:location]
          group_ids = group_ids machine.mobile_device_groups

        else
          general, location, group_ids = fetch_subsets(machine)
        end # case

        {
          general: general,
          location: location,
          group_ids: group_ids
        }
      end

      # When we are given an indentifier for a machine,
      # fetch just the subsets of API data we need to
      # determine if the machine is in this scope
      #
      # @param ident[String, Integer]
      #
      # @return [Array] the general, locacation, and parsed group IDs
      #
      def fetch_subsets(ident)
        id = @target_class.valid_id ident, cnx: container.cnx
        raise Jamf::NoSuchItemError, "No #{@target_class} matching #{machine}" unless id

        if @target_class == Jamf::MobileDevice
          grp_subset = 'MobileDeviceGroups'
          top_key = :mobile_device
        else
          grp_subset = 'GroupsAccounts'
          top_key = :computer
        end
        subset_rsrc = "#{@target_class::RSRC_BASE}/id/#{id}/subset/General&Location&#{grp_subset}"
        data = container.cnx.c_get(subset_rsrc)[top_key]
        grp_data =
          if @target_class == Jamf::MobileDevice
            data[:mobile_device_groups]
          else
            data[:groups_accounts][:computer_group_memberships]
          end

        [data[:general], data[:location], group_ids(grp_data)]
      end

      # Given the raw API data for a machines group membership,
      # return an array of the IDs of the groups.
      #
      # @param raw[Array] The API array of the machine's group memberships
      #
      # @return [Array] The ID's of the groups to which the machine belongs.
      #
      def group_ids(raw)
        if @target_class == Jamf::MobileDevice
          raw.map { |mdg| mdg[:id] }
        else
          names_to_ids = @group_class.map_all_ids_to(:name).invert
          raw.map { |gn| names_to_ids[gn] }
        end
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @return [Boolean]
      ################
      def a_target?(machine_data)
        return false unless machine_data[:general][:managed]
        return true if \
          all_targets? || \
          machine_directly_scoped?(machine_data, :target) || \
          machine_in_scope_group?(machine_data, :target) || \
          machine_in_scope_buildings?(machine_data, :target) || \
          machine_in_scope_depts?(machine_data, :target)

        false
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @return [Boolean]
      ################
      def within_limitations?(machine_data)
        return false if \
          machine_in_scope_netsegs?(machine_data, :limitation) == false || \
          machine_in_scope_jamf_ldap_users_list?(machine_data, :limitation) == false || \
          machine_in_scope_ldap_usergroup_list?(machine_data, :limitation) == false

        true
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @return [Boolean]
      ################
      def excluded?(machine_data)
        return true if
          machine_directly_scoped?(machine_data, :exclusion) || \
          machine_in_scope_group?(machine_data, :exclusion) || \
          machine_in_scope_buildings?(machine_data, :exclusion) || \
          machine_in_scope_depts?(machine_data, :exclusion) || \
          machine_in_scope_netsegs?(machine_data, :exclusion) || \
          machine_in_scope_jamf_ldap_users_list?(machine_data, :exclusion) || \
          machine_in_scope_ldap_usergroup_list?(machine_data, :exclusion)

        false
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :target or :exclusion
      # @return [Boolean] Is the machine directly spcified in this part of the scope?
      ################
      def machine_directly_scoped?(machine_data, part)
        scope_list = part == :target ? @targets[:direct_targets] : @exclusions[:direct_exclusions]
        scope_list.include? machine_data[:general][:id]
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :target or :exclusion
      # @return [Boolean] Is the machine a member of any group listed in this part of the scope?
      ################
      def machine_in_scope_group?(machine_data, part)
        scope_list = part == :target ? @targets[:group_targets] : @exclusions[:group_exclusions]
        # if the list is empty, return nil
        return if scope_list.empty?

        # if the intersection of the machine's group ids, and those of the scope part
        # is not empty, then the machine is in at least one of the groups
        !(machine_data[:group_ids] & scope_list).empty?
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :target or :exclusion
      # @return [Boolean] Is the machine in any building listed in this part of the scope?
      #################
      def machine_in_scope_buildings?(machine_data, part)
        scope_list = part == :target ? @targets[:buildings] : @exclusions[:buildings]

        # nil if empty
        return if scope_list.empty?
        # false if no building for the machine - it isn't in any dept
        return false if machine_data[:location][:building].to_s.empty?

        building_id = Jamf::Building.map_all_ids_to(:name).invert[machine_data[:location][:building]]
        scope_list.include? building_id
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :target or :exclusion
      # @return [Boolean] Is the machine in any department listed in this part of the scope?
      #################
      def machine_in_scope_depts?(machine_data, part)
        scope_list = part == :target ? @targets[:departments] : @exclusions[:departments]

        # nil if empty
        return if scope_list.empty?
        # false if no dept for the machine - it isn't in any dept
        return false if machine_data[:location][:department].to_s.empty?

        dept_id = Jamf::Department.map_all_ids_to(:name).invert[machine_data[:location][:department]]

        scope_list.include? dept_id
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :limitation or :exclusion
      # @return [Boolean] Is the machine in any NetworkSegment listed in this part of the scope?
      ##################
      def machine_in_scope_netsegs?(machine_data, part)
        scope_list = part == :limitation ? @limitations[:network_segments] : @exclusions[:network_segments]

        # nil if no netsegs in scope part
        return if scope_list.empty?

        ip = @target_class == Jamf::Computer ? machine_data[:general][:last_reported_ip] : machine_data[:general][:ip_address]
        # false if no ip for machine - it isn't in a any of the segs
        return false if ip.to_s.empty?

        mach_segs = Jamf::NetworkSegment.network_segments_for_ip ip

        # if the intersection is not empty, then the machine is in at least one of the net segs
        !(mach_segs & scope_list).empty?
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :limitation or :exclusion
      # @return [Boolean] Is the user of this machine in the list of jamf/ldap users in this part of the scope?
      ##################
      def machine_in_scope_jamf_ldap_users_list?(machine_data, part)
        scope_list = part == :limitation ? @limitations[:jamf_ldap_users] : @exclusions[:jamf_ldap_users]

        # nil if the list is empty
        return if scope_list.empty?

        scope_list.include? machine_data[:location][:username]
      end

      # @param machine_data[Hash] See #fetch_machine_data
      # @param part[Symbol] either :limitation or :exclusion
      # @return [Boolean] Is the user of this machine a member of any of the LDAP groups in in this part of the scope?
      ##################
      def machine_in_scope_ldap_usergroup_list?(machine_data, part)
        scope_list = part == :limitation ? @limitations[:ldap_user_groups] : @exclusions[:ldap_user_groups]

        # nil if the list is empty
        return if scope_list.empty?

        # loop thru them checking to see if the user is a member
        scope_list.each do |ldapgroup|
          server = Jamf::LdapServer.server_for_group ldapgroup
          # if the group doesn't exist in any LDAP the user isn't a part of it
          next unless server

          # if the user name is in any group, return true
          return true if Jamf::LdapServer.check_membership server, machine_data[:location][:username], ldapgroup
        end

        # if we're here, not in any group
        false
      end

      # make a note both in this instance and in our container
      # that a change has been made and an update is needed
      def note_pending_changes
        warn_about_data_loss_bug
        warn_about_array_hash_bug
        @should_update = true
        @container&.should_update
      end

      # display data loss warning.
      def warn_about_data_loss_bug
        return unless JAMF_DATA_LOSS_BUG_CLASSES.include?(@container.class)
        return if Jamf::Scopable::Scope.do_not_warn_about_policy_scope_bugs?
        return if @warn_about_data_loss_bug_has_run

        warn "WARNING: Saving changes to this scope may cause data loss!\nDue to a bug in the Classic API, if the scope uses Jamf Users or User Groups in the Targets or Exclusions, they will be deleted from the scope when you save!"

        @warn_about_data_loss_bug_has_run = true
      end

      # display warning about array-hash bug data loss
      def warn_about_array_hash_bug
        return unless @array_hash_bug_target_key
        return if Jamf::Scopable::Scope.do_not_warn_about_array_hash_scope_bugs?
        return if @warn_about_array_hash_bug_has_run

        warn "WARNING: At least one #{@array_hash_bug_target_key} is used as a scope target.\nDue to a bug in the Classic API, if you save changes to this scope, all but the last #{@array_hash_bug_target_key} will be deleted from the scope targets when you save!"

        @warn_about_array_hash_bug_has_run = true
      end

    end # class Scope

  end # module Scopable

end # moduleß
