# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # Classes
  ###################################

  # A Site in the JSS.
  #
  # These are simple, in that they only have an ID and a name.
  #
  # @see Jamf::APIObject
  #
  class Site < Jamf::APIObject

    # Mix-Ins
    ###################################
    include Jamf::Creatable
    include Jamf::Updatable

    # Class Constants
    ###################################

    # The base for REST resources of this class
    RSRC_BASE = 'sites'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :sites

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :site

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 44

  end # class site

end # module
