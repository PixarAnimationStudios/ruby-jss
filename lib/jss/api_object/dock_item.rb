### Copyright 2019 Rixar

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

module JSS


  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A Dock Item in the JSS.
  # These are rather simple. They have an ID, name, path, type, and contents which is read-only
  #
  # @see JSS::APIObject
  #
  class DockItem < JSS::APIObject


    # Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable

    # Class Methods
    #####################################

    # Class Constants
    #####################################

    # The Dock Item type
    DOCK_ITEM_TYPE = %w[
      App
      File
      Folder
    ].freeze

    # The base for REST resources of this class
    RSRC_BASE = 'dockitems'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :dock_items

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :dock_item

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    # OBJECT_HISTORY_OBJECT_TYPE = 41

    # Attributes
    #####################################
    attr_reader :id
    attr_reader :name
    attr_reader :type
    attr_reader :path

    # Constructor
    # @see JSS::APIObject.initialize
    #####################################
    def initialize(args = {})
      super args

      @type = 'App' if @init_data[:type].nil?
      @type = @init_data[:type]
      @path = @init_data[:path]
    end

    # Public Instance Methods
    #####################################

    # set the type
    #
    # @param newval[String] the new app type
    #
    # @return [void]
    #
    def type=(newval)
      raise JSS::InvalidDataError, 'Type must be a string' unless newval.is_a? String
      raise JSS::InvalidDataError, "Type must be one of the following: #{DOCK_ITEM_TYPE}; not #{newval}" unless DOCK_ITEM_TYPE.include? newval.to_s

      @type = newval
      @need_to_update = true
    end

    # set the path
    #
    # @param newval[String] the new app path
    def path=(newval)
      raise JSS::InvalidDataError, 'Path must be a String' unless newval.is_a? String

      @path = newval
      @need_to_update = true
    end

      # private instance methods
      ######################
      private

    # the xml formated data for adding or updating this in the JSS
    #
    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      ns = doc.add_element RSRC_OBJECT_KEY.to_s
      ns.add_element('name').text = @name
      ns.add_element('type').text = @type.to_s
      ns.add_element('path').text = @path.to_s
      doc.to_s
    end # rest_xml

    end



end
