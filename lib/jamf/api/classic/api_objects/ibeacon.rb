# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # An iBeacon in the JSS.
  # @see Jamf::APIObject
  #
  class IBeacon < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable

    # Class Methods
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'ibeacons'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :ibeacons

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :ibeacon

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 360

    # The major & minor values, if used, must be in this range
    MAJOR_MINOR_RANGE = 0..65_535

    # If not used, this is the value for the major and minor
    MAJOR_MINOR_UNUSED = -1

    # Attributes
    #####################################

    ### @return [String] the top-level region identifier, a valid UUID
    attr_reader :uuid

    ### @return [IPAddr] the mid-level region identifier,
    # an integer within MAJOR_MINOR_RANGE or MAJOR_MINOR_UNUSED
    attr_reader :major

    ### @return [IPAddr] the low-level region identifier,
    # an integer within MAJOR_MINOR_RANGE or MAJOR_MINOR_UNUSED
    attr_reader :minor

    # Constructor
    # @see Jamf::APIObject.initialize
    #####################################
    def initialize(**args)
      super

      @uuid = @init_data[:uuid]
      @major = @init_data[:major]
      @minor = @init_data[:minor]

      # defaults
      @major ||= MAJOR_MINOR_UNUSED
      @minor ||= MAJOR_MINOR_UNUSED
    end # init

    # Public Instance Methods
    #####################################

    # set the uuid
    #
    # @param newval[String] the new uuid
    #
    # @return [void]
    #
    def uuid=(newval)
      Jamf::Validate.uuid newval
      @uuid = newval
      @need_to_update = true
    end

    # Set the major value to for this iBeacon region.
    # Use nil or -1 to not use the major value
    #
    # @param newval[String] the new value
    #
    # @return [void]
    #
    def major=(newval)
      if newval.nil? || newval == MAJOR_MINOR_UNUSED
        newval ||= MAJOR_MINOR_UNUSED
      else
        Jamf::Validate.ibeacon_major_minor newval
      end
      @major = newval
      @need_to_update = true
    end

    # Set the minoe value to for this iBeacon region.
    # Use nil or -1 to not use the major value
    #
    # @param newval[String] the new value
    #
    # @return [void]
    #
    def minor=(newval)
      if newval.nil? || newval == MAJOR_MINOR_UNUSED
        newval ||= MAJOR_MINOR_UNUSED
      else
        Jamf::Validate.ibeacon_major_minor newval
      end

      @minor = newval
      @need_to_update = true
    end

    # @return is the major identifier being used in this region?
    def using_major?
      @major == MAJOR_MINOR_UNUSED
    end

    # @return is the minor identifier being used in this region?
    def using_minor?
      @minor == MAJOR_MINOR_UNUSED
    end

    # @see Creatable.create
    def create
      raise Jamf::MissingDataError, 'uuid may not be empty' if @uuid.to_s.empty?

      super
    end

    # @see Updatable.update
    def update
      raise Jamf::MissingDataError, 'uuid may not be empty' if @uuid.to_s.empty?

      super
    end

    # private instance methods
    ######################
    private

    # the xml formated data for adding or updating this in the JSS
    #
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      doc.root.name = RSRC_OBJECT_KEY.to_s
      ns = doc.root
      ns.add_element('name').text = @name
      ns.add_element('uuid').text = @uuid
      ns.add_element('major').text = @major.to_s
      ns.add_element('minor').text = @minor.to_s
      doc.to_s
    end # rest_xml

  end # class ibeacon

end # module
