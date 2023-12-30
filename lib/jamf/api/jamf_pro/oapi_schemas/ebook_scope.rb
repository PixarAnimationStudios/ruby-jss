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


    # OAPI Object Model and Enums for: EbookScope
    #
    #
    #
    # This class was automatically genereated from the api/schema
    # URL path on a Jamf Pro server version 10.50.0-t1693149930
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::EbookLimitations
    #  - Jamf::OAPISchemas::EbookExclusions
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/v1/ebooks/{id}/scope:GET' needs permissions:
    #    - Read eBooks
    #
    #
    class EbookScope < Jamf::OAPIObject

      

      OAPI_PROPERTIES = {

        # @!attribute allComputers
        #   @return [Boolean]
        allComputers: {
          class: :boolean
        },

        # @!attribute allMobileDevices
        #   @return [Boolean]
        allMobileDevices: {
          class: :boolean
        },

        # @!attribute allUsers
        #   @return [Boolean]
        allUsers: {
          class: :boolean
        },

        # @!attribute computerIds
        #   @return [Array<String>]
        computerIds: {
          class: :string,
          multi: true
        },

        # @!attribute computerGroupIds
        #   @return [Array<String>]
        computerGroupIds: {
          class: :string,
          multi: true
        },

        # @!attribute mobileDeviceIds
        #   @return [Array<String>]
        mobileDeviceIds: {
          class: :string,
          multi: true
        },

        # @!attribute mobileDeviceGroupIds
        #   @return [Array<String>]
        mobileDeviceGroupIds: {
          class: :string,
          multi: true
        },

        # @!attribute buildingIds
        #   @return [Array<String>]
        buildingIds: {
          class: :string,
          multi: true
        },

        # @!attribute departmentIds
        #   @return [Array<String>]
        departmentIds: {
          class: :string,
          multi: true
        },

        # @!attribute userIds
        #   @return [Array<String>]
        userIds: {
          class: :string,
          multi: true
        },

        # @!attribute userGroupIds
        #   @return [Array<String>]
        userGroupIds: {
          class: :string,
          multi: true
        },

        # @!attribute classroomIds
        #   @return [Array<String>]
        classroomIds: {
          class: :string,
          multi: true
        },

        # @!attribute limitations
        #   @return [Jamf::OAPISchemas::EbookLimitations]
        limitations: {
          class: Jamf::OAPISchemas::EbookLimitations
        },

        # @!attribute exclusions
        #   @return [Jamf::OAPISchemas::EbookExclusions]
        exclusions: {
          class: Jamf::OAPISchemas::EbookExclusions
        }

      } # end OAPI_PROPERTIES

    end # class EbookScope

  end # module OAPISchemas

end # module Jamf
