# Copyright 2023 Pixar
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


    # OAPI Object Model and Enums for: Script
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.40.0-t1657115323
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
    #  - Jamf::OAPISchemas::ScriptsSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/scripts:POST' needs permissions:
    #    - Create Scripts
    #  - '/v1/scripts/{id}:GET' needs permissions:
    #    - Read Scripts
    #  - '/v1/scripts/{id}:PUT' needs permissions:
    #    - Update Scripts
    #
    #
    class Script < Jamf::OAPIObject

      # Enums used by this class or others

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

    end # class Script

  end # module OAPISchemas

end # module Jamf
