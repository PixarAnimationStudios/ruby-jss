# This is just a stub for now.

#
module JSS

  #
  class MobileDeviceConfigurationProfile < APIObject

    # Mix-Ins
    ###################################
    include JSS::Categorizable
    include JSS::Sitable
    include JSS::Scopable
    include JSS::SelfServable

    ### The base for REST resources of this class
    RSRC_BASE = 'mobiledeviceconfigurationprofiles'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :configuration_profiles

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :configuration_profile

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 22

    # Our scopes deal with computers
    SCOPE_TARGET_KEY = :mobile_devices

    SITE_SUBSET = :general

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :general

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = Hash


    # Attributes
    ###################################

    # @return [String] the description of this profile
    attr_reader :description

    # @return [String] the distribution_method of this profile
    attr_reader :distribution_method

    # @return [Boolean] can the user remove this profile
    attr_reader :user_removable

    # @return [String] the level (user/computer) of this profile
    attr_reader :level

    # @return [String] the uuid of this profile. NOT Updatable
    attr_reader :uuid

    # @return [Boolean] Should this profile be redeployed when an inventory update happens?
    attr_reader :redeploy_on_update

    # @return [String] the plist containing the payloads for this profile. NOT Updatable
    attr_reader :payloads

  end

end
