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


    # OAPI Object Model and Enums for: SessionDetails
    #
    # Description of this class from the OAPI Schema:
    #   Session details
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
    #  - Jamf::OAPISchemas::SessionDetailsSearchResults
    #
    # Sub Objects:
    # Other object models used by this model's attributes.
    #  
    #
    # Endpoints and Privileges:
    # API endpoints and HTTP operations that use this object
    # model, and the Jamf Pro privileges needed to access them.
    #  - '/preview/remote-administration-configurations/team-viewer/{configurationId}/sessions/{sessionId}:GET' needs permissions:
    #    - Read Remote Administration
    #
    #
    class SessionDetails < Jamf::OAPIObject

      # Enums used by this class or others

      DEVICE_TYPE_OPTIONS = [
        'COMPUTER'
      ]

      STATE_OPTIONS = [
        'OPEN',
        'CLOSED',
        'UNKNOWN'
      ]

      OAPI_PROPERTIES = {

        # Session identifier
        # @!attribute id
        #   @return [String]
        id: {
          class: :j_id,
          identifier: :primary
        },

        # Sessions code
        # @!attribute code
        #   @return [String]
        code: {
          class: :string
        },

        # Session description. To be used for additional context on the reason of the session
        # @!attribute description
        #   @return [String]
        description: {
          class: :string
        },

        # Supporter session URL
        # @!attribute supporterLink
        #   @return [String]
        supporterLink: {
          class: :string
        },

        # End user session URL
        # @!attribute endUserLink
        #   @return [String]
        endUserLink: {
          class: :string
        },

        # Device identifier
        # @!attribute deviceId
        #   @return [String]
        deviceId: {
          class: :string
        },

        # Device name if found - null otherwise
        # @!attribute deviceName
        #   @return [String]
        deviceName: {
          class: :string
        },

        # Device type
        # @!attribute deviceType
        #   @return [String]
        deviceType: {
          class: :string,
          enum: DEVICE_TYPE_OPTIONS
        },

        # Session state
        # @!attribute state
        #   @return [String]
        state: {
          class: :string,
          enum: STATE_OPTIONS
        },

        # ID of session creator if session created by Jamf Pro local user, null otherwise
        # @!attribute creatorId
        #   @return [String]
        creatorId: {
          class: :string
        },

        # Username of the session creator
        # @!attribute creatorName
        #   @return [String]
        creatorName: {
          class: :string
        },

        # Session creation time
        # @!attribute createdAt
        #   @return [Jamf::Timestamp]
        createdAt: {
          class: Jamf::Timestamp,
          format: 'date-time'
        }

      } # end OAPI_PROPERTIES

    end # class SessionDetails

  end # module OAPISchemas

end # module Jamf
