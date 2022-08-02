# Copyright 2022 Pixar

#
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

  # Classes
  #####################################

  # This is the parent class of the smart/static group objects in the JSS
  # namely, {ComputerGroup}, {MobileDeviceGroup}, and {UserGroup}
  #
  # It provides methods for working with the membership of static groups and, by
  # including {Jamf::Criteriable}, the criteria for smart groups.
  #
  # When changing the criteria of a smart group, use the #criteria attribute,
  # which is a {Jamf::Criteria} instance.
  #
  # Subclasses must define these constants:
  # - MEMBER_CLASS: the ruby-jss class to which the group
  #   members belong (e.g. Jamf::MobileDevice)
  # - ADD_MEMBERS_ELEMENT: the XML element tag for adding members to the group
  #   wuth a PUT call to the API, e.g. 'computer_additions'
  # - REMOVE_MEMBERS_ELEMENT: the XML element tag for removing members from the
  #   group wuth a PUT call to the API, e.g. 'computer_deletions'
  #
  # @see Jamf::APIObject
  #
  # @see Jamf::Criteriable
  #
  class Group < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Criteriable
    include Jamf::Sitable

    # Class Constants
    #####################################

    # the types of groups allowed for creation
    GROUP_TYPES = %i[smart static].freeze

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :top

    # the 'id' xml element tag
    ID_XML_TAG = 'id'.freeze

    # Class Methods
    #####################################

    # Returns an Array of all the smart
    # groups.
    #
    def self.all_smart(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).select { |g| g[:is_smart] }
    end

    # Returns an Array of all the static
    # groups.
    #
    def self.all_static(refresh = false, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all(refresh, cnx: cnx).reject { |g| g[:is_smart] }
    end

    # Immediatly add and/or remove members in a static group without
    # instantiating it first. Uses the <x_additions> and <x_deletions>
    # XML elements available when sending a PUT request to the API.
    #
    # @param group [String, Integer] The name or id of the group being changed
    #
    # @param add_members [String, Integer, Array<String, Integer>] valid
    #   identifier(s) for members to add
    #
    # @param remove_members [String, Integer, Array<String, Integer>] valid
    #   identifier(s) for members to remove
    #
    # @param cnx [Jamf::Connection] The API connetion to use, uses the default
    #   connection if not specified
    #
    # @return [void]
    #
    def self.change_membership(group, add_members: [], remove_members: [], api: nil, cnx: Jamf.cnx)
      cnx = api if api

      raise Jamf::NoSuchItemError, "No #{self} matching '#{group}'" unless (group_id = valid_id group, cnx: cnx)
      raise Jamf::UnsupportedError, "Not a static group, can't change membership" if map_all(:id, to: :is_smart, cnx: cnx)[group_id]

      add_members = [add_members].flatten
      remove_members = [remove_members].flatten
      return if add_members.empty? && remove_members.empty?

      # we must know the current group membership, because the API
      # will raise a conflict error if we try to remove a member
      # that isn't in the group (which is kinda lame - it should just
      # ignore this, like it does when we add a member that's already
      # in the group.)
      # Its even more lame because we have to instantiate the group
      # and part of the point of this class method is to avoid that.
      current_member_ids = fetch(id: group_id, cnx: cnx).member_ids

      # nil if no changes to be made
      xml_doc = change_membership_xml add_members, remove_members, current_member_ids
      return unless xml_doc

      cnx.c_put "#{self::RSRC_BASE}/id/#{group_id}", xml_doc.to_s
    end

    # return [REXML::Document, nil]
    #
    def self.change_membership_xml(add_members, remove_members, current_member_ids)
      # these are nil if there are no changes to make
      addx = member_additions_xml(add_members, current_member_ids)
      remx = member_removals_xml(remove_members, current_member_ids)
      return nil unless addx || remx

      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      groupelem = doc.add_element self::RSRC_OBJECT_KEY.to_s
      groupelem << addx if addx
      groupelem << remx if remx
      doc
    end
    private_class_method :change_membership_xml

    # @return [REXML::Element, nil]
    #
    def self.member_additions_xml(add_members, current_member_ids)
      return nil if add_members.empty?

      additions = REXML::Element.new self::ADD_MEMBERS_ELEMENT
      member_added = false
      add_members.each do |am|
        am_id = self::MEMBER_CLASS.valid_id am
        raise Jamf::NoSuchItemError, "No #{self::MEMBER_CLASS} matching '#{am}'" unless am_id
        next if current_member_ids.include? am_id

        xam = additions.add_element self::MEMBER_CLASS::RSRC_OBJECT_KEY.to_s
        xam.add_element(ID_XML_TAG).text = am_id.to_s
        member_added = true
      end # each

      member_added ? additions : nil
    end
    private_class_method :member_additions_xml

    # @return [REXML::Element, nil]
    #
    def self.member_removals_xml(remove_members, current_member_ids)
      return nil if remove_members.empty?

      removals = REXML::Element.new self::REMOVE_MEMBERS_ELEMENT
      member_removed = false
      remove_members.each do |rm|
        rm_id = self::MEMBER_CLASS.valid_id rm
        next unless rm_id && current_member_ids.include?(rm_id)

        xrm = removals.add_element self::MEMBER_CLASS::RSRC_OBJECT_KEY.to_s
        xrm.add_element(ID_XML_TAG).text = rm_id.to_s
        member_removed = true
      end # each

      member_removed ? removals : nil
    end
    private_class_method :member_removals_xml

    # Attributes
    #####################################

    # @return [Array<Hash>] the group membership
    #
    # Each hash contains the identifiers for
    # a member of the group, those being:
    # - :id, :name, and possibly :udid, :serial_number, :mac_address, :alt_mac_address,  and :wifi_mac_address
    #
    # @see #member_ids
    #
    # @see #member_names
    #
    attr_reader :members

    # @return [Boolean] is this a smart group
    attr_reader :is_smart
    alias smart? is_smart

    # @return [Boolean] does this group send notifications when it changes?
    attr_reader :notify_on_change
    alias notify_on_change? notify_on_change
    alias notify? notify_on_change

    # Constructor
    #####################################

    # When creating a new group in the JSS, you must call .make with a :type key
    # and a value of :smart or :static, as well as a :name
    #
    # @see Jamf::APIObject
    #
    def initialize(**args)
      raise Jamf::InvalidDataError, 'New group creation must specify a :type of :smart or :static' if args[:id] == :new && !(GROUP_TYPES.include? args[:type])

      super

      @is_smart = @init_data[:is_smart] || (args[:type] == :smart)

      @members =
        @init_data[self.class::MEMBER_CLASS::RSRC_LIST_KEY] || []
    end # init

    # Public Instance Methods
    #####################################

    # @see Creatable#create
    #
    # @param calculate_members [Boolan] should the local membership list be
    #   re-read from the API after the group is created?
    #
    # @param retries [Integer] If calculate_members is true, refetching the
    #   group to re-read the membership can happen too fast, the JSS won't know
    #   it exists yet and will throw a NoSuchItem error.  If that
    #   happens, try again this many times with a 1 second pause between attempts.
    #
    def create(calculate_members: true, retries: 10)
      raise Jamf::MissingDataError, 'No criteria specified for smart group' if @is_smart && !@criteria

      super()

      if calculate_members
        tries = 0
        while tries < retries
          begin
            refresh_members
            break
          rescue
            sleep 1
            tries += 1
          end # begin
        end # while
      end # if calc members

      @id
    end

    # @see Updatable#update
    #
    def update(refresh: true)
      super()
      refresh_members if refresh
      @id
    end

    # Wrapper/alias for both create and update
    def save(**params)
      params[:calculate_members] = true if params[:calculate_members].nil?
      params[:retries] = 10 if params[:retries].nil?
      params[:refresh] = true if params[:refresh].nil?

      if @in_jss
        raise Jamf::UnsupportedError, 'Updating this object in the JSS is currently not supported by ruby-jss' unless updatable?

        update refresh: params[:refresh]
      else
        raise Jamf::UnsupportedError, 'Creating this object in the JSS is currently not supported by ruby-jss' unless creatable?

        create calculate_members: params[:calculate_members], retries: params[:retries]
      end
    end

    # @see APIObject#delete
    #
    def delete
      super
      @is_smart = nil
      @criteria = nil
      @site = nil
      @members = []
    end # delete

    # Apply a new set of criteria to a smart group
    #
    # @param new_criteria[Jamf::Criteria] the new criteria for the smart group
    #
    def criteria=(new_criteria)
      raise InvalidDataError, 'Only smart groups have criteria.' unless @is_smart

      super
    end

    # Change static group to smart group
    #
    # @param args[Hash] the options and settings use for switching the computer group from static group to smart group
    #
    # @option args criteria[Array] The criteria to be user for the smart group
    #
    # @return [void]
    def make_smart(**params)
      return if @is_smart

      params[:criteria] = [] if params[:criteria].nil?

      criteria = params[:criteria]

      @is_smart = true
      @need_to_update = true
    end
    # backward compatility
    alias set_smart make_smart

    # Change smart group to static group
    #
    # @param args[Hash] the options and settings use for switching the computer group from smart group to static group
    #
    # @option args preserve_members[Boolean] Should the smart group preserve it's current members?
    #
    # @return [void]
    def make_static(**params)
      return unless @is_smart

      preserve_members = params.include? :preserve_members

      @is_smart = false

      clear unless preserve_members
    end
    # backward compatility
    alias set_static make_static
        
    # How many members of the group?
    #
    # @return [Integer] the number of members of the group
    #
    def size
      @members.count
    end
    alias count size

    # @return [Boolean] Is this a static group?
    def static?
      !smart?
    end
    alias is_static static?

    # @return [Array<String>] the names of the group members
    #
    def member_names
      @members.map { |m| m[:name] }
    end

    # @return [Array<Integer>] the ids of the group members
    #
    def member_ids
      @members.map { |m| m[:id] }
    end

    # Replace all @members with an array of uniq device identfiers (names, ids, serial numbers, etc)
    # E.g: [ 'lambic', 1233, '2341', 'monkey']
    #
    # They must all be in the JSS or an error is raised
    # before doing anything. See {#check_member}
    #
    # @param new_members[Array<Integer,String>] the new group members
    #
    # @return [void]
    #
    def members=(new_members)
      raise UnsupportedError, "Smart group members can't be changed." if @is_smart
      raise InvalidDataError, 'Arg must be an array of names and/or ids' unless new_members.is_a? Array

      ok_members = []
      new_members.each do |m|
        ok_members << check_member(m)
      end

      ok_members.uniq!

      # make sure we've actually changed...
      return if members.map { |m| m[:id] }.sort == ok_members.map { |m| m[:id] }.sort

      @members = ok_members
      @need_to_update = true
    end

    # Add a member, by name or id
    #
    # @param m[Integer,String] the id or name of the member to add
    #
    # @return [void]
    #
    def add_member(mem)
      raise UnsupportedError, "Smart group members can't be changed." if smart?

      @members << check_member(mem)
      @need_to_update = true
    end

    # Remove a member by id, or name
    #
    # @param m[Integer,String] an identifier for the item to remove
    #
    # @return [void]
    #
    def remove_member(mem)
      raise UnsupportedError, "Smart group members can't be changed." if smart?

      # See if we have the identifier in the @members hash
      id_to_remove = @members.select { |mm| mm.values.include? mem }.first&.dig :id
      # But the members hash might not have SN, macaddr, etc, and never has udid, so
      # look at the MEMBER_CLASS if needed
      id_to_remove ||= self.class::MEMBER_CLASS.valid_id mem

      # nothing to do if that id isn't one of our members
      return unless id_to_remove && member_ids.include?(id_to_remove)

      @members.delete_if { |k, v| k == :id && v == id_to_remove }
      @need_to_update = true 
    end

    # Remove all members
    #
    # @return [void]
    #
    def clear
      raise InvalidDataError, "Smart group members can't be changed." if @is_smart
      return if @members.empty?

      @members.clear
      @need_to_update = true
    end

    # Immediatly add and/or remove members in this static group
    #
    # IMPORTANT: This method changes the group in the JSS immediately,
    #   there is no need to call #update/#save
    #
    # @param add_members [String, Integer, Array<String, Integer>] valid
    #   identifier(s) for members to add
    #
    # @param remove_members [String, Integer, Array<String, Integer>] valid
    #   identifier(s) for members to remove
    #
    # @param cnx [Jamf::Connection] The API connetion to use, uses the default
    #   connection if not specified
    #
    # @return [void]
    #
    def change_membership(add_members: [], remove_members: [])
      self.class.change_membership(@id, add_members: add_members, remove_members: remove_members, cnx: @cnx)
      refresh_members
    end

    # Refresh the membership from the API
    #
    # @return [Array<Hash>] the refresh membership
    #
    def refresh_members
      @members = @cnx.c_get(@rest_rsrc)[self.class::RSRC_OBJECT_KEY][self.class::MEMBER_CLASS::RSRC_LIST_KEY]
    end
  

    # Public Instance Methods
    #####################################
    private

    # Check that a potential group member is valid in the JSS.
    # Arg must be an id or name.
    # An exception is raised if the device doesn't exist.
    #
    # @return [Hash{:id=>Integer,:name=>String}] the valid id and name
    #
    def check_member(m)
      desired_id = self.class::MEMBER_CLASS.valid_id m, cnx: @cnx
      raise Jamf::NoSuchItemError, "No #{self.class::MEMBER_CLASS::RSRC_OBJECT_KEY} matching '#{m}' in the JSS." unless desired_id

      desired_name = self.class::MEMBER_CLASS.map_all(:id, to: :name, cnx: @cnx)[desired_id]

      { name: desired_name, id: desired_id }      
    end

    # the xml formated data for adding or updating this in the JSS,
    #
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      group = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      group.add_element('name').text = @name
      group.add_element('is_smart').text = @is_smart
      if @is_smart
        group << @criteria.rest_xml if @criteria
      else
        group << self.class::MEMBER_CLASS.xml_list(@members, :id)
      end

      add_site_to_xml(doc)

      doc.to_s
    end # rest_xml

  end # class ComputerGroup

end # module Jamf
