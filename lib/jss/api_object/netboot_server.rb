### Copyright 2019 Pixar

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
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Classes
  #####################################

  ###
  ### A NetBoot Server in the JSS
  ###
  ###
  ### Only minimally implemented, mostly for access to the APIObject list methods
  ###
  ### @see JSS::APIObject
  ###
  class NetBootServer < JSS::APIObject

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
    RSRC_BASE = "netbootservers"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :netboot_servers

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :netboot_server

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:protocol, :boot_args]

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 81

    #####################################
    ### Attributes
    #####################################

    ### @return [String]  the nvram/bless args
    attr_reader :boot_args

    ### @return [String]  the nvram/bless args
    attr_reader :boot_device

    ### @return [String]  the nvram/bless args
    attr_reader :boot_file

    ### @return [Boolean]
    attr_reader :configure_manually

    ### @return [boolean] is this one default?
    attr_reader :default_image

    ### @return [String]  the actual dmg name , eg "NetBoot.dmg"
    attr_reader :image

    ### @return [String] the server's IP address
    attr_reader :ip_address

    ### @return [String]  "nfs" or "http"
    attr_reader :protocol

    ### @return [String]  the nbi folder "MetroNB-test-10.9.3-1063.nbi"
    attr_reader :set

    ### @return [String]  the tftp/protocol sharepoint name, usually "NetBootSP0"
    attr_reader :share_point

    ### @return [Boolean]
    attr_reader :specific_image

    ### @return [String]  e.g."Intel/x86"
    attr_reader :target_platform


    #####################################
    ### Constructor
    #####################################

    ###
    ### See JSS::APIObject#initialize
    ###

    def initialize (args = {})
      super
      @boot_args = @init_data[:boot_args]
      @boot_device = @init_data[:boot_device]
      @boot_file = @init_data[:boot_file]
      @configure_manually = @init_data[:configure_manually]
      @default_image = @init_data[:default_image]
      @image = @init_data[:image]
      @ip_address = @init_data[:ip_address]
      @protocol = @init_data[:protocol]
      @set = @init_data[:set]
      @share_point = @init_data[:share_point]
      @specific_image = @init_data[:specific_image]
      @target_platform = @init_data[:target_platform]

    end

    #####################################
    ### Public Instance Methods
    #####################################


  end # class NetbootServer

end # module
