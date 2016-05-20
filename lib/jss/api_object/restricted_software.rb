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

    #####################################
    ### Attributes
    #####################################

    ### The values returned in the General, Location, and Purchasing subsets are stored as direct attributes
    ### Location and Purchasing are defined in the Locatable and Purchasable mixin modules.
    ### Here's General, in alphabetical order

    ### @return [String] the process name
    attr_reader :process_name

    ### @return [Boolean] whether to return match exact process name
    attr_reader :match_exact_process_name

    ### @return [Boolean] whether to send a notification
    attr_reader :send_notification

    ### @return [Boolean] whether to kill the running process
    attr_reader :kill_process

    ### @return [Boolean] whether to delete the executable
    attr_reader :delete_executable

    ### @return [String] message displayed to the user
    attr_reader :display_message

    ### @return [Hash] the :name and :id of the site for this machine
    attr_reader :site

    #####################################
    ### Instance Methods
    #####################################

    def initialize(args = {})
      super args, []

      @process_name = @init_data[:general][:process_name]
      @match_exact_process_name = @init_data[:general][:match_exact_process_name]
      @send_notification = @init_data[:general][:send_notification]
      @kill_process = @init_data[:general][:kill_process]
      @delete_executable = @init_data[:general][:delete_executable]
      @display_message = @init_data[:general][:display_message]
      @site = JSS::APIObject.get_name(@init_data[:general][:site])
    end
  end
end
