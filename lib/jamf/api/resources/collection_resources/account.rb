# Copyright 2019 Pixar

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

# The Module
module Jamf

  # Classes
  #####################################

  # An administrator account in the JSS
  #
  # ISSUES FOR JAMF:
  # - Seems like there needs to be some cleanup/coordination
  #   with the endpoints GET/auth, POST/auth/current, and GET/user
  #   Things are currently wonky enough that I can't really move forward
  #   with this class.
  #
  class Account < Jamf::JSONObject

    # Constants
    #####################################

    ACCESS_LEVEL_FULL = 'FullAccess'.freeze
    ACCESS_LEVEL_SITE = 'SiteAccess'.freeze,
    ACCESS_LEVEL_GROUP = 'GroupBasedAccess'.freeze

    ACCESS_LEVELS = [
      ACCESS_LEVEL_FULL,
      ACCESS_LEVEL_SITE,
      ACCESS_LEVEL_GROUP
    ].freeze

    PRIVILEGE_SET_ADMIN = 'ADMINISTRATOR'.freeze
    PRIVILEGE_SET_AUDITOR = 'AUDITOR'.freeze
    PRIVILEGE_SET_ENROLL = 'ENROLLMENT'.freeze
    PRIVILEGE_SET_CUSTOM = 'CUSTOM'.freeze

    PRIVILEGE_SETS = [
      PRIVILEGE_SET_ADMIN,
      PRIVILEGE_SET_AUDITOR,
      PRIVILEGE_SET_ENROLL,
      PRIVILEGE_SET_CUSTOM
    ].freeze

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {
      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] username
      #   @return [String]
      username: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] realName
      #   @return [String]
      realName: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] email
      #   @return [String]
      email: {
        class: :string,
        readonly: true
      },

      # @!attribute [r]  preferences
      #   @return [String]
      preferences: {
        class: Jamf::AccountPreferences,
        readonly: true
      },

      # @!attribute [r] isMultiSiteAdmin
      #   @return [Boolean]
      isMultiSiteAdmin: {
        class: :boolean,
        readonly: true
      },

      # @!attribute [r] accessLevel
      #   @return [String]
      accessLevel: {
        class: :string,
        readonly: true,
        enum: Jamf::Account::ACCESS_LEVELS
      },

      # @!attribute [r] accessLevel
      #   @return [String]
      privilegeSet: {
        class: :string,
        readonly: true,
        enum: Jamf::Account::PRIVILEGE_SETS
      },

    }.freeze
    parse_object_model

    # CurrentAccount {
    # id (integer, optional),
    # username (string, optional),
    # realName (string, optional),
    # email (string, optional),
    # preferences (AccountPreferences, optional),
    # isMultiSiteAdmin (boolean, optional),
    # accessLevel (string, optional) = ['FullAccess', 'SiteAccess', 'GroupBasedAccess'],
    # privilegeSet (string, optional) = ['ADMINISTRATOR', 'AUDITOR', 'ENROLLMENT', 'CUSTOM'],
    # privileges (Array[string], optional),
    # groupIds (Array[integer], optional),
    # currentSiteId (integer, optional)
    # }

    # Account/AuthAccount {
    # id (integer, optional),
    # username (string, optional),
    # realName (string, optional),
    # email (string, optional),
    # preferences (AccountPreferences, optional),
    # isMultiSiteAdmin (boolean, optional),
    # accessLevel (string, optional) = ['FullAccess', 'SiteAccess', 'GroupBasedAccess'],
    # privilegeSet (string, optional) = ['ADMINISTRATOR', 'AUDITOR', 'ENROLLMENT', 'CUSTOM'],
    # privilegesBySite (object, optional),
    # groupIds (Array[integer], optional),
    # currentSiteId (integer, optional)
    # }

  end # class

end # module
