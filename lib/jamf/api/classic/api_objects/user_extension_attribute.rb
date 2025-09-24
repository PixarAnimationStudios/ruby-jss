# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

module Jamf

  # Classes
  #####################################

  # A User extension attribute as defined in the JSS
  #
  # @see Jamf::ExtensionAttribute
  # @see Jamf::APIObject
  #
  class UserExtensionAttribute < Jamf::ExtensionAttribute

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'userextensionattributes'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :user_extension_attributes

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :user_extension_attribute

    # these ext attribs are related to these kinds of objects
    TARGET_CLASS = Jamf::User

    # A criterion that will return all members of the TARGET_CLASS
    ALL_TARGETS_CRITERION = Jamf::Criteriable::Criterion.new(and_or: 'and', name: 'Username', search_type: 'like', value: '')

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 87

    # Public Instance Methods
    #####################################

    # @see Jamf::ExtensionAttribute#input_type=
    #
    def input_type=(new_val)
      raise Jamf::InvalidDataError, "User Extension Attribute input_type cannot be '#{INPUT_TYPE_SCRIPT}'" if new_val == INPUT_TYPE_SCRIPT
      raise Jamf::InvalidDataError, "User Extension Attribute input_type cannot be '#{INPUT_TYPE_LDAP}'" if new_val == INPUT_TYPE_LDAP

      super
    end # end input_type

    # @see Jamf::ExtensionAttribute#web_display=
    #
    def web_display=(_new_val)
      raise Jamf::UnsupportedError, 'User Extension Attributes web_display cannot be set'
    end

  end # class ExtAttrib

end # module
