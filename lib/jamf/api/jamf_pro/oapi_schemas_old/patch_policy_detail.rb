# Copyright 2025 Pixar
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

    # OAPI Object Model and Enums for: PatchPolicyDetail
    #
    #
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
    #  - Jamf::OAPISchemas::PatchPolicyDetails
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
    class PatchPolicyDetail < Jamf::OAPIObject

      OAPI_PROPERTIES = {

        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # @!attribute name
        #   @return [String]
        name: {
          class: :string
        },

        # @!attribute enabled
        #   @return [Boolean]
        enabled: {
          class: :boolean
        },

        # @!attribute targetPatchVersion
        #   @return [String]
        targetPatchVersion: {
          class: :string
        },

        # @!attribute deploymentMethod
        #   @return [String]
        deploymentMethod: {
          class: :string
        },

        # @!attribute softwareTitleId
        #   @return [String]
        softwareTitleId: {
          class: :string
        },

        # @!attribute softwareTitleConfigurationId
        #   @return [String]
        softwareTitleConfigurationId: {
          class: :string
        },

        # @!attribute killAppsDelayMinutes
        #   @return [Integer]
        killAppsDelayMinutes: {
          class: :integer
        },

        # @!attribute killAppsMessage
        #   @return [String]
        killAppsMessage: {
          class: :string
        },

        # @!attribute downgrade
        #   @return [Boolean]
        downgrade: {
          class: :boolean
        },

        # @!attribute patchUnknownVersion
        #   @return [Boolean]
        patchUnknownVersion: {
          class: :boolean
        },

        # @!attribute notificationHeader
        #   @return [String]
        notificationHeader: {
          class: :string
        },

        # @!attribute selfServiceEnforceDeadline
        #   @return [Boolean]
        selfServiceEnforceDeadline: {
          class: :boolean
        },

        # @!attribute selfServiceDeadline
        #   @return [Integer]
        selfServiceDeadline: {
          class: :integer
        },

        # @!attribute installButtonText
        #   @return [String]
        installButtonText: {
          class: :string
        },

        # @!attribute selfServiceDescription
        #   @return [String]
        selfServiceDescription: {
          class: :string
        },

        # @!attribute iconId
        #   @return [String]
        iconId: {
          class: :string
        },

        # @!attribute reminderFrequency
        #   @return [Integer]
        reminderFrequency: {
          class: :integer
        },

        # @!attribute reminderEnabled
        #   @return [Boolean]
        reminderEnabled: {
          class: :boolean
        }

      } # end OAPI_PROPERTIES

    end # class PatchPolicyDetail

  end # module OAPISchemas

end # module Jamf
