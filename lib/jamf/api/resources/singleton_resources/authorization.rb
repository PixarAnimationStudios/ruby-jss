# Copyright 2020 Pixar

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

  # Authorization Details associated with the current API token
  #
  class Authorization < Jamf::SingletonResource

    # Constants
    #####################################

    RSRC_PATH = 'auth'.freeze

    AUTH_TYPE_JSS = 'JSS'.freeze
    AUTH_TYPE_LDAP = 'LDAP'.freeze
    AUTH_TYPE_SAML = 'SAML'.freeze
    AUTH_TYPE_INVITE = 'INVITE'.freeze
    AUTH_TYPE_OAUTH = 'OAUTH'.freeze

    AUTH_TYPES = [
      AUTH_TYPE_JSS,
      AUTH_TYPE_LDAP,
      AUTH_TYPE_SAML,
      AUTH_TYPE_INVITE,
      AUTH_TYPE_OAUTH
    ].freeze

    OBJECT_MODEL = {

      # @!attribute account
      #   @return [Jamf::Account]
      account: {
        class: Jamf::Account,
        readonly: true
      },

      # @!attribute accountGroups
      #   @return [Array<Jamf::AccountGroup>]
      accountGroups: {
        class: Jamf::AccountGroup,
        multi: true,
        readonly: true
      },

      # @!attribute sites
      #   @return [Array<amf::Site>]
      sites: {
        class: Jamf::Site,
        multi: true,
        readonly: true
      },

      # @!attribute authenticationType
      #   @return [String]
      authenticationType: {
        class: :string,
        enum: Jamf::Authorization::AUTH_TYPES
      }

    }.freeze # end OBJECT_MODEL
    parse_object_model

  end # class ReEnrollment

end # module JAMF
