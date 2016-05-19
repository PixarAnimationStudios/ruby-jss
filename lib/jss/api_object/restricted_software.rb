module JSS
  #####################################
  ### Classes
  #####################################

  ###
  ### Restricted Software in the JSS.
  ###
  ### This class only supports showing of object data.
  ###
  ### @see JSS::APIObject
  ###
  class RestrictedSoftware < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    include JSS::Scopable

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "restrictedsoftware"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :restricted_software

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :restricted_software

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:scope]

    ### Our scopes deal with computers
    SCOPE_TARGET_KEY = :computers
  end
end
