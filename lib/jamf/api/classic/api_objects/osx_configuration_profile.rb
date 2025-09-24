# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # Classes
  ###################################

  # An OS X Configuration Profile in the JSS.
  #
  # Note that the profile payloads and the profile UUID cannot be edited or updated with this via this class.
  # Use the web UI.
  #
  # @see Jamf::APIObject
  #
  class OSXConfigurationProfile < Jamf::ConfigurationProfile

    # Class Constants
    ###################################

    # The base for REST resources of this class
    RSRC_BASE = 'osxconfigurationprofiles'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :os_x_configuration_profiles

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :os_x_configuration_profile

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

    # See Jamf::APIObject#initialize
    #
    def initialize(**args)
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
      raise Jamf::InvalidDataError, "New value must be one of '#{LEVELS.join("' '")}'" unless LEVELS.include? new_val

      @level = new_val
      @need_to_update = true
    end

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
