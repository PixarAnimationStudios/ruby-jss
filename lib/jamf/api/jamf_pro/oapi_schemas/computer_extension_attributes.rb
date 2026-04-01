# Copyright 2025 Pixar
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

module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas

    # OAPI Object Model and Enums for: ComputerExtensionAttributes
    #
    #
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.9.2-t1726753918
    #
    # This class may be used directly, e.g instances of other classes may
    # use instances of this class as one of their own properties/attributes.
    #
    # It may also be used as a superclass when implementing Jamf Pro API
    # Resources in ruby-jss. The subclasses include appropriate mixins, and
    # should expand on the basic functionality provided here.
    #
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - Jamf::OAPISchemas::ComputerExtensionAttributeSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/computer-extension-attributes:POST' needs permissions:
    #    - Create Computer Extension Attributes
    #  - '/v1/computer-extension-attributes/{id}:GET' needs permissions:
    #    - Read Computer Extension Attributes
    #  - '/v1/computer-extension-attributes/{id}:PUT' needs permissions:
    #    - Update Computer Extension Attributes
    #
    #
    class ComputerExtensionAttributes < Jamf::OAPIObject

      # Enums used by this class or others

      INVENTORY_DISPLAY_TYPE_OPTIONS = %w[
        GENERAL
        HARDWARE
        OPERATING_SYSTEM
        USER_AND_LOCATION
        PURCHASING
        EXTENSION_ATTRIBUTES
      ]

      INPUT_TYPE_OPTIONS = %w[
        SCRIPT
        TEXT
        POPUP
        DIRECTORY_SERVICE_ATTRIBUTE_MAPPING
      ]

      OAPI_PROPERTIES = {

        # Enabled by default, but for inputType Script we can disable it as well. <br/> Possible values are:<br/> false <br/> true
        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean
        },

        # Category in which to display the extension attribute in Jamf Pro.
        # @!attribute inventoryDisplayType
        #   @return [String]
        inventoryDisplayType: {
          class: :string,
          required: true,
          enum: INVENTORY_DISPLAY_TYPE_OPTIONS
        },

        # Extension attributes collect inventory data by using an input type.The type of the Input used to populate the extension attribute.
        # @!attribute inputType
        #   @return [String]
        inputType: {
          class: :string,
          required: true,
          enum: INPUT_TYPE_OPTIONS
        },

        # When we run this script it returns a data value each time a computer submits inventory to Jamf Pro. Provide scriptContents only when inputType is 'SCRIPT'.
        # @!attribute scriptContents
        #   @return [String]
        scriptContents: {
          class: :string,
          nil_ok: true
        },

        # When added with list of choices while creating computer extension attributes these Pop-up menu can be displayed in inventory information. User can choose a value from the pop-up menu list when enrolling a computer any time using Jamf Pro. Provide popupMenuChoices only when inputType is 'POPUP'.
        # @!attribute popupMenuChoices
        #   @return [Array<String>]
        popupMenuChoices: {
          class: :string,
          multi: true,
          min_items: 0
        },

        # Directory Service attribute use to populate the extension attribute. <br/> Required when inputType is "DIRECTORY_SERVICE_ATTRIBUTE_MAPPING"
        # @!attribute ldapAttributeMapping
        #   @return [String]
        ldapAttributeMapping: {
          class: :string
        },

        # Collect multiple values for this extension attribute. ldapExtensionAttributeAllowed is disabled by default, only for inputType 'DIRECTORY_SERVICE_ATTRIBUTE_MAPPING' it can be enabled. It's value cannot be modified during edit operation.<br/> Possible values are:<br/> false <br/> true <br/>
        # @!attribute ldapExtensionAttributeAllowed
        #   @return [Boolean]
        ldapExtensionAttributeAllowed: {
          class: :boolean
        }
      }.merge(Jamf::OAPISchemas::ExtensionAttributes::OAPI_PROPERTIES) # end OAPI_PROPERTIES

    end # class ComputerExtensionAttributes

  end # module OAPISchemas

end # module Jamf
