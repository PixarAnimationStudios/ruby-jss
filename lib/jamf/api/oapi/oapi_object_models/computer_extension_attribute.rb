# Copyright 2022 Pixar
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


module Jamf

  # This module contains Object Model and Enum Constants for all JSONObjects
  # defined in the Jamf Pro API.
  #
  # Generated automatically from the OAPI schema available from the
  # 'api/schema' endpoint of any Jamf Pro server.
  #
  # This file was generated from Jamf Pro version 10.36.1
  #
  module OAPIObjectModels

    # API Object Model and Enums for: ComputerExtensionAttribute
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::ComputerGeneral
    #  - OAPIObjectModels::ComputerGeneralUpdate
    #  - OAPIObjectModels::ComputerHardware
    #  - OAPIObjectModels::ComputerHardwareUpdate
    #  - OAPIObjectModels::ComputerInventoryResponse
    #  - OAPIObjectModels::ComputerInventoryUpdateRequest
    #  - OAPIObjectModels::ComputerOperatingSystem
    #  - OAPIObjectModels::ComputerOperatingSystemUpdate
    #  - OAPIObjectModels::ComputerPurchase
    #  - OAPIObjectModels::ComputerUserAndLocation
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::ComputerExtensionAttribute
    #
    module ComputerExtensionAttribute

      # These enums are used in the properties below

      DATA_TYPE_OPTIONS = [
        'STRING',
        'INTEGER',
        'DATE_TIME'
      ]

      INPUT_TYPE_OPTIONS = [
        'TEXT',
        'POPUP',
        'SCRIPT',
        'LDAP'
      ]

      OAPI_PROPERTIES = {

        # An identifier of extension attribute definition.
        # @!attribute definitionId
        #   @return [String]
        definitionId: {
          class: :string
        },

        # A human-readable name by which attribute can be referred to.
        # @!attribute [r] name
        #   @return [String]
        name: {
          class: :string,
          readonly: true
        },

        # An additional explanation of exact attribute meaning, possible values, etc.
        # @!attribute [r] description
        #   @return [String]
        description: {
          class: :string,
          nil_ok: true,
          readonly: true
        },

        # @!attribute [r] enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean,
          readonly: true
        },

        # @!attribute [r] multiValue
        #   @return [Boolean]
        multiValue: {
          class: :boolean,
          readonly: true
        },

        # A value of extension attribute, in some rare cases there may be multiple values present, hence the array.
        # @!attribute values
        #   @return [Array<String>]
        values: {
          class: :string,
          nil_ok: true,
          multi: true
        },

        # A data type of extension attribute.
        # @!attribute [r] dataType
        #   @return [String]
        dataType: {
          class: :string,
          nil_ok: true,
          readonly: true,
          enum: DATA_TYPE_OPTIONS
        },

        # A closed list of possible values (applies to `popup` input type).
        # @!attribute [r] options
        #   @return [Array<String>]
        options: {
          class: :string,
          nil_ok: true,
          readonly: true,
          multi: true
        },

        # The input method. `text` is most common and means simply free text, `popup` i a closed list of values from
        # which one or many can be selected and `script` value is calculated and can never be set directly.
        # @!attribute [r] inputType
        #   @return [String]
        inputType: {
          class: :string,
          nil_ok: true,
          readonly: true,
          enum: INPUT_TYPE_OPTIONS
        }

      } # end OAPI_PROPERTIES

    end # module ComputerExtensionAttribute

  end # module OAPIObjectModels

end # module Jamf
