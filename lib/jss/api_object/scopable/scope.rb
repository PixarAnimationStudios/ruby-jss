module JSS

  module Scopable

  #####################################
  ### Classes
  #####################################

    ###
    ### This class represents a Scope in the JSS, as can be applied to Scopable objects like
    ### Policies, Profiles, etc. Instances of this class are generally used as the value of the @scope attribute
    ### of those objects.
    ###
    ### Scope data comes from the API as a hash within the overall object data. The main keys of the hash
    ### define the included targets of the scope. A sub-hash defines limitations on those inclusions,
    ### and another sub-hash defines explicit exclusions.
    ###
    ### This class provides methods for adding, removing, or fully replacing the
    ### various parts of the scope's inclusions, limitations, and exclusions.
    ###
    ### @todo Implement simple LDAP queries using the defined {LDAPServer}s to confirm the
    ###   existance of users or groups used in limitations and exclusions. As things are now
    ###   if you add invalid user or group names, you'll get a 409 conflict error when you try
    ###   to save your changes to the JSS.
    ###
    ### @see JSS::Scopable
    ###
    class Scope

      #####################################
      ### Mix-Ins
      #####################################

      #####################################
      ### Class Methods
      #####################################

      #####################################
      ### Class Constants
      #####################################

      ### These are the classes that Scopes can use for defining a scope,
      ### keyed by appropriate symbols.
      SCOPING_CLASSES ={
        :computers => JSS::Computer,
        :computer => JSS::Computer,
        :computer_groups => JSS::ComputerGroup,
        :computer_group => JSS::ComputerGroup,
        :mobile_devices => JSS::MobileDevice,
        :mobile_device => JSS::MobileDevice,
        :mobile_device_groups => JSS::MobileDeviceGroup,
        :mobile_device_group => JSS::MobileDeviceGroup,
        :buildings => JSS::Building,
        :building => JSS::Building,
        :departments => JSS::Department,
        :department => JSS::Department,
        :network_segments => JSS::NetworkSegment,
        :network_segment => JSS::NetworkSegment,
        :users => JSS::User,
        :user => JSS::User,
        :user_groups => JSS::UserGroup,
        :user_group => JSS::UserGroup
      }

      ### Some things get checked in LDAP as well as the JSS
      LDAP_USER_KEYS = [:user, :users]
      LDAP_GROUP_KEYS = [:user_groups, :user_group]
      CHECK_LDAP_KEYS = LDAP_USER_KEYS + LDAP_GROUP_KEYS

      ### This hash maps the availble Scope Target keys from SCOPING_CLASSES to
      ### their corresponding target group keys from SCOPING_CLASSES.
      TARGETS_AND_GROUPS = {:computers => :computer_groups, :mobile_devices => :mobile_device_groups }

      ### These can be part of the base inclusion list of the scope,
      ### along with the appropriate target and target group keys
      INCLUSIONS = [:buildings, :departments]

      ### These can limit the inclusion list
      LIMITATIONS = [:network_segments, :users, :user_groups]

      ### any of them can be excluded
      EXCLUSIONS = INCLUSIONS + LIMITATIONS

      ### Here's a default scope as it might come from the API.
      DEFAULT_SCOPE = {
        :all_computers => true,
        :all_mobile_devices => true,
        :limitations => {},
        :exclusions => {}
      }



      ######################
      ### Attributes
      ######################

      ### @return [JSS::APIObject subclass]
      ###
      ### A reference to the object that contains this Scope
      ###
      ### For telling it when a change is made and an update needed
      attr_accessor :container
      
      ### @return [Boolean] should we expect a potential 409 Conflict 
      ###   if we can't connect to LDAP servers for verification?
      attr_accessor :unable_to_verify_ldap_entries
      
      ### what type of target is this scope for? Computers or Mobiledevices?
      attr_reader :target_class

      ### @return [Hash<Array>]
      ###
      ### The items which form the base scope of included targets
      ###
      ### This is the group of targets to which the limitations and exclusions apply.
      ### they keys are:
      ### - :targets
      ### - :target_groups
      ### - :departments
      ### - :buildings
      ### and the values are Arrays of names of those things.
      ###
      attr_reader :inclusions

      ### @return [Boolean]
      ###
      ### Does this scope cover all targets?
      ###
      ### If this is true, the @inclusions Hash is ignored, and all
      ### targets in the JSS form the base scope.
      ###
      attr_reader :all_targets
      


      ### @return [Hash<Array>]
      ###
      ### The items in these arrays are the limitations applied to targets in the @inclusions .
      ###
      ### The arrays of names are:
      ### - :network_segments
      ### - :users
      ### - :user_groups
      ###
      attr_reader :limitations

      ### @return [Hash<Array>]
      ###
      ### The items in these arrays are the exclusions applied to targets in the @inclusions .
      ###
      ### The arrays of names are:
      ### - :targets
      ### - :target_groups
      ### - :departments
      ### - :buildings
      ### - :network_segments
      ### - :users
      ### - :user_groups
      ###
      attr_reader :exclusions


      #####################################
      ### Public Instance Methods
      #####################################

      ###
      ### If api_scope is empty, a default scope, scoped to all targets, is created, and can be modified
      ### as needed.
      ###
      ### @param target_key[Symbol] the kind of thing we're scopeing, one of {TARGETS_AND_GROUPS}
      ###
      ### @param api_scope[Hash] the JSON :scope data from an API query that is scopable, e.g. a Policy.
      ###
      def initialize(target_key, api_scope = DEFAULT_SCOPE)

        raise JSS::InvalidDataError, "The target class of a Scope must be one of the symbols :#{TARGETS_AND_GROUPS.keys.join(', :')}" unless TARGETS_AND_GROUPS.keys.include? target_key

        @target_key = target_key
        @target_class = SCOPING_CLASSES[@target_key]
        @group_key = TARGETS_AND_GROUPS[@target_key]
        @group_class = SCOPING_CLASSES[@group_key]

        @inclusion_keys = [@target_key, @group_key] + INCLUSIONS
        @exclusion_keys = [@target_key, @group_key] + EXCLUSIONS

        @all_key = "all_#{target_key}".to_sym
        @all_targets = api_scope[@all_key]

        ### Everything gets mapped from an Array of Hashes to an Array of names (or an empty array)
        ### since names are all that really matter when submitting the scope.
        @inclusions = {}
        @inclusion_keys.each{|k| @inclusions[k] = api_scope[k] ? api_scope[k].map{|n| n[:name]} :  [] }

        @limitations = {}
        if api_scope[:limitations]
          LIMITATIONS.each{|k| @limitations[k] = api_scope[:limitations][k] ? api_scope[:limitations][k].map{|n| n[:name]} :  [] }
        end

        @exclusions = {}
        if api_scope[:exclusions]
          @exclusion_keys.each{|k| @exclusions[k] = api_scope[:exclusions][k] ? api_scope[:exclusions][k].map{|n| n[:name]} :  [] }
        end

        @container = nil

      end  # init

      ###
      ### Set the scope's inclusions to all targets.
      ###
      ### By default, the limitations and exclusions remain.
      ### If a non-false parameter is provided, they will be removed also.
      ###
      ### @param clear[Boolean] Should the limitations and exclusions be removed also?
      ###
      ### @return [void]
      ###
      def include_all(clear = false)
        @inclusions = {}
        @inclusion_keys.each{|k| @inclusions[k] = []}
        @all_targets = true
        if clear
          @limitations = {}
          LIMITATIONS.each{|k| @limitations[k] = []}

          @exclusions = {}
          @exclusion_keys.each{|k| @exclusions[k] = []}
        end
        @container.should_update if @container
      end


      ###
      ### Replace a list of item names for inclusion in this scope.
      ###
      ### The list must be an Array of names of items of the Class represented by the key.
      ### Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of items being included, :computer, :building, etc...
      ###
      ### @param list[Array] the names of the items being added
      ###
      ### @example
      ###   set_inclusion(:computers, ['kimchi','mantis'])
      ###
      ### @return [void]
      ###
      def set_inclusion(key, list)
        raise JSS::InvalidDataError, "Inclusion key must be one of :#{@inclusion_keys.join(', :')}" unless @inclusion_keys.include? key
        raise JSS::InvalidDataError, "List must be an Array of #{key} names, it may be empty." unless list.kind_of? Array

        return nil if list.sort == @inclusions[key].sort

        # emptying the list?
        if list.empty?
          @inclusion[key] = list
          # if ALL the @inclusion keys are empty, then set all targets to true.
          @all_targets =  @inclusions.values.reject{|a| a.nil? or a.empty?}.empty?
          @container.should_update if @container
          return list
        end

        ### check the names
        list.each do |name|
          raise JSS::NoSuchItemError, "No existing #{key} with name '#{name}'" unless check_name key, name
          raise JSS::AlreadyExistsError, "Can't set #{key} scope to '#{name}' because it's already an explicit exclusion." if @exclusions[key] and @exclusions[key].include? name
        end # each

        @inclusions[key] = list
        @all_targets = false
        @container.should_update if @container
      end # sinclude_in_scope


      ###
      ### Add a single item for this inclusion in this scope.
      ###
      ### The item name will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of item being added, :computer, :building, etc...
      ###
      ### @param item[String] the name of the item being added
      ###
      ### @example
      ###   add_inclusion(:computer, "mantis")
      ###
      ### @return [void]
      ###
      def add_inclusion (key, item)
        raise JSS::InvalidDataError, "Inclusion key must be one of :#{@inclusion_keys.join(', :')}" unless @inclusion_keys.include? key
        raise JSS::InvalidDataError, "Item must be a #{key} name." unless item.kind_of? String

        return nil if @inclusions[key] and @inclusions[key].include? item

        ### check the name
        raise JSS::NoSuchItemError, "No existing #{key} with name '#{item}'" unless check_name key, item
        raise JSS::AlreadyExistsError, "Can't set #{key} scope to '#{item}' because it's already an explicit exclusion." if @exclusions[key] and @exclusions[key].include? item


        @inclusions[key] << item
        @all_targets = false
        @container.should_update if @container
      end

      ###
      ### Remove a single item for this scope.
      ###
      ### @param key[Symbol] the key from #{SCOPING_CLASSES} for the kind of item being removed, :computer, :building, etc...
      ###
      ### @param item[String] the name of the item being removed
      ###
      ### @example
      ###   remove_inclusion(:computer, "mantis")
      ###
      ### @return [void]
      ###
      def remove_inclusion (key, item)
        raise JSS::InvalidDataError, "Inclusion key must be one of :#{@inclusion_keys.join(', :')}" unless @inclusion_keys.include? key
        raise JSS::InvalidDataError, "Item must be a #{key} name." unless item.kind_of? String

        return nil unless @inclusions[key] and @inclusions[key].include? item

        @inclusions[key] -= [item]

        # if ALL the @inclusion keys are empty, then set all targets to true.
        @all_targets =  @inclusions.values.reject{|a| a.nil? or a.empty?}.empty?

        @container.should_update if @container
      end


      ###
      ### Replace a limitation list for this scope.
      ###
      ### The list must be an Array of names of items of the Class represented by the key.
      ### Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### @param key[Symbol] the type of items being set as limitations, :network_segments, :users, etc...
      ###
      ### @param list[Array] the names of the items being set as limitations
      ###
      ### @example
      ###   set_limitation(:network_segments, ['foo','bar'])
      ###
      ### @return [void]
      ###
      ### @todo  handle ldap user group lookups
      ###
      def set_limitation (key, list)
        raise JSS::InvalidDataError, "Limitation key must be one of :#{LIMITATIONS.join(', :')}" unless LIMITATIONS.include? key
        raise JSS::InvalidDataError, "List must be an Array of #{key} names, it may be empty." unless list.kind_of? Array
        return nil if list.sort == @limitations[key].sort

        if list.empty?
          @limitations[key] = []
          @container.should_update if @container
          return list
        end

        ### check the names
        list.each do |name|
          raise JSS::NoSuchItemError, "No existing #{key} with name '#{name}'" unless check_name key,  name
          raise JSS::AlreadyExistsError, "Can't set #{key} limitation for '#{name}' because it's already an explicit exclusion." if @exclusions[key] and @exclusions[key].include? name
        end # each

        @limitations[key] = list
        @container.should_update if @container
      end # limit scope


      ###
      ### Add a single item for limiting this scope.
      ###
      ### The item name will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### @param key[Symbol] the type of item being added, :computer, :building, etc...
      ###
      ### @param item[String] the name of the item being added
      ###
      ### @example
      ###   add_limitation(:network_segments, "foo")
      ###
      ### @return [void]
      ###
      ### @todo  handle ldap user/group lookups
      ###
      def add_limitation (key, item)
        raise JSS::InvalidDataError, "Limitation key must be one of :#{LIMITATIONS.join(', :')}" unless LIMITATIONS.include? key
        raise JSS::InvalidDataError, "Item must be a #{key} name." unless item.kind_of? String

        return nil if @limitations[key] and @limitations[key].include? item

        ### check the name
        raise JSS::NoSuchItemError, "No existing #{key} with name '#{item}'" unless check_name key, item
        raise JSS::AlreadyExistsError, "Can't set #{key} limitation for '#{name}' because it's already an explicit exclusion." if @exclusions[key] and @exclusions[key].include? item


        @limitations[key] << item
        @container.should_update if @container
      end

      ###
      ### Remove a single item for limiting this scope.
      ###
      ### @param key[Symbol] the type of item being removed, :computer, :building, etc...
      ###
      ### @param item[String] the name of the item being removed
      ###
      ### @example
      ###   remove_limitation(:network_segments, "foo")
      ###
      ### @return [void]
      ###
      ### @todo  handle ldap user/group lookups
      ###
      def remove_limitation( key, item)
        raise JSS::InvalidDataError, "Limitation key must be one of :#{LIMITATIONS.join(', :')}" unless LIMITATIONS.include? key
        raise JSS::InvalidDataError, "Item must be a #{key} name." unless item.kind_of? String

        return nil unless @limitations[key] and @limitations[key].include? item

        @limitations[key] -= [item]
        @container.should_update if @container
      end



      ###
      ### Replace an exclusion list for this scope
      ###
      ### The list must be an Array of names of items of the Class being excluded from the scope
      ### Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### @param key[Symbol] the type of item being excluded, :computer, :building, etc...
      ###
      ### @param list[Array] the names of the items being added
      ###
      ### @example
      ###   set_exclusion(:network_segments, ['foo','bar'])
      ###
      ### @return [void]
      ###
      def set_exclusion (key, list)
        raise JSS::InvalidDataError, "Exclusion key must be one of :#{@exclusion_keys.join(', :')}" unless @exclusion_keys.include? key
        raise JSS::InvalidDataError, "List must be an Array of #{key} names, it may be empty." unless list.kind_of? Array
        return nil if list.sort == @exclusions[key].sort

        if list.empty?
          @exclusions[key] = []
          @container.should_update if @container
          return list
        end

        ### check the names
        list.each do |name|
          raise JSS::NoSuchItemError, "No existing #{key} with name '#{name}'" unless check_name key, name
          case key
            when *@inclusion_keys
              raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{name}' because it's already explicitly included." if  @inclusions[key] and @inclusions[key].include? name
            when *LIMITATIONS
              raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{name}' because it's already an explicit limitation." if @limitations[key] and @limitations[key].include? name
          end

        end # each

        @exclusions[key] = list
        @container.should_update if @container
      end # limit scope

      ###
      ### Add a single item for exclusions of this scope.
      ###
      ### The item name will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### @param key[Symbol] the type of item being added to the exclusions, :computer, :building, etc...
      ###
      ### @param item[String] the name of the item being added
      ###
      ### @example
      ###   add_exclusion(:network_segments, "foo")
      ###
      ### @return [void]
      ###
      def add_exclusion (key, item)
        raise JSS::InvalidDataError, "Exclusion key must be one of :#{@exclusion_keys.join(', :')}" unless @exclusion_keys.include? key
        raise JSS::InvalidDataError, "Item must be a #{key} name." unless item.kind_of? String

        return nil if @exclusions[key] and @exclusions[key].include? item

        ### check the name
        raise JSS::NoSuchItemError, "No existing #{key} with name '#{item}'" unless check_name key, item
        raise JSS::AlreadyExistsError, "Can't exclude #{key} scope to '#{item}' because it's already explicitly included." if @inclusions[key] and @inclusions[key].include? item
        raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{item}' because it's already an explicit limitation." if @limitations[key] and @limitations[key].include? item

        @exclusions[key] << item
        @container.should_update if @container
      end

      ###
      ### Remove a single item for exclusions of this scope
      ###
      ### @param key[Symbol] the type of item being removed from the excludions, :computer, :building, etc...
      ###
      ### @param item[String] the name of the item being removed
      ###
      ### @example
      ###   remove_exclusion(:network_segments, "foo")
      ###
      ### @return [void]
      ###
      def remove_exclusion (key, item)
        raise JSS::InvalidDataError, "Exclusion key must be one of :#{@exclusion_keys.join(', :')}" unless @exclusion_keys.include? key
        raise JSS::InvalidDataError, "Item must be a #{key} name." unless item.kind_of? String

        return nil unless @exclusions[key] and @exclusions[key].include? item

        @exclusions[key] -= [item]
        @container.should_update if @container
      end

      ###
      ### @api private
      ### Return a REXML Element containing the current state of the Scope
      ### for adding into the XML of the container.
      ###
      ### @return [REXML::Element]
      ###
      def scope_xml
        scope = REXML::Element.new "scope"
        scope.add_element(@all_key.to_s).text = @all_targets

        @inclusions.each do |klass,list|
          list_as_hash = list.map{|i| {:name => i} }
          scope << SCOPING_CLASSES[klass].xml_list( list_as_hash, :name)
        end

        limitations = scope.add_element('limitations')
        @limitations.each do |klass,list|
          list_as_hash = list.map{|i| {:name => i} }
          limitations << SCOPING_CLASSES[klass].xml_list( list_as_hash, :name)
        end

        exclusions = scope.add_element('exclusions')
        @exclusions.each do |klass,list|
          list_as_hash = list.map{|i| {:name => i} }
          exclusions << SCOPING_CLASSES[klass].xml_list( list_as_hash, :name)
        end
        return scope
      end #scope_xml
      
      
      ### Aliases
      
      alias all_targets? all_targets
      
      
      #####################################
      ### Private Instance Methods
      #####################################
      private

      ###
      ### Given a name of some class of item to be used in the scope, check that it
      ### exists in the JSS.
      ###
      ### @return [Boolean] does the name exist for the key in JSS or LDAP?
      ###
      def check_name(key, name)

        found_in_jss = SCOPING_CLASSES[key].all_names.include?(name)

        return true if found_in_jss

        return false unless CHECK_LDAP_KEYS.include?(key)
        
        begin
          return JSS::LDAPServer.user_in_ldap?(name) if LDAP_USER_KEYS.include?(key)
          return JSS::LDAPServer.group_in_ldap?(name) if LDAP_GROUP_KEYS.include?(key)
        
        # if an ldap server isn't connected, make a note of it and return true
        rescue JSS::InvalidConnectionError
          @unable_to_verify_ldap_entries = true
          return true
        end # begin
        
        return false
      end



    end # class Scope
  end #module Scopable
end # module

