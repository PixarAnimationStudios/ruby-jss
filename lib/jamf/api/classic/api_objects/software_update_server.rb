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
  ### A Software Update Server in the JSS
  ###
  ### Only minimally implemented, for access to the APIObject list methods
  ###
  ### @see Jamf::APIObject
  ###
  class SoftwareUpdateServer < Jamf::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'softwareupdateservers'

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :software_update_servers

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :software_update_server

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 82

    #####################################
    ### Attributes
    #####################################

    ### @return [String]
    attr_reader :ip_address

    ### @return [Integer]
    attr_reader :port

    ### @return [Boolean]
    attr_reader :set_system_wide

    #####################################
    ### Constructor
    #####################################

    ###
    ### @see SS::APIObject#initialize
    ###
    def initialize(**args)
      super
      @ip_address = @init_data[:ip_address]
      @port = @init_data[:port]
      @set_system_wide = @init_data[:set_system_wide]
    end

    #####################################
    ### Public Instance Methods
    #####################################

  end # class NetbootServer

end # module
