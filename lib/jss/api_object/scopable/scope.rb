# Copyright 2019 Pixar

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

module JSS

  module Scopable

    # Classes
    #####################################

    # This class represents a Scope in the JSS, as can be applied to Scopable
    # objects like Policies, Profiles, etc. Instances of this class are
    # generally used as the value of the @scope attribute of those objects.
    #
    # Scope data comes from the API as a hash within the overall object data.
    # The main keys of the hash define the included targets of the scope. A
    # sub-hash defines limitations on those inclusions, and another sub-hash
    # defines explicit exclusions.
    #
    # This class provides methods for adding, removing, or fully replacing the
    # various items in scope's realms: targets, limitations, and exclusions.
    #
    # IMPORTANT:
    # The classic API has bugs regarding the use of Users, UserGroups,
    # LDAP/Local Users, & LDAP User Groups in scopes. Here's a discussion
    # of those bugs and how ruby-jss handles them.
    #
    # Targets/Inclusions
    #  - 'Users' can only be JSS::Users - No LDAP
    #    - BUG: They do not appear in API data (XML or JSON) and are
    #      NOT SUPPORTED in ruby-jss.
    #    - You must use the Web UI to work with them in a Scope.
    #  - 'User Groups' can only be JSS::UserGroups - No LDAP
    #    - BUG: They do not appear in API data (XML or JSON) and are
    #      NOT SUPPORTED in ruby-jss.
    #    - You must use the Web UI to work with them in a Scope.
    #
    # Limitations
    #  - 'LDAP/Local Users' can be any string
    #    - The Web UI accepts any string, even if no matching Local or LDAP user.
    #    - The data shows up in API data in scope=>limitations=>users
    #      by name only (the string provided), no IDs
    #  - 'LDAP User Groups' can only be LDAP groups that actually exist
    #    - The Web UI won't let you add a group that doesn't exist in ldap
    #    - The data shows up in API data in scope=>limitations=>user_groups
    #      by name and LDAP ID (which may be empty)
    #    - The data ALSO shows up in API data in scope=>limit_to_users=>user_groups
    #      by name only, no LDAP IDs. ruby-jss ignores this and looks at
    #      scope=>limitations=>user_groups
    #
    # Exclusions, combines the behavior of Inclusions & Limitations
    #  - 'Users' can only be JSS::Users - No LDAP
    #    - BUG: They do not appear in API data (XML or JSON) and are
    #      NOT SUPPORTED in ruby-jss.
    #    - You must use the Web UI to work with them in a Scope.
    #  - 'User Groups' can only be JSS::UserGroups - No LDAP
    #    - BUG: They do not appear in API data (XML or JSON) and are
    #      NOT SUPPORTED in ruby-jss.
    #    - You must use the Web UI to work with them in a Scope.
    #  - 'LDAP/Local Users' can be any string
    #    - The Web UI accepts any string, even if no matching Local or LDAP user.
    #    - The data shows up in API data in scope=>exclusions=>users
    #      by name only (the string provided), no IDs
    #  - 'LDAP User Groups' can only be LDAP groups that actually exist
    #    - The Web UI won't let you add a group that doesn't exist in ldap
    #    - The data shows up in API data in scope=>exclusions=>user_groups
    #      by name and LDAP ID (which may be empty)
    #
    #
    # How ruby-jss handles this:
    #
    #   - Methods #set_targets and #add_target will not accept the keys
    #     :user, :users, :user_group, :user_groups.
    #
    #   - Method #remove_target will ignore them.
    #
    #   - Methods #set_limitations, #add_limitation & #remove_limitation will accept:
    #     - :user or :ldap_user (and their plurals) for working with
    #       'LDAP/Local Users'. When setting or adding, the provided string(s)
    #       must exist as either a JSS::User or an LDAP user
    #     - :user_group or :ldap_user_group (and their plurals) for working with
    #       'LDAP User Groups'. When setting or adding, the provided string
    #       must exist as a group in LDAP.
    #
    #   - Methods #set_exclusions, #add_exclusion & #remove_exclusion will accept:
    #     - :user or :ldap_user (and their plurals) for working with
    #       'LDAP/Local Users'. When setting or adding, the provided string(s)
    #       must exist as either a JSS::User or an LDAP user.
    #     - :user_group or :ldap_user_group (and their plurals) for working with
    #       'LDAP User Groups''. When setting or adding, the provided string
    #       must exist as a group in LDAP.
    #
    #
    # @see JSS::Scopable
    #
    class Scope

      # Class Constants
      #####################################

      # These are the classes that Scopes can use for defining a scope,
      # keyed by appropriate symbols.
      SCOPING_CLASSES = {
        computers: JSS::Computer,
        computer: JSS::Computer,
        computer_groups: JSS::ComputerGroup,
        computer_group: JSS::ComputerGroup,
        mobile_devices: JSS::MobileDevice,
        mobile_device: JSS::MobileDevice,
        mobile_device_groups: JSS::MobileDeviceGroup,
        mobile_device_group: JSS::MobileDeviceGroup,
        buildings: JSS::Building,
        building: JSS::Building,
        departments: JSS::Department,
        department: JSS::Department,
        network_segments: JSS::NetworkSegment,
        network_segment: JSS::NetworkSegment,
        users: JSS::User,
        user: JSS::User,
        user_groups: JSS::UserGroup,
        user_group: JSS::UserGroup,
        ldap_user: JSS::User,
        ldap_users: JSS::User,
        ldap_user_group: JSS::UserGroup,
        ldap_user_groups: JSS::UserGroup
      }.freeze

      # Some things get checked in LDAP as well as the JSS
      LDAP_USER_KEYS = %i[user users].freeze
      LDAP_GROUP_KEYS = %i[user_groups user_group].freeze
      CHECK_LDAP_KEYS = LDAP_USER_KEYS + LDAP_GROUP_KEYS

      # This hash maps the availble Scope Target keys from SCOPING_CLASSES to
      # their corresponding target group keys from SCOPING_CLASSES.
      TARGETS_AND_GROUPS = { computers: :computer_groups, mobile_devices: :mobile_device_groups }.freeze

      # added to the ends of singular key names if needed, e.g. computer_group => computer_groups
      ESS = 's'.freeze

      # These can be part of the base inclusion list of the scope,
      # along with the appropriate target and target group keys
      INCLUSIONS = %i[buildings departments].freeze

      # These can limit the inclusion list
      LIMITATIONS = %i[network_segments ldap_users ldap_user_groups].freeze

      # any of them can be excluded
      EXCLUSIONS = INCLUSIONS + LIMITATIONS

      # Here's a default scope as it might come from the API.
      DEFAULT_SCOPE = {
        all_computers: true,
        all_mobile_devices: true,
        limitations: {},
        exclusions: {}
      }.freeze

      # Attributes
      ######################

      # @return [JSS::APIObject subclass]
      #
      # A reference to the object that contains this Scope
      #
      # For telling it when a change is made and an update needed
      attr_accessor :container

      # @return [Boolean] should we expect a potential 409 Conflict
      #   if we can't connect to LDAP servers for verification?
      attr_accessor :unable_to_verify_ldap_entries

      # what type of target is this scope for? Computers or Mobiledevices?
      attr_reader :target_class

      # @return [Hash<Array>]
      #
      # The items which form the base scope of included targets
      #
      # This is the group of targets to which the limitations and exclusions apply.
      # they keys are:
      # - :targets
      # - :target_groups
      # - :departments
      # - :buildings
      # and the values are Arrays of names of those things.
      #
      attr_reader :inclusions

      # @return [Boolean]
      #
      # Does this scope cover all targets?
      #
      # If this is true, the @inclusions Hash is ignored, and all
      # targets in the JSS form the base scope.
      #
      attr_reader :all_targets

      # @return [Hash<Array>]
      #
      # The items in these arrays are the limitations applied to targets in the @inclusions .
      #
      # The arrays of names are:
      # - :network_segments
      # - :users
      # - :user_groups
      #
      attr_reader :limitations

      # @return [Hash<Array>]
      #
      # The items in these arrays are the exclusions applied to targets in the @inclusions .
      #
      # The arrays of names are:
      # - :targets
      # - :target_groups
      # - :departments
      # - :buildings
      # - :network_segments
      # - :users
      # - :user_groups
      #
      attr_reader :exclusions

      # Public Instance Methods
      #####################################

      # If raw_scope is empty, a default scope, scoped to all targets, is created, and can be modified
      # as needed.
      #
      # @param target_key[Symbol] the kind of thing we're scoping, one of {TARGETS_AND_GROUPS}
      #
      # @param raw_scope[Hash] the JSON :scope data from an API query that is scopable, e.g. a Policy.
      #
      def initialize(target_key, raw_scope = nil)
        raw_scope ||= DEFAULT_SCOPE.dup
        raise JSS::InvalidDataError, "The target class of a Scope must be one of the symbols :#{TARGETS_AND_GROUPS.keys.join(', :')}" unless TARGETS_AND_GROUPS.key?(target_key)

        @target_key = target_key
        @target_class = SCOPING_CLASSES[@target_key]
        @group_key = TARGETS_AND_GROUPS[@target_key]
        @group_class = SCOPING_CLASSES[@group_key]

        @inclusion_keys = [@target_key, @group_key] + INCLUSIONS
        @exclusion_keys = [@target_key, @group_key] + EXCLUSIONS

        @all_key = "all_#{target_key}".to_sym
        @all_targets = raw_scope[@all_key]

        # Everything gets mapped from an Array of Hashes to
        # an Array of ids
        @inclusions = {}
        @inclusion_keys.each do |k|
          raw_scope[k] ||= []
          @inclusions[k] = raw_scope[k].compact.map { |n| n[:id].to_i  }
        end # @inclusion_keys.each do |k|

        @limitations = {}
        if raw_scope[:limitations]
          LIMITATIONS.each do |k|
            raw_scope[:limitations][k] ||= []

            if k == :ldap_users || k == :ldap_user_groups

              if k == :ldap_users
                ldap_users = raw_scope[:limitations][:users].compact.map { |n| n[:name].to_s }
                @limitations[k] = ldap_users
              else
                ldap_user_groups = raw_scope[:limitations][:user_groups].compact.map { |n| n[:name].to_s }
                @limitations[k] = ldap_user_groups
              end
            else
              @limitations[k] = raw_scope[:limitations][k].compact.map { |n| n[:id].to_i }
            end
          end # LIMITATIONS.each do |k|
        end # if raw_scope[:limitations]

        @exclusions = {}
        if raw_scope[:exclusions]
          @exclusion_keys.each do |k|
            # Skip these since API doesn't actually provide these
            next if (k == :ldap_users || k == :ldap_user_groups)

            raw_scope[:exclusions][k] ||= []

            if k == :users || k == :user_groups
              ldap_objects = []
              if k == :users
                ldap_users = raw_scope[:exclusions][:users].compact.select { |n| JSS::User.valid_id(n).nil? }.map { |n| n[:name].to_s }
                ldap_objects = ldap_users
                @exclusions[:ldap_users] = ldap_users

                jss_users = raw_scope[:exclusions][:user_groups].compact.select { |n| !JSS::User.valid_id(n).nil? }.map { |n| n[:id].to_i }
                @exclusions[k] = jss_users
              else
                ldap_user_groups = raw_scope[:exclusions][:user_groups].compact.select { |n| JSS::UserGroup.valid_id(n).nil? }.map { |n| n[:name].to_s }
                ldap_objects = ldap_user_groups
                @exclusions[:ldap_user_groups] = ldap_user_groups

                jss_user_groups = raw_scope[:exclusions][:user_groups].compact.select { |n| !JSS::UserGroup.valid_id(n).nil? }.map { |n| n[:id].to_i }
                @exclusions[k] = jss_user_groups

              end
            else
              @exclusions[k] = raw_scope[:exclusions][k].compact.map { |n| n[:id].to_i }
            end
          end
        end

        @container = nil
      end # init

      # Set the scope's inclusions to all targets.
      #
      # By default, the limitations and exclusions remain.
      # If a non-false parameter is provided, they will be removed also.
      #
      # @param clear[Boolean] Should the limitations and exclusions be removed also?
      #
      # @return [void]
      #
      def include_all(clear = false)
        @inclusions = {}
        @inclusion_keys.each { |k| @inclusions[k] = [] }
        @all_targets = true
        if clear
          @limitations = {}
          LIMITATIONS.each { |k| @limitations[k] = [] }

          @exclusions = {}
          @exclusion_keys.each { |k| @exclusions[k] = [] }
        end
        @container.should_update if @container
      end

      # Replace a list of item names for as targets in this scope.
      #
      # The list must be an Array of names of items of the Class represented by
      # the key.
      # Each will be checked for existence in the JSS, and an exception raised
      # if the item doesn't exist.
      #
      # @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of items
      # being included, :computer, :building, etc...
      #
      # @param list[Array]  identifiers of the items being added
      #
      # @example
      #   set_targets(:computers, ['kimchi','mantis'])
      #
      # @return [void]
      #
      def set_targets(key, list)
        key = pluralize_key(key)
        raise JSS::InvalidDataError, "List must be an Array of #{key} identifiers, it may be empty." unless list.is_a? Array

        # check the idents
        list.map! do |ident|
          item_id = validate_item(:target, key, ident)
          if @exclusions[key] && @exclusions[key].include?(item_id)
            raise JSS::AlreadyExistsError, \
              "Can't set #{key} target to '#{ident}' because it's already an explicit exclusion."
          end
          item_id
        end # each

        return nil if list.sort == @inclusions[key].sort

        @inclusions[key] = list
        @all_targets = false
        @container.should_update if @container
      end # sinclude_in_scope
      alias set_target set_targets
      alias set_inclusion set_targets
      alias set_inclusions set_targets

      # Add a single item as a target in this scope.
      #
      # The item name will be checked for existence in the JSS, and an exception
      #  raised if the item doesn't exist.
      #
      # @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of item being added, :computer, :building, etc...
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
      def add_target(key, item)
        key = pluralize_key(key)
        item_id = validate_item(:target, key, item)
        return if @inclusions[key] && @inclusions[key].include?(item_id)

        raise JSS::AlreadyExistsError, "Can't set #{key} target to '#{item}' because it's already an explicit exclusion." if @exclusions[key] && @exclusions[key].include?(item_id)

        @inclusions[key] << item_id
        @all_targets = false
        @container.should_update if @container
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
        return unless @inclusions[key] && @inclusions[key].include?(item_id)
        @inclusions[key].delete item_id
        @container.should_update if @container
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
      def set_limitation(key, list)
        key = pluralize_key(key)
        raise JSS::InvalidDataError, "List must be an Array of #{key} identifiers, it may be empty." unless list.is_a? Array

        # check the idents
        list.map! do |ident|
          item_id = validate_item(:limitation, key, ident)
          raise JSS::AlreadyExistsError, "Can't set #{key} limitation for '#{name}' because it's already an explicit exclusion." if @exclusions[key] && @exclusions[key].include?(item_id)
          item_id
        end # each

        return nil if list.sort == @limitations[key].sort

        @limitations[key] = list
        @container.should_update if @container
      end # set_limitation
      alias set_limitations set_limitation

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
        return nil if @limitations[key] && @limitations[key].include?(item_id)

        raise JSS::AlreadyExistsError, "Can't set #{key} limitation for '#{name}' because it's already an explicit exclusion." if @exclusions[key] && @exclusions[key].include?(item_id)

        @limitations[key] << item_id
        @container.should_update if @container
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
        return unless @limitations[key] && @limitations[key].include?(item_id)
        @limitations[key].delete item_id
        @container.should_update if @container
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
      def set_exclusion(key, list)
        key = pluralize_key(key)
        raise JSS::InvalidDataError, "List must be an Array of #{key} identifiers, it may be empty." unless list.is_a? Array

        # check the idents
        list.map! do |ident|
          item_id = validate_item(:exclusion, key, ident)
          case key
          when *@inclusion_keys
            raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{ident}' because it's already explicitly included." if @inclusions[key] && @inclusions[key].include?(item_id)
          when *LIMITATIONS
            raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{ident}' because it's already an explicit limitation." if @limitations[key] && @limitations[key].include?(item_id)
          end
          item_id
        end # each

        return nil if list.sort == @exclusions[key].sort

        @exclusions[key] = list
        @container.should_update if @container
      end # limit scope

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
        return if @exclusions[key] && @exclusions[key].include?(item_id)
        raise JSS::AlreadyExistsError, "Can't exclude #{key} scope to '#{item}' because it's already explicitly included." if @inclusions[key] && @inclusions[key].include?(item)
        raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{item}' because it's already an explicit limitation." if @limitations[key] && @limitations[key].include?(item)

        @exclusions[key] << item_id
        @container.should_update if @container
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
        return unless @exclusions[key] && @exclusions[key].include?(item_id)
        @exclusions[key].delete item_id
        @container.should_update if @container
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

        @inclusions.each do |klass, list|
          list.compact!
          list.delete 0
          list_as_hash = list.map { |i| { id: i } }
          scope << SCOPING_CLASSES[klass].xml_list(list_as_hash, :id)
        end

        limitations = scope.add_element('limitations')
        @limitations.each do |klass, list|
          list.compact!
          list.delete 0
          if klass == :ldap_user_groups || klass == :ldap_users
            list_as_hash = list.map { |i| { name: i } }
            limitations << SCOPING_CLASSES[klass].xml_list(list_as_hash, :name)
          else
            list_as_hash = list.map { |i| { id: i } }
            limitations << SCOPING_CLASSES[klass].xml_list(list_as_hash, :id)
          end
        end

        exclusions = scope.add_element('exclusions')
        @exclusions.each do |klass, list|
          list.compact!
          list.delete 0
          if klass == :ldap_user_groups || klass == :ldap_users
            list_as_hash = list.map { |i| { name: i } }
            exclusions << SCOPING_CLASSES[klass].xml_list(list_as_hash, :name)
          else
            list_as_hash = list.map { |i| { id: i } }
            exclusions << SCOPING_CLASSES[klass].xml_list(list_as_hash, :id)
          end
        end
        scope
      end # scope_xml

      # Remove the init_data and api object from
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

      # Aliases

      alias all_targets? all_targets

      # Private Instance Methods
      #####################################
      private

      # look up a valid id or nil, for use in a scope type
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
      # @return [Integer, nil] the valid id for the item, or nil if not found
      #
      def validate_item(realm, key, ident, error_if_not_found: true)
        # which keys allowed depends on how the item is used...
        possible_keys =
          case realm
          when :target then @inclusion_keys
          when :limitation then LIMITATIONS
          when :exclusion then @exclusion_keys
          else
            raise ArgumentError, 'Unknown realm, must be :target, :limitation, or :exclusion'
          end
        key = pluralize_key(key)
        raise JSS::InvalidDataError, "#{realm} key must be one of :#{possible_keys.join(', :')}" \
          unless possible_keys.include? key

        # return nil or a valid id
        id = SCOPING_CLASSES[key].valid_id ident

        if id.nil? && (key == :ldap_users || key == :ldap_user_groups)
          if key == :ldap_user_groups
            # Check if ldap user exists
            return ident if JSS::LDAPServer.group_in_ldap? ident
          else
            # Check if ldap user group exists
            return ident if JSS::LDAPServer.user_in_ldap? ident
          end
        else
          raise JSS::NoSuchItemError, "No existing #{key} matching '#{ident}'" if error_if_not_found && id.nil?
          id
        end
      end # validate_item(type, key, ident)

      # the symbols used in the API data are plural, e.g. 'network_segments'
      # this will pluralize them, allowing us to use singulars as well.
      def pluralize_key(key)
        key.to_s.end_with?(ESS) ? key : "#{key}s".to_sym
      end

    end # class Scope

  end # module Scopable

end # module
