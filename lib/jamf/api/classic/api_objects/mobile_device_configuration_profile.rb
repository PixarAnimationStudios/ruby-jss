### Copyright 2022 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###

# This is just a stub for now.

#
module Jamf

  #
  class MobileDeviceConfigurationProfile < Jamf::ConfigurationProfile


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

    # See Jamf::APIObject#initialize
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
      raise Jamf::InvalidDataError, 'New value must be an integer >= 0' unless new_val.is_a?(Integer) && new_val >= 0
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

end # module Jamf
