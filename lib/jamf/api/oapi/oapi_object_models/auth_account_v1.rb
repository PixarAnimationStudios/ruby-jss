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

    # API Object Model and Enums for: AuthAccountV1
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::AuthorizationV1
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - OAPIObjectModels::AccountPreferencesV1
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
    #   include Jamf::OAPIObjectModels::AuthAccountV1
    #
    module AuthAccountV1

      # These enums are used in the properties below

      ACCESS_LEVEL_OPTIONS = [
        'FullAccess',
        'SiteAccess',
        'GroupBasedAccess'
      ]

      PRIVILEGE_SET_OPTIONS = [
        'ADMINISTRATOR',
        'AUDITOR',
        'ENROLLMENT',
        'CUSTOM'
      ]

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute username
        #   @return [String]
        username: {
          class: :string
        },

        # @!attribute realName
        #   @return [String]
        realName: {
          class: :string
        },

        # @!attribute email
        #   @return [String]
        email: {
          class: :string
        },

        # @!attribute preferences
        #   @return [Jamf::AccountPreferencesV1]
        preferences: {
          class: Jamf::AccountPreferencesV1
        },

        # @!attribute multiSiteAdmin
        #   @return [Boolean]
        multiSiteAdmin: {
          class: :boolean
        },

        # @!attribute accessLevel
        #   @return [String]
        accessLevel: {
          class: :string,
          enum: ACCESS_LEVEL_OPTIONS
        },

        # @!attribute privilegeSet
        #   @return [String]
        privilegeSet: {
          class: :string,
          enum: PRIVILEGE_SET_OPTIONS
        },

        # @!attribute privilegesBySite
        #   @return [Hash{Symbol: Array<String> }]
        privilegesBySite: {
          class: :hash
        },

        # @!attribute groupIds
        #   @return [Array<String>]
        groupIds: {
          class: :string,
          multi: true
        },

        # @!attribute currentSiteId
        #   @return [String]
        currentSiteId: {
          class: :string
        }

      } # end OAPI_PROPERTIES

    end # module AuthAccountV1

  end # module OAPIObjectModels

end # module Jamf
