# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # Classes
  #####################################

  # A computer group in the JSS
  #
  # See also the parent class Jamf::Group
  #
  # @see Jamf::APIObject
  #
  # @see Jamf::Group
  #
  class ComputerGroup < Jamf::Group

    # Mix-Ins
    #####################################
    include Jamf::MDM
    include Jamf::MacOSManagedUpdates
    include Jamf::MacOSRedeployMgmtFramework

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'computergroups'

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :computer_groups

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :computer_group

    # this allows the parent Group class to do things right
    MEMBER_CLASS = Jamf::Computer

    # the XML element for immediate member additions via PUT
    ADD_MEMBERS_ELEMENT = 'computer_additions'.freeze

    # the XML element for immediate member removals via PUT
    REMOVE_MEMBERS_ELEMENT = 'computer_deletions'.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 7

    # what kind of devices are these WRT MDM
    MDM_COMMAND_TARGET = :computergroups

    # Public Instance Methods
    #####################################

    #
    # The serial numbers of members in this group
    #
    # @return [Array<String>] the member serial numbers
    #
    def member_serial_numbers
      @members.map { |m| m[:serial_number] }
    end

    #
    # Return an array of the mac_addrs of members in this group
    #
    # @return [Array<String>] the member mac addresses
    #
    def member_mac_addresses
      @members.map { |m| m[:mac_address] } + @members.map { |m| m[:alt_mac_address] }
    end

  end # class ComputerGroup

end # module
