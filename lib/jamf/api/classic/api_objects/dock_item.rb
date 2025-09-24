# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A Dock Item in the JSS.
  # These are rather simple. They have an ID, name, path, type, and contents which is read-only
  #
  # @see Jamf::APIObject
  #
  class DockItem < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable

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
    attr_reader :name, :type, :path

    # Constructor
    # @see Jamf::APIObject.initialize
    #####################################
    def initialize(**args)
      super

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
      raise Jamf::InvalidDataError, 'Type must be a string' unless newval.is_a? String
      raise Jamf::InvalidDataError, "Type must be one of the following: #{DOCK_ITEM_TYPE}; not #{newval}" unless DOCK_ITEM_TYPE.include? newval.to_s

      @type = newval
      @need_to_update = true
    end

    # set the path
    #
    # @param newval[String] the new app path
    def path=(newval)
      raise Jamf::InvalidDataError, 'Path must be a String' unless newval.is_a? String

      @path = newval
      @need_to_update = true
    end

    # private instance methods
    ######################
    private

    # the xml formated data for adding or updating this in the JSS
    #
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      ns = doc.add_element RSRC_OBJECT_KEY.to_s
      ns.add_element('name').text = @name
      ns.add_element('type').text = @type.to_s
      ns.add_element('path').text = @path.to_s
      doc.to_s
    end # rest_xml

  end

end
