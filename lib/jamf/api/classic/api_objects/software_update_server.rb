### Copyright 2022 Pixar

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
    RSRC_BASE = "softwareupdateservers"

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
    def initialize (args = {})
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
