module JSS
  
  #####################################
  ### Module Constants
  #####################################  
  
  #####################################
  ### Module Variables
  #####################################
  
  #####################################
  ### Module Methods
  ##################################### 
  
  #####################################
  ### Classes
  ##################################### 
  
  ### 
  ### This class is the parent to ComputerGroup, MobileDeviceGroup, UserGroup
  ### and other smart/static group objects in the JSS.
  ###
  ### Subclasses must define the constant MEMBER_CLASS which indicates Ruby class 
  ### to which the group members belong (e.g. JSS::MobileDevice)
  ###
  ### See also JSS::APIObject
  ###
  class Group < JSS::APIObject
    
    #####################################
    ### Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    include JSS::Criteriable
    
        
    #####################################
    ### Class Constants
    #####################################
    
    ### the types of groups allowed for creation
    GROUP_TYPES = [:smart, :static]
    
    #####################################
    ### Class Variables
    #####################################
    
    #####################################
    ### Class Methods
    #####################################
    
    ###
    ### Returns an Array of all the smart
    ### groups.
    ###
    def self.all_smart(refresh = false)
      self.all(refresh).select{|g| g[:is_smart] }
    end
    
    ###
    ### Returns an Array of all the static
    ### groups.
    ###
    def self.all_static(refresh = false)
      self.all(refresh).select{|g| not g[:is_smart] }
    end
    
    #####################################
    ### Attributes
    #####################################
    
    ### :id, :name, :in_jss, :need_to_update, and :rest_rsrc come from JSS::APIObject
    
    ### Array of Hashes. Each hash contains the identifiers for
    ### a member of the group, those being:
    ### :id, :name, and possibly :udid, :serial_number, :mac_address,
    ### :alt_mac_address,  and :wifi_mac_address
    ###
    ### See Also: the instance methods #member_ids, #member_names, etc...
    ###
    attr_reader :members
    
    ### Boolean - is this a smart group
    attr_reader :is_smart
    alias smart? is_smart
    
    ### Boolean - does this group send notifications when it changes?
    attr_reader :notify_on_change
    alias notify_on_change? notify_on_change
    alias notify? notify_on_change
    
    ### Hash, the :name, and :id site for this group
    attr_reader :site
    
    
    #####################################
    ### Constructor
    #####################################
    
    def initialize(args = {})
      
      if args[:id] == :new
        raise JSS::InvalidDataError, "New group creation must specify a :type of :smart or :static" unless GROUP_TYPES.include? args[:type] 
      end

      super args
      
      
      @is_smart = @init_data[:is_smart] || (args[:type] == :smart)
      
      @members = if @init_data[self.class::MEMBER_CLASS::RSRC_LIST_KEY]
        @init_data[self.class::MEMBER_CLASS::RSRC_LIST_KEY] 
      else 
        []
      end
      
      parse_criteria
      
    end #init
    
    #####################################
    ### Public Instance Methods
    #####################################
    
    ###
    ### create a new one in the JSS
    ###
    def create
      if @is_smart
        raise JSS::MissingDataError, "No criteria specified for smart group" unless @criteria
      end
      super
      refresh_members
      return @id
    end
    
    
    ###
    ### Save changes
    ###
    def update
      super
      refresh_members
      true
    end
    
    ###
    ### delete this item from the JSS
    ###
    def delete
      super
      @is_smart = nil
      @criteria = nil
      @site = JSS::NO_SITE
      @members = []
    end # delete
    
    ###
    ### Check for smart before calling super
    ###
    def criteria= (new_criteria)
      raise InvalidDataError, "Only smart groups have criteria." unless @is_smart
      super
    end
    
    ###
    ### how many members of the group?
    ###
    def size
      @members.count
    end
    alias count size
    
    ###
    ### Return an array of the names of mobile_devices in this group
    ### Note: there may be duplicate names!
    ###
    def member_names
      @members.map{|m| m[:name]}
    end
    
    ###
    ### Return an array of the ids of mobile_devices in this group
    ###
    def member_ids
      @members.map{|m| m[:id]}
    end
    
    ###
    ### Replace all @members with an array of uniq device identfiers (names, ids, serial numbers, etc)
    ### E.g: [ 'lambic', 1233, '2341', 'monkey']
    ###
    ### They must all be in the JSS, and non-ambiguous or an error is raised
    ### before doing anything. See #check_member
    ###
    def members= (mds)
      raise UnsupportedError, "Smart group members can't be changed." if @is_smart
      raise InvalidDataError, "Arg must be an array of names and/or ids" unless mds.kind_of? Array
      new_members = []
      mds.each do |m|
        new_members << check_member(m)
      end
      
      ### make sure we've actually changed...
      unless member_ids.sort == new_members.uniq.sort
        @members = new_members
        @need_to_update = true
      end
    end
    
    ###
    ### Add a member, by any identifier
    ###
    def add_member(m)
      raise UnsupportedError, "Smart group members can't be changed." if @is_smart
      @members << {:id => check_member(m)}
      @need_to_update = true
    end
    
    ###
    ### Remove a member by id, or name
    ###
    def remove_member(m)
      raise InvalidDataError, "Smart group members can't be changed." if @is_smart
      
      if @members.reject!{ |mm|  [mm[:id], mm[:name]].include? m  }
        @need_to_update = true
      else
        raise JSS::NoSuchItemError, "No member matches '#{m}'"
      end
    end
    
    ###
    ### Remove all members
    ###
    def clear
      raise InvalidDataError, "Smart group members can't be changed." if @is_smart
      return if @members.empty?
      @members.clear
      @need_to_update = true
    end

    ### 
    ### Refresh the membership from the API
    ###
    def refresh_members
      @members = JSS::API.get_rsrc(@rest_rsrc)[self.class::RSRC_OBJECT_KEY][self.class::MEMBER_CLASS::RSRC_LIST_KEY]
    end
    
    
    #####################################
    ### Public Instance Methods
    #####################################
    private

    ###
    ### Check that a potential group member is valid in the JSS.
    ### Arg must be an id or name.
    ### An error is raised if the device doesn't exist.
    ### Returns the valid id
    ###
    def check_member(m)
      potential_members = self.class::MEMBER_CLASS.map_all_ids_to(:name)
      return m if potential_members.keys.include? m
      return potential_members.invert[m] if potential_members.values.include? m
      raise JSS::NoSuchItemError, "No potential member matching '#{m}' in the JSS."
    end
    
    ###
    ### the xml formated data for adding or updating this in the JSS,
    ###
    def rest_xml
      doc = REXML::Document.new JSS::APIConnection::XML_HEADER
      group = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      group.add_element('id').text = @id
      group.add_element('name').text = @name
      group.add_element('site').add_element('id').text = @site[:id]
      group.add_element('is_smart').text = @is_smart
      if @is_smart
        group << @criteria.rest_xml 
      else
        group << self.class::MEMBER_CLASS.xml_list(@members) 
      end
      
      return doc.to_s
      
    end #rest_xml
    
  end # class ComputerGroup
  
end # module JSS

require "jss/api_object/group/computer_group"
require "jss/api_object/group/mobile_device_group"
require "jss/api_object/group/user_group"

