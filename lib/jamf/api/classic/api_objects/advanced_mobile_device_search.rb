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

  # An AdvancedComputerSearch in the JSS
  #
  # @see Jamf::AdvancedSearch
  #
  # @see Jamf::APIObject
  #
  class AdvancedMobileDeviceSearch < Jamf::AdvancedSearch

    # Mix-Ins
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'advancedmobiledevicesearches'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :advanced_mobile_device_searches

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :advanced_mobile_device_search

    # what kind of thing is returned by this search?
    RESULT_CLASS = Jamf::MobileDevice

    # what data fields come back along with the display fields
    # for each mobiledevices?
    RESULT_ID_FIELDS = %i[id name udid].freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 71

    # Attributes
    #####################################

    # Constructor
    #####################################

    # Public Instance Methods
    #####################################

    # Private Instance Methods
    #####################################

  end # class

end # module
