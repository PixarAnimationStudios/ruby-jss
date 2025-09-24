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

  # A Building in the JSS.
  # These are simple, in that they only have an ID and a name.
  #
  # @deprecated Use {Jamf::JBuiding} instead. This class will be removed in a future release.
  #
  # @see Jamf::APIObject
  #
  # For accessing buildings via the Jamf Pro API, see {Jamf::JBuiding}, which
  # provides access to the other building-related attributes.
  #
  class Building < Jamf::APIObject

    # Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable

    # Class Methods
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'buildings'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :buildings

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :building

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 41

    # Attributes
    #####################################

    # Constructor
    #####################################

    # Public Instance Methods
    #####################################

  end # class building

end # module
