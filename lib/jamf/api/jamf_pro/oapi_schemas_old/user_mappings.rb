# Copyright 2024 Pixar
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


    # OAPI Object Model and Enums for: UserMappings
    #
    # Description of this class from the OAPI Schema:
    #   Cloud Identity Provider user mappings configuration
    #
    # This class was automatically generated from the api/schema
    # URL path on a Jamf Pro server version 11.6.1-t1718634702
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
    #  - Jamf::OAPISchemas::CloudLdapMappingsRequest
    #  - Jamf::OAPISchemas::CloudLdapMappingsResponse
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
    #
    class UserMappings < Jamf::OAPIObject

      # Enums used by this class or others

      OBJECT_CLASS_LIMITATION_OPTIONS = [
        'ANY_OBJECT_CLASSES',
        'ALL_OBJECT_CLASSES'
      ]

      SEARCH_SCOPE_OPTIONS = [
        'ALL_SUBTREES',
        'FIRST_LEVEL_ONLY'
      ]

      OAPI_PROPERTIES = {

        # @!attribute objectClassLimitation
        #   @return [String]
        objectClassLimitation: {
          class: :string,
          required: true,
          enum: OBJECT_CLASS_LIMITATION_OPTIONS
        },

        # @!attribute objectClasses
        #   @return [String]
        objectClasses: {
          class: :string,
          required: true
        },

        # @!attribute searchBase
        #   @return [String]
        searchBase: {
          class: :string,
          required: true
        },

        # @!attribute searchScope
        #   @return [String]
        searchScope: {
          class: :string,
          required: true,
          enum: SEARCH_SCOPE_OPTIONS
        },

        # @!attribute additionalSearchBase
        #   @return [String]
        additionalSearchBase: {
          class: :string
        },

        # @!attribute userID
        #   @return [String]
        userID: {
          class: :string,
          required: true
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string,
          required: true
        },

        # @!attribute realName
        #   @return [String]
        realName: {
          class: :string,
          required: true
        },

        # @!attribute emailAddress
        #   @return [String]
        emailAddress: {
          class: :string,
          required: true
        },

        # @!attribute department
        #   @return [String]
        department: {
          class: :string,
          required: true
        },

        # @!attribute building
        #   @return [String]
        building: {
          class: :string,
          required: true
        },

        # @!attribute room
        #   @return [String]
        room: {
          class: :string,
          required: true
        },

        # @!attribute phone
        #   @return [String]
        phone: {
          class: :string,
          required: true
        },

        # @!attribute position
        #   @return [String]
        position: {
          class: :string,
          required: true
        },

        # @!attribute userUuid
        #   @return [String]
        userUuid: {
          class: :string,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # class UserMappings

  end # module OAPISchemas

end # module Jamf
