module JSS
  
  module Scopable
  
  #####################################
  ### Classes
  #####################################
  
    ###
    ### A Scope in the JSS, as can be applied to Scopable objects like
    ### Policies, Profiles, etc
    ###
    ### scope comes from the API as a hash of inclusions, exclusions, and limitations of objects
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
      
      ### These are the classes that Scopes can use for defining a scope
      SCOPING_CLASSES ={
        :computers => JSS::Computer, 
        :computer_groups => JSS::ComputerGroup,
        :mobile_devices => JSS::MobileDevice, 
        :mobile_device_groups => JSS::MobileDeviceGroup,
        :buildings => JSS::Building, 
        :departments => JSS::Department,
        :network_segments => JSS::NetworkSegment,
        :users => JSS::User,
        :user_groups => JSS::UserGroup
      }
      
      ### These keys can be the targets of a scope.
      ### Their values are the matching group key
      TARGET_KEYS = {:computers => :computer_groups, :mobile_devices => :mobile_device_groups }

      ### These can be part of the base inclusion list of the scope, 
      ### along with the appropriate target and target group keys
      INCLUSION_KEYS = [:buildings, :departments]
      
      ### These can limit the inclusion list
      LIMITATION_KEYS = [:network_segments, :users, :user_groups]
      
      ### any of them can be excluded
      EXCLUSION_KEYS = INCLUSION_KEYS + LIMITATION_KEYS

      
      ### A default scope has no inclusions, limitations, or exclusions, and is scoped to everything.
      DEFAULT_SCOPE = {
        :all_computers => true,
        :all_mobile_devices => true,
        :limitations =>{}, 
        :exclusions=>{} 
      }
      

      
      ######################
      ### Attributes
      ######################
      
      ### a reference to the object that contains this Scope, so that we
      ### can tell it when a change is made and an update needed
      attr_accessor :container
      
      ### what type of target is this scope for? Computers or Mobiledevices?
      attr_reader :target_key
      
      ### A Hash of Arrays of names
      ### The items in these arrays form the base scope
      ### to which the limitations and exclusions apply.
      ### they keys are:
      ###  :targets, :target_groups, :departments, :buildings
      ### and the values are Arrays of names of those things.
      attr_reader :inclusions
      
      ### Bool, does this scope cover all computers, or mobile devices
      ### if this is true, the @inclusions hash is ignored, and all 
      ### targets in the JSS form the base scope.
      attr_reader :all_targets 
      alias all_targets? all_targets
      
      
      ### A Hash of Arrays of names
      ### The items in these arrays are the limitations
      ### applied to the @inclusions scop base.
      attr_reader :limitations
      
      ### A Hash of Arrays of names
      ### The items in these arrays are the exclusions 
      ### appliend to the items in the @inclusions scope base.
      attr_reader :exclusions
      
      
      #####################################
      ### Public Instance Methods
      #####################################
      
      ###
      ### The first arg must be the kind of target this scope specifies, one of the symbols in TARGET_KEYS
      ###
      ### The second, if provided, is the :scope hash the JSON output of the API resource for an object
      ### that has a scope, e.g. a Policy.
      ### If the second is empty, a default scope, scoped to all targets, is created, and can be modified
      ### as needed.
      ### 
      def initialize(target_key, api_scope = DEFAULT_SCOPE)
        
        raise JSS::InvalidDataError, "The target key of a Scope must be one of :#{TARGET_KEYS.keys.join(', :')}" unless TARGET_KEYS.keys.include? target_key
        
        @target_key = target_key
        @target_class = SCOPING_CLASSES[@target_key]
        @group_key = TARGET_KEYS[target_key]
        @group_class = SCOPING_CLASSES[@group_key]
        @all_key = "all_#{target_key}".to_sym
        @inclusion_keys = [@target_key, @group_key] + INCLUSION_KEYS
        @exclusion_keys = [@target_key, @group_key] + EXCLUSION_KEYS
        
        @all_targets = api_scope[@all_key]
        
        ### Everything gets mapped from an Array of Hashes to an Array of names (or an empty array)
        ### since names are all that really matter when submitting the scope.
        @inclusions = {}
        @inclusions[@target_key] = api_scope[@target_key] ? api_scope[@target_key].map{|n| n[:name]} : []
        @inclusions[@group_key] = api_scope[@group_key]  ? api_scope[@group_key].map{|n| n[:name]} :  []
        @inclusions[:departments] = api_scope[:departments]  ? api_scope[:departments].map{|n| n[:name]} :  []
        @inclusions[:buildings] = api_scope[:buildings]  ? api_scope[:buildings].map{|n| n[:name]} :  []
        
        @limitations = api_scope[:limitations]
        if @limitations
          @limitations[:network_segments] ||= []
          @limitations[:users] ||= []
          @limitations[:user_groups] ||= []
          
          @limitations[:network_segments].map!{|n| n[:name]}
          @limitations[:users].map!{|n| n[:name]}
          @limitations[:user_groups].map!{|n| n[:name]}
        end
        
        @exclusions = api_scope[:exclusions]
        if @exclusions
          @exclusions[@target_key] ||= []
          @exclusions[@group_key] ||= []
          @exclusions[:departments] ||= []
          @exclusions[:buildings]  ||= []
          @exclusions[:network_segments]  ||= []
          @exclusions[:users]  ||= []
          @exclusions[:user_groups]  ||= []

          @exclusions[@target_key].map!{|n| n[:name]}
          @exclusions[@group_key].map!{|n| n[:name]}
          @exclusions[:departments].map!{|n| n[:name]}
          @exclusions[:buildings].map!{|n| n[:name]}
          @exclusions[:network_segments].map!{|n| n[:name]}
          @exclusions[:users].map!{|n| n[:name]}
          @exclusions[:user_groups].map!{|n| n[:name]}
        end
        
        @container = nil
        
      end  # init
      
      ###
      ### remove all scoping inclusions, but not 
      ### limitations or exclusions, setting @all_targets to true
      ###
      def include_all
        @inclusion_keys.each{|k| include_in_scope(k,[])}
        @all_targets = true
      end
      
      ###
      ### Set @all_targets = true, and remove all limitations and exclusions
      ###
      def clear
        set_scope_to_all
        LIMITATION_KEYS.each{|k| limit_scope(k,[])}
        @exclusion_keys.each{|k| exclude_from_scope(k,[])}
      end
      
      ###
      ### provide a new inclusion list of names for scoping this policy
      ### The list must be an Array of names for items of the klass being added to the scope
      ### Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      ### e.g include_in_scope(:computers, ['kimchi','mantis'])
      ###
      def include_in_scope(key, list)
        raise JSS::InvalidDataError, "Scope key must be one of :#{@inclusion_keys.join(', :')}" unless @inclusion_keys.include? key
        raise JSS::InvalidDataError, "List must be an Array of #{key} names, it may be empty." unless list.kind_of? Array
        
        return nil if list.sort == @inclusions[key].sort
        
        if list.empty?
          @inclusion[key] = []
          ### if ALL the @incliuusion keys are empty, then set all targets to true.
          @all_targets =  @inclusion.values.reject{|a| a.empty?}.empty?
          @container.need_to_update if @container
          return list
        end
        
        ### check the names
        list.each do |name|
          raise JSS::NoSuchItemError, "No existing #{key} with name '#{name}'" unless check_name name
          raise JSS::AlreadyExistsError, "Can't set #{key} scope to '#{name}' because it's already an explicit exclusion." if @exclusions[key].include? name
        end # each
        
        @inclusions[key] = list 
        @container.need_to_update if @container
      end # sinclude_in_scope
      
      ###
      ### provide a new limitation list of items for scoping this policy
      ### The list must be an Array of names for items of the type being limited in the scope
      ### Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      def limit_scope(key, list)
        raise JSS::InvalidDataError, "Scope key must be one of :#{LIMITATION_KEYS.join(', :')}" unless LIMITATION_KEYS.include? key
        raise JSS::InvalidDataError, "List must be an Array of #{key} names, it may be empty." unless list.kind_of? Array
        return nil if list.sort == @limitations[key].sort
        
        if list.empty?
          @limitations[key] = []
          @container.need_to_update if @container
          return list
        end
        
        ### check the names
        list.each do |name|
          raise JSS::NoSuchItemError, "No existing #{key} with name '#{name}'" unless check_name name
          raise JSS::AlreadyExistsError, "Can't set #{key} limitation to '#{name}' because it's already an explicit exclusion." if @exclusions[key].include? name
        end # each
        
        @limitations[key] = list 
        @container.need_to_update if @container
      end # limit scope
      
      ###
      ### provide a new exclusion list of items for scoping this policy
      ### The list must be an Array of names or id's for items of the type being excluded from the scope
      ### Each will be checked for existence in the JSS, and an exception raised if the item doesn't exist.
      ###
      def exclude_from_scope(key, list)
        raise JSS::InvalidDataError, "Scope key must be one of :#{@exclusion_keys.join(', :')}" unless @exclusion_keys.include? key
        raise JSS::InvalidDataError, "List must be an Array of #{key} names, it may be empty." unless list.kind_of? Array
        return nil if list.sort == @exclusions[key].sort
        
        if list.empty?
          @exclusions[key] = []
          @container.need_to_update if @container
          return list
        end
        
        ### check the names
        list.each do |name|
          raise JSS::NoSuchItemError, "No existing #{key} with name '#{name}'" unless check_name name
          case key
            when *@inclusion_keys
              raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{name}' because it's already explicitly included." if @inclusions[key].include? name
            when *LIMITATION_KEYS
              raise JSS::AlreadyExistsError, "Can't exclude #{key} '#{name}' because it's already an explicit limitation." if @limitations[key].include? name
          end
          
        end # each
        
        @exclusions[key] = list 
        @container.need_to_update if @container
      end # limit scope
      
      
      #####################################
      ### Private Instance Methods
      #####################################
      ###private
      
      ###
      ### Given a name of some class of item to be used in the scope, check that it
      ### exists in the JSS. Return true or false
      ### Since users and user groups don't come from the list of API users (they come 
      ### from LDAP or the client machine) the always return true
      ###
      def check_name(klass, name)
        SCOPING_CLASSES[klass].all_names.include? name
      end
      
      ###
      ### Return a REXML Element containing the current state of the Scope
      ### for adding into the XML of the container.
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
      
    end # class Scope
  end #module Scopable
end # module

