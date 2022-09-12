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


module Jamf

  # This module is the namespace for all objects defined
  # in the OAPI JSON schema under the components => schemas key
  #
  module OAPISchemas


    # OAPI Object Model and Enums for: Account
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
    #  
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  - Jamf::OAPISchemas::AccountPreferences
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/user:GET' needs permissions:
    #    - Read Accounts
    #
    #
    class Account < Jamf::OAPIObject

      # Enums used by this class or others

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
        #   @return [Integer]
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
        #   @return [Jamf::OAPISchemas::AccountPreferences]
        preferences: {
          class: Jamf::OAPISchemas::AccountPreferences
        },

        # @!attribute isMultiSiteAdmin
        #   @return [Boolean]
        isMultiSiteAdmin: {
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
        #   @return [Array<Integer>]
        groupIds: {
          class: :integer,
          multi: true
        },

        # @!attribute currentSiteId
        #   @return [Integer]
        currentSiteId: {
          class: :integer
        }

      } # end OAPI_PROPERTIES

    end # class Account

  end # module OAPISchemas

end # module Jamf
