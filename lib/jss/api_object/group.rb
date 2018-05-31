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
  ### This is the parent class of the smart/static group objects in the JSS
  ### namely, {ComputerGroup}, {MobileDeviceGroup}, and {UserGroup}
  ###
  ### It provides methods for working with the membership of static groups and, by
  ### including {JSS::Criteriable}, the criteria for smart groups.
  ###
  ### When changing the criteria of a smart group, use the #criteria attribute,
  ### which is a {JSS::Criteria} instance.
  ###
  ### Subclasses must define the constant MEMBER_CLASS which indicates Ruby class
  ### to which the group members belong (e.g. JSS::MobileDevice)
  ###
  ### @see JSS::APIObject
  ###
  ### @see JSS::Criteriable
  ###
  class Group < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    include JSS::Criteriable
    include JSS::Sitable


    #####################################
    ### Class Constants
    #####################################

    ### the types of groups allowed for creation
    GROUP_TYPES = [:smart, :static]

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :top

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
    def self.all_smart(refresh = false, api: JSS.api)
      all(refresh, api: api).select{|g| g[:is_smart] }
    end

    ###
    ### Returns an Array of all the static
    ### groups.
    ###
    def self.all_static(refresh = false, api: JSS.api)
      all(refresh, api: api).select{|g| not g[:is_smart] }
    end

    #####################################
    ### Attributes
    #####################################

    ### @return [Array<Hash>] the group membership
    ###
    ### Each hash contains the identifiers for
    ### a member of the group, those being:
    ### - :id, :name, and possibly :udid, :serial_number, :mac_address, :alt_mac_address,  and :wifi_mac_address
    ###
    ### @see #member_ids
    ###
    ### @see #member_names
    ###
    attr_reader :members

    ### @return [Boolean] is this a smart group
    attr_reader :is_smart

    ### @return [Boolean] does this group send notifications when it changes?
    attr_reader :notify_on_change


    ### @return [String] the :name of the site for this group
    attr_reader :site


    #####################################
    ### Constructor
    #####################################

    ###
    ### When creating a new group in the JSS, you must call .new with a :type key
    ### and a value of :smart or :static, as well as a :name and the :id => :new
    ###
    ### @see JSS::APIObject
    ###
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

      @site = JSS::APIObject.get_name(@init_data[:site])

    end #init

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### @see Creatable#create
    ###
    def create(calculate_members: true)
      if @is_smart
        raise JSS::MissingDataError, "No criteria specified for smart group" unless @criteria
      end
      super()
      refresh_members if calculate_members
      return @id
    end


    ###
    ### @see Updatable#update
    ###
    def update
      super
      refresh_members
      true
    end

    ###
    ### @see APIObject#delete
    ###
    def delete
      super
      @is_smart = nil
      @criteria = nil
      @site = nil
      @members = []
    end # delete

    ###
    ### Apply a new set of criteria to a smart group
    ###
    ### @param new_criteria[JSS::Criteria] the new criteria for the smart group
    ###
    def criteria= (new_criteria)
      raise InvalidDataError, "Only smart groups have criteria." unless @is_smart
      super
    end

    ###
    ### How many members of the group?
    ###
    ### @return [Integer] the number of members of the group
    ###
    def size
      @members.count
    end


    ###
    ### @return [Array<String>] the names of the group members
    ###
    def member_names
      @members.map{|m| m[:name]}
    end

    ###
    ### @return [Array<Integer>] the ids of the group members
    ###
    def member_ids
      @members.map{|m| m[:id]}
    end

    ###
    ### Replace all @members with an array of uniq device identfiers (names, ids, serial numbers, etc)
    ### E.g: [ 'lambic', 1233, '2341', 'monkey']
    ###
    ### They must all be in the JSS or an error is raised
    ### before doing anything. See {#check_member}
    ###
    ### @param new_members[Array<Integer,String>] the new group members
    ###
    ### @return [void]
    ###
    def members= (new_members)
      raise UnsupportedError, "Smart group members can't be changed." if @is_smart
      raise InvalidDataError, "Arg must be an array of names and/or ids" unless new_members.kind_of? Array
      ok_members = []
      new_members.each do |m|
        ok_members << check_member(m)
      end

      ok_members.uniq!

      ### make sure we've actually changed...
      unless members.map{|m| m[:id]}.sort == ok_members.map{|m| m[:id]}.sort
        @members = ok_members
        @need_to_update = true
      end
    end

    ###
    ### Add a member, by name or id
    ###
    ### @param m[Integer,String] the id or name of the member to add
    ###
    ### @return [void]
    ###
    def add_member(m)
      raise UnsupportedError, "Smart group members can't be changed." if @is_smart
      @members << check_member(m)
      @need_to_update = true
    end

    ###
    ### Remove a member by id, or name
    ###
    ### @param m[Integer,String] the id or name of the member to remove
    ###
    ### @return [void]
    ###
    def remove_member(m)
      raise InvalidDataError, "Smart group members can't be changed." if @is_smart

      if @members.reject!{ |mm|  [mm[:id], mm[:name], mm[:username]].include? m  }
        @need_to_update = true
      else
        raise JSS::NoSuchItemError, "No member matches '#{m}'"
      end
    end

    ###
    ### Remove all members
    ###
    ### @return [void]
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
    ### @return [Array<Hash>] the refresh membership
    ###
    def refresh_members
      @members = @api.get_rsrc(@rest_rsrc)[self.class::RSRC_OBJECT_KEY][self.class::MEMBER_CLASS::RSRC_LIST_KEY]
    end

    ###
    ### Change the site for this group
    ###
    ### @param new_val[String] the name of the new site
    ###
    ### @return [void]
    ###
    def site= (new_val)
      raise JSS::NoSuchItemError, "No site named #{new_val} in the JSS" unless JSS::Site.all_names(api: @api).include? new_val
      @site = new_val
      @need_to_update = true
    end


    ### aliases

    alias smart? is_smart
    alias notify_on_change? notify_on_change
    alias notify? notify_on_change
    alias count size

    #####################################
    ### Public Instance Methods
    #####################################
    private

    ###
    ### Check that a potential group member is valid in the JSS.
    ### Arg must be an id or name.
    ### An exception is raised if the device doesn't exist.
    ###
    ### @return [Hash{:id=>Integer,:name=>String}] the valid id and name
    ###
    def check_member(m)
      potential_members = self.class::MEMBER_CLASS.map_all_ids_to(:name, api: @api)
      if m.to_s =~ /^\d+$/
        return {:id=>m.to_i, :name=> potential_members[m]} if potential_members.keys.include? m.to_i
      else
        return {:name=>m, :id=> potential_members.invert[m]} if potential_members.values.include? m
      end
      raise JSS::NoSuchItemError, "No #{self.class::MEMBER_CLASS::RSRC_OBJECT_KEY} matching '#{m}' in the JSS."
    end

    ###
    ### the xml formated data for adding or updating this in the JSS,
    ###
    def rest_xml
      doc = REXML::Document.new JSS::APIConnection::XML_HEADER
      group = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      group.add_element('name').text = @name
      group.add_element('is_smart').text = @is_smart
      if @is_smart
        group << @criteria.rest_xml if @criteria
      else
        group << self.class::MEMBER_CLASS.xml_list(@members, :id)
      end

      add_site_to_xml(doc)

      return doc.to_s

    end #rest_xml

  end # class ComputerGroup

end # module JSS

require "jss/api_object/group/computer_group"
require "jss/api_object/group/mobile_device_group"
require "jss/api_object/group/user_group"
