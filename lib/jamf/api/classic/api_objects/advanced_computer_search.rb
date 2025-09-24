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
  class AdvancedComputerSearch < Jamf::AdvancedSearch

    # Mix-Ins
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'advancedcomputersearches'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :advanced_computer_searches

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :advanced_computer_search

    # what kind of thing is returned by this search?
    RESULT_CLASS = Jamf::Computer

    # what data fields come back along with the display fields
    # for each computer?
    RESULT_ID_FIELDS = %i[id name udid].freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 70

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
