# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

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
  ### A Mobile Device group in the JSS
  ###
  ### See also the parent class Jamf::Group
  ###
  ### @see Jamf::APIObject
  ###
  ### @see Jamf::Group
  ###
  class MobileDeviceGroup < Jamf::Group

    #####################################
    ### Mix-Ins
    #####################################
    include Jamf::MDM

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'mobiledevicegroups'

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mobile_device_groups

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mobile_device_group

    ### this allows the parent Group class to do things right
    MEMBER_CLASS = Jamf::MobileDevice

    # the XML element for immediate member additions via PUT
    ADD_MEMBERS_ELEMENT = 'mobile_device_additions'.freeze

    # the XML element for immediate member removals via PUT
    REMOVE_MEMBERS_ELEMENT = 'mobile_device_deletions'.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 25

    # what kind of devices are these WRT MDM
    MDM_COMMAND_TARGET = :mobiledevicegroups

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Attributes
    #####################################

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### Return an array of the udids of mobile_devices in this group
    ###
    ### @return [Array<String>] the member udids
    ###
    def member_udids
      @members.map { |m| m[:udid] }
    end

    ###
    ### Return an array of the serial numbers of mobile_devices in this group
    ###
    ### @return [Array<String>] the member serial numbers
    ###
    def member_serial_numbers
      @members.map { |m| m[:serial_number] }
    end

    ###
    ### Return an array of the mac_addrs of mobile_devices in this group
    ###
    ### @return [Array<String>] the member mac addresses
    ###
    def member_mac_addresses
      @members.map { |m| m[:mac_address] }
    end

    ###
    ### Return an array of the wifi mac_addrs of mobile_devices in this group
    ###
    ### @return [Array<String>] the member wifi mac addresses
    ###
    def member_wifi_mac_addresses
      @members.map { |m| m[:wifi_mac_address] }
    end

    #####################################
    ### Private Instance Methods
    #####################################

  end # class ComputerGroup

end # module
