module JSS

  #####################################
  ### Module Constants
  #####################################

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
  ### A Mobile Device group in the JSS
  ###
  ### See also the parent class JSS::Group
  ###
  ### @see JSS::APIObject
  ###
  ### @see JSS::Group
  ###
  class UserGroup < JSS::Group

    #####################################
    ### Mix-Ins
    #####################################


    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "usergroups"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :user_groups

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :user_group

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:is_smart, :users ]

    ### this allows the parent Group class to do things right
    MEMBER_CLASS = JSS::User

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Attributes
    #####################################

    #####################################
    ### Public Instance Methods
    #####################################
    
    ###
    ### Return an array of the usernames of users in this group
    ###
    ### @return [Array<String>] the member usernames
    ###
    def member_usernames
      @members.map{|m| m[:username]}
    end
    
    ###
    ### Return an array of the full names of users in this group
    ###
    ### @return [Array<String>] the member full names
    ###
    def member_full_names
      @members.map{|m| m[:full_name]}
    end
    
    ###
    ### Return an array of the phone numbers of users in this group
    ###
    ### @return [Array<String>] the member phone numbers
    ###
    def member_phone_numbers
      @members.map{|m| m[:phone_number]}
    end
    
    ###
    ### Return an array of the email addresses of users in this group
    ###
    ### @return [Array<String>] the member email addresses
    ###
    def member_email_addresses
      @members.map{|m| m[:email_address]}
    end
    
    #####################################
    ### Private Instance Methods
    #####################################


  end # class UserGroup

end # module
