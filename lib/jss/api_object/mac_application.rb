# This is just a stub for now.

#
module JSS

  #
  class MacApplication < APIObject

    ### The base for REST resources of this class
    RSRC_BASE = 'macapplications'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :mac_applications

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :mac_application

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 350

  end

end
