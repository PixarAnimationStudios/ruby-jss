module JSS

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Classes
  #####################################

  ###
  ### An AdvancedUserSearch in the JSS
  ###
  ### @see JSS::AdvancedSearch
  ###
  ### @see JSS::APIObject
  ###
  class AdvancedUserSearch <  JSS::AdvancedSearch

    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "advancedusersearches"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :advanced_user_searches

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :advanced_user_search

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:criteria, :display_fields, :users]

    ### what kind of thing is returned by this search?
    RESULT_CLASS = JSS::User

    ### what data fields come back along with the display fields
    ### for each user?
    RESULT_ID_FIELDS = [:id, :name]

    #####################################
    ### Attributes
    #####################################

    #####################################
    ### Constructor
    #####################################

    #####################################
    ### Public Instance Methods
    #####################################

    #####################################
    ### Private Instance Methods
    #####################################

  end # class

end # module
