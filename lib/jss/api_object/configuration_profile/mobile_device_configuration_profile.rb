# This is just a stub for now.

#
module JSS

  #
  class MobileDeviceConfigurationProfile < JSS::ConfigurationProfile


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

    # Our scopes deal with mobile_devices
    SCOPE_TARGET_KEY = :mobile_devices

    # icons cant be uploaded yet
    # UPLOAD_TYPES = { icon: :mobiledeviceconfigurationprofileicon }.freeze

    # Attributes
    ###################################

    # @return [Integer] how many days before a cert payload expires
    # should this profile be automatically re-installed?
    attr_reader :redeploy_days_before_certificate_expires

    # Constructor
    ###################################

    # See JSS::APIObject#initialize
    #
    def initialize(args = {})
      super
      @redeploy_days_before_certificate_expires = @main_subset[:redeploy_days_before_certificate_expires]
    end

    # @param new_val[String] the new level for this profile (user/computer)
    #
    # @return [void]
    #
    def redeploy_days_before_certificate_expires=(new_val)
      return nil if redeploy_days_before_certificate_expires == new_val
      raise JSS::InvalidDataError, 'New value must be an integer >= 0' unless new_val.is_a?(Integer) && new_val >= 0
      @redeploy_days_before_certificate_expires = new_val
      @need_to_update = true
    end #

    # Private Instance Methods
    ###################################
    private

    def rest_xml
      doc = super
      gen = doc.root.elements['general']
      gen.add_element('redeploy_days_before_certificate_expires').text = redeploy_days_before_certificate_expires.to_s
      doc.to_s
    end

  end # class MobileDeviceConfigurationProfile

end # module JSS

require 'jss/api_object/configuration_profile/mobile_device_configuration_profile'
require 'jss/api_object/configuration_profile/osx_configuration_profile'
