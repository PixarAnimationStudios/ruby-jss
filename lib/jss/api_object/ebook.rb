# This is just a stub for now.

#
module JSS

  #
  class EBook < APIObject

    ### The base for REST resources of this class
    RSRC_BASE = 'ebooks'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :ebooks

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :ebook

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 24

  end

end
