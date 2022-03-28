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

    # API Object Model and Enums for: Script
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::ScriptsSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/scripts:POST', needs permissions: Create Scripts
    #  - '/v1/scripts/{id}:GET', needs permissions: Read Scripts
    #  - '/v1/scripts/{id}:PUT', needs permissions: Update Scripts
    #
    # We define this in its own module so that it can be autoloaded
    # by ZeitWerk, and included in other classes and modules.
    #
    # To do so, use:
    #   include Jamf::OAPIObjectModels::Script
    #
    module Script

      # These enums are used in the properties below

      PRIORITY_OPTIONS = [
        'BEFORE',
        'AFTER',
        'AT_REBOOT'
      ]

      OAPI_PROPERTIES = {

        # @!attribute [r] id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary,
          readonly: true
        },

        # @!attribute name
        #   @return [String]
        name: {
          class: :string,
          required: true
        },

        # @!attribute info
        #   @return [String]
        info: {
          class: :string
        },

        # @!attribute notes
        #   @return [String]
        notes: {
          class: :string
        },

        # @!attribute priority
        #   @return [String]
        priority: {
          class: :string,
          enum: PRIORITY_OPTIONS
        },

        # @!attribute categoryId
        #   @return [String]
        categoryId: {
          class: :string
        },

        # @!attribute categoryName
        #   @return [String]
        categoryName: {
          class: :string
        },

        # @!attribute parameter4
        #   @return [String]
        parameter4: {
          class: :string
        },

        # @!attribute parameter5
        #   @return [String]
        parameter5: {
          class: :string
        },

        # @!attribute parameter6
        #   @return [String]
        parameter6: {
          class: :string
        },

        # @!attribute parameter7
        #   @return [String]
        parameter7: {
          class: :string
        },

        # @!attribute parameter8
        #   @return [String]
        parameter8: {
          class: :string
        },

        # @!attribute parameter9
        #   @return [String]
        parameter9: {
          class: :string
        },

        # @!attribute parameter10
        #   @return [String]
        parameter10: {
          class: :string
        },

        # @!attribute parameter11
        #   @return [String]
        parameter11: {
          class: :string
        },

        # @!attribute osRequirements
        #   @return [String]
        osRequirements: {
          class: :string
        },

        # @!attribute scriptContents
        #   @return [String]
        scriptContents: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # module Script

  end # module OAPIObjectModels

end # module Jamf
