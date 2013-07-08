# = db_connection.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A Class representing a Computer Group in the JSS. Note that SmartGroups are not currently editable
# via this Class.
#

module PixJSS
  
  #####################################
  # Module Items related to computer groups
  #####################################
  
  #####################################
  # Constants
  #####################################  
  
  # The computer groups table in the JSS
  COMPUTER_GROUPS_TABLE = "computer_groups"
  
  # The computers table in the JSS
  COMPUTER_GROUP_MEMBERSHIPS_TABLE = "computer_group_memberships"
  
  # A mapping of symbols to field names in the computer_groups table
  COMPUTER_GROUP_ATTRS_TO_JSS_FIELDS = {
    :id => 'computer_group_id',
    :name => 'computer_group_name',
    :is_smart => 'is_smart_group',
    :live_lookup => 'requires_live_lookup',
    :notify => 'notify_on_change'
  }
  
  # A shorter but less descriptive name for the COMPUTER_GROUP_ATTRS_TO_JSS_FIELDS constant
  CGMAP = COMPUTER_GROUP_ATTRS_TO_JSS_FIELDS
  
  # A mapping of symbols to field names in the computer_group_memberships table
  COMPUTER_GROUP_MEMBERSHIP_ATTRS_TO_JSS_FIELDS = {
    :gid => 'computer_group_id',
    :cid => 'computer_id'
  }
  
  # A shorter but less descriptive name for the COMPUTER_GROUP_MEMBERSHIP_ATTRS_TO_JSS_FIELDS constant
  CGM_MAP = COMPUTER_GROUP_MEMBERSHIP_ATTRS_TO_JSS_FIELDS
  
  #####################################
  # Module Variables
  ##################################### 
  
    
  ### Stores a hash of all computer groups in the JSS keyed by names
  ### values are another hash, with two keys :smart, and :id
  ### Access is via the computer_groups module method
  @@computer_groups = nil
  
  
  #####################################
  # Module Methods
  ##################################### 
  
  ###
  ### Return an hash of all computer groups in the JSS keyed by names.
  ### values are another hash, with two keys :smart, and :id
  ###
  ### NOTE this isn't an arry or hash of ComputerGroup objects
  ### since it would be slow to generate that when all we want is the names
  ### & basic info. 
  ### If you want the objects, use the keys from this to generate them as needed
  ###
  def computer_groups(refresh = nil)
    @@computer_groups = nil if refresh
    return @@computer_groups if @@computer_groups
    
    @@computer_groups = {}
    check_connection
    
    REST_CNX.get_rsrc('computergroups')[:computer_groups][:computer_group].each do |cg|
      @@computer_groups[cg[:name]] = {}
      @@computer_groups[cg[:name]][:smart] = cg[:is_smart]
      @@computer_groups[cg[:name]][:id] = cg[:id]
      
    end
    @@computer_groups
  end # def computer_groups
  
  
  #####################################
  # Classes
  ##################################### 
  
  
  ### 
  ### A computer group in the JSS
  ###
  class JSSComputerGroup
    include PixJSS

    # String - name of the Computer Group in the jss
    attr_reader :name
    
    # Integer or nil - the id of this computer group in the JSS
    attr_reader :jss_id
    alias id jss_id
    
    # Hash - the ids (keys) and names of the computers in this group
    attr_reader :members
    alias membership members
    
    
    # FixNum - how many computers in this group?
    attr_reader :size
    alias count size
    
    # Boolean - is this a smart group
    attr_reader :is_smart
    alias smart? is_smart
    
    # Hash - the criteria for a smart group (not currently supported)
    attr_reader :criteria
    
    ###
    ### For initialization, the arg is the group name 
    ### If the group exists in the jss, its data is queried from the JSS
    ### Otherwise it is instantiated with no members.  
    ### Use the "members=" method to set an array of 
    ### group members, or the "add_computer(name)" to append a single computer.
    ### Use add_to_jss, update_jss, or delete_from_jss to save your
    ### changes to the server
    ###
    def initialize(name)
    
      raise MissingDataError, "Computer groups must have names" unless name
      @name = name
      @rest_rsrc = URI::encode "computergroups/name/#{name}"
      @members = {}
      @is_smart = false
      @criteria = nil
      @jss_id = nil
      
      # If this group is in the jss, get all the data from there
      if PixJSS.computer_groups(:refresh).keys.include? name
        
        # If this group 
        # look up the data
        group_data = PixJSS::RESTConnection.instance.get_rsrc(@rest_rsrc)[:computer_group]

        @is_smart = group_data[:is_smart]
        @criteria = group_data[:criteria]
        @jss_id = group_data[:id]
        @rest_rsrc = URI::encode "computergroups/id/#{@jss_id}"
        
        # if the group has members, add them to computer_names
        if group_data[:computers][:size] > 1 
            group_data[:computers][:computer].each {|member| @members[member[:id].to_i] = member[:name]}
        
        elsif group_data[:computers][:size] == 1
            @members[group_data[:computers][:computer][:id].to_i] = group_data[:computers][:computer][:name]
        end #  if group_data[:computers][:size] > 1 
        
      end # if PixJSS.computer_groups.include? name
      
      @size = @members.count
      @name_changed = false
      @membership_changed = false
      @saved_members = @members.dup
    end #init
    
    ###
    ### Return an array of the names of computers in this group
    ### Note: there may be duplicate names!
    ###
    def computer_names
      @members.values
    end
    
    ###
    ### Return an array of the ids of computers in this group
    ###
    def computer_ids
      @members.keys
    end
    
    ###
    ### Change the name of this group
    ###
    def name=(newname)
      @name = newname
      @rest_rsrc = URI::encode "computergroups/name/#{newname}" unless @jss_id
      @name_changed = true
    end
    
    ###
    ### Replace all @members with an array computer names or ids
    ### E.g: [ 'lambic', 1233, '2341', 'monkey']
    ###
    ### They must all be in the JSS, and non-ambiguous or an error is raised
    ### before doing anything. 
    ###
    def members=(comps)
      raise InvalidTypeError, "Smart group members can't be changed." if @is_smart
      raise InvalidTypeError, "Arg must be an array of names and/or ids" unless comps.class == Array
      
      new_members = {}
      comps.each do |comp|
        (id,name) = check_computer(comp)
        new_members[id.to_i] = name
      end
      
      # make sure we've actually changed...
      unless @members.keys.uniq.sort == new_members.keys.uniq.sort
        @members = new_members
        @membership_changed = true
      end
      @size = @members.count
    end
    
    
    ###
    ### Add a member, by name or id
    ###
    def add_computer(comp)
      raise InvalidTypeError, "Smart group members can't be changed." if @is_smart
      comp = comp.to_s
      
      (id,name) = check_computer(comp)

      unless @members.keys.include? id
        @members[id.to_i] = name
        @membership_changed = true
      end
      @size = @members.count
    end
    
    ###
    ### Remove a member
    ###
    def remove_computer(comp)
      raise InvalidTypeError, "Smart group members can't be changed." if @is_smart
      
      # is it all digits? if so, its an id
      if comp.to_s =~ /^\d+$/
        comp = comp.to_i
        raise NoSuchItemError, "Computer id #{comp} is not a member of group '#{@name}'" unless @members.keys.include? comp
        @members.delete comp
      else
        raise NoSuchItemError, "Computer '#{comp}' is not a member of group '#{@name}'" unless  @members.values.include? comp
        @members.delete_if {|key, value| value == comp } 
      end
      @membership_changed = true
      @size = @members.count
    end
    
    ###
    ### Remove all members
    ###
    def clear
      raise InvalidTypeError, "Smart group members can't be changed." if @is_smart
      return if @members.empty?
      @members.clear
      @membership_changed = true
      @size = @members.count
    end
    
    ###
    ### add this group to the JSS 
    ###
    def save
      raise AlreadyExistsError, "Computer Group '#{@name}' already in JSS, use #update."  if @jss_id
      
      # using REST is incredibly slow, so we'll do it directly in the DB
      # (at the risk of breaking when we update casper)
      #
      # rest_reply = PixJSS::RESTConnection.instance.post_rsrc( :rsrc => @rest_rsrc, :xml => rest_xml )
      # rest_reply =~ /<id>(\d+)<\/id>/
      # @jss_id = $1.to_i
      # @rest_rsrc = URI::encode "computergroups/id/#{@jss_id}"
      
      insert = @@db_cnx.prepare "INSERT INTO #{PixJSS::COMPUTER_GROUPS_TABLE} (#{PixJSS::CGMAP[:name]}) VALUES ('#{@name}')"
      insert.execute
      @name_changed = false
      
      @jss_id = insert.insert_id
      @rest_rsrc = URI::encode "computergroups/id/#{@jss_id}"
      
      set_membership
      @membership_changed = false
      
    end # add
    
    ###
    ### delete this group from the JSS
    ###
    def delete
      raise NoSuchItemError, "Computer Group '#{@name}' not in JSS, can't delete."  unless @jss_id
      PixJSS::RESTConnection.instance.delete_rsrc(@rest_rsrc)
      @jss_id = nil
      @rest_rsrc = URI::encode "computergroups/name/#{@name}"
    end # delete
    
    ###
    ### update this group in the JSS with current object state
    ###
    def update
      raise NoSuchItemError, "Computer Group '#{@name}' not in JSS, can't update."  unless @jss_id
      
      # Updating via rest is broken in casper 8.4.3. JAMF software defect #D-002649 
      # PixJSS::RESTConnection.instance.put_xml( :rsrc => @rest_rsrc, :xml => rest_xml )
      
      if @name_changed
        name_qry = @@db_cnx.prepare "UPDATE #{PixJSS::COMPUTER_GROUPS_TABLE} SET #{PixJSS::CGMAP[:name]} = '#{@name}' WHERE #{PixJSS::CGMAP[:id]} = '#{@jss_id}'"
        name_qry.execute
        @name_changed = false
      end
      
      if @membership_changed
        set_membership
        @membership_changed = false
      end
      return nil
    end # update
    
    
    ######################
    # private methods
    private

    ###
    ### Check that a computer is valid in the JSS
    ### Arg must be either either a computer name or id
    ### An error is raised if the computer doesn't exist or is ambiguous
    ### return an array of [id, name]
    ###
    def check_computer(comp)
      comp = comp.to_s
      
      # is it all digits? if so, its an id
      if comp =~ /^\d+$/
        raise PixJSS::NoSuchItemError, "Computer id #{comp} isn't in the JSS." unless PixJSS.computers.keys.include? comp
        return [comp, PixJSS.computers[comp]]
      else
        raise PixJSS::NoSuchItemError, "Computer '#{comp}' isn't in the JSS." unless PixJSS.computers.values.include? comp
        raise "Multiple computers named '#{comp}' in the JSS. Use :id instead" if PixJSS.computers.values.count(comp) > 1
        return [PixJSS.computers.invert[comp], comp]
      end
      
    end
    
    ###
    ### set the membership of a group in the JSS to the contents of @members
    ###
    def set_membership
      
      # get a lock on the membership table
      lock = @@db_cnx.query "LOCK TABLES #{PixJSS::COMPUTER_GROUP_MEMBERSHIPS_TABLE} WRITE"
      
      # first delete those being deleted
      # @saved.keys - @members.keys = those needing to be removed
      those_to_delete = @saved_members.keys - @members.keys
      unless those_to_delete.empty?
        del_qry = @@db_cnx.prepare "DELETE FROM #{PixJSS::COMPUTER_GROUP_MEMBERSHIPS_TABLE} WHERE #{PixJSS::CGM_MAP[:gid]} = #{@jss_id} AND #{PixJSS::CGM_MAP[:cid]} IN (#{those_to_delete.join(',')}) "
        del_qry.execute
      end
      
      # then add the new ones
      # @members.keys - @saved.keys = those needing to be added
      those_to_add = @members.keys - @saved_members.keys
      unless those_to_add.empty?
        those_to_add.map! {|id| "(#{@jss_id},#{id})" }
        add_qry = @@db_cnx.prepare "INSERT INTO #{PixJSS::COMPUTER_GROUP_MEMBERSHIPS_TABLE} (#{PixJSS::CGM_MAP[:gid]}, #{PixJSS::CGM_MAP[:cid]}) VALUES #{those_to_add.join(',')}"
        add_qry.execute
      end
      
      unlock =  @@db_cnx.query "UNLOCK TABLES"
      @saved_members = @members.dup
    end
    
    ###
    ### the xml formated data for adding or updating this in the JSS,
    ### Not Used for now...
    ### Updating via rest is broken in casper 8.4.3. JAMF software defect #D-002649 
    ###
    def rest_xml
    
      computers_xml = "\n"
      
      @members.each do |id,c|
        computers_xml += <<-ENDCOMPXML
    <computer>
      <id>#{PixJSS.computers[c]}</id>
    </computer>
ENDCOMPXML
      end
      
      
      xml_payload = <<-ENDXML 
#{REST_XML_HEADER}
<computer_group>
  <name>#{@name}</name>
  <computers>#{computers_xml}  </computers>
</computer_group>
ENDXML

      return xml_payload 
    end #rest_xml
    
  end # class JSSComputerGroup
end # module