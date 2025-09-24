# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

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
  ### A removable_macaddr in the JSS
  ###
  ### These are simple, in that they only have an ID and a name
  ###
  ### @see Jamf::APIObject
  ###
  class RemovableMacAddress < Jamf::APIObject

    #####################################
    ### Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'removablemacaddresses'

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :removable_mac_addresses

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :removable_mac_address

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 77

    #####################################
    ### Attributes
    #####################################

    #####################################
    ### Constructor
    #####################################

    ###
    ### See Jamf::APIObject#initialize
    ###

    #####################################
    ### Public Instance Methods
    #####################################

    alias macaddress name
    alias mac_address name

  end # class removable_macaddr

end # module
