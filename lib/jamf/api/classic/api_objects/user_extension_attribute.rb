# Copyright 2023 Pixar

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
