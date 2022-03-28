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

    # API Object Model and Enums for: SelfServiceInteractionSettings
    #
    # This constant defines the attributes of this API object
    # and should be used as the base of the OBJECT_MODEL for the
    # matching class in the Jamf module.
    #
    # Container Objects:
    # Other object models that use this model as the value in one
    # of their attributes.
    #  - OAPIObjectModels::SelfServiceSettings
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
    #   include Jamf::OAPIObjectModels::SelfServiceInteractionSettings
    #
    module SelfServiceInteractionSettings

      # These enums are used in the properties below

      DEFAULT_LANDING_PAGE_OPTIONS = [
        'HOME',
        'BROWSE',
        'HISTORY',
        'NOTIFICATIONS'
      ]

      OAPI_PROPERTIES = {

        # global Self Service setting for if notifications are on or off
        # @!attribute notificationsEnabled
        #   @return [Boolean]
        notificationsEnabled: {
          class: :boolean
        },

        # whether users should be notified they need to approve organization's MDM profile
        # @!attribute alertUserApprovedMdm
        #   @return [Boolean]
        alertUserApprovedMdm: {
          class: :boolean
        },

        # the default landing page in Self Service
        # @!attribute defaultLandingPage
        #   @return [String]
        defaultLandingPage: {
          class: :string,
          enum: DEFAULT_LANDING_PAGE_OPTIONS
        },

        # id for the default home category in Self Service
        # @!attribute defaultHomeCategoryId
        #   @return [Integer]
        defaultHomeCategoryId: {
          class: :integer
        },

        # renamed string for bookmarks if the admin wishes
        # @!attribute bookmarksName
        #   @return [String]
        bookmarksName: {
          class: :string,
          required: true
        }

      } # end OAPI_PROPERTIES

    end # module SelfServiceInteractionSettings

  end # module OAPIObjectModels

end # module Jamf
