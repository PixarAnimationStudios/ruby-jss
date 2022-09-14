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
