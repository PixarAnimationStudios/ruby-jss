# Copyright 2018 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

#
module JSS

  # Classes
  ###################################

  # An OS X Configuration Profile in the JSS.
  #
  # Note that the profile payloads and the profile UUID cannot be edited or updated with this via this class.
  # Use the web UI.
  #
  # @see JSS::APIObject
  #
  class OSXConfigurationProfile < JSS::ConfigurationProfile

    # Class Constants
    ###################################

    # The base for REST resources of this class
    RSRC_BASE = 'osxconfigurationprofiles'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :os_x_configuration_profiles

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :os_x_configuration_profile

    # these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = %i[distribution_method scope redeploy_on_update].freeze

    # Our scopes deal with computers
    SCOPE_TARGET_KEY = :computers

    # Our SelfService happens on OSX
    SELF_SERVICE_TARGET = :osx

    # The possible values for :level
    LEVELS = %w[user computer].freeze

    # can not yet upload icons
    # UPLOAD_TYPES = { icon: :osxconfigurationprofileicon }.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 4

    # Attributes
    ###################################

    # @return [String] the level (user/computer) of this profile
    attr_reader :level

    # Constructor
    ###################################

    # See JSS::APIObject#initialize
    #
    def initialize(args = {})
      super
      @level = @main_subset[:level]
    end

    # Public Instance Methods
    ###################################

    # @param new_val[String] the new level for this profile (user/computer)
    #
    # @return [void]
    #
    def level=(new_val)
      return nil if @level == new_val
      raise JSS::InvalidDataError, "New value must be one of '#{LEVELS.join("' '")}'" unless LEVELS.include? new_val
      @level = new_val
      @need_to_update = true
    end #

    # Private Instance Methods
    ###################################
    private

    def rest_xml
      doc = super
      gen = doc.root.elements['general']
      gen.add_element('level').text = level
      doc.to_s
    end

  end # class OSXConfigurationProfile

end # module
